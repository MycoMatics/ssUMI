#!/bin/bash
# DESCRIPTION
#    Consensus sequence polishing using medaka.
#    This script is a part of the longread-UMI-pipeline.
#
# IMPLEMENTATION
#    author   Søren Karst (sorenkarst@gmail.com)
#             Ryan Ziels (ziels@mail.ubc.ca)
#    license  GNU General Public License
#

### Description ----------------------------------------------------------------

USAGE="
-- longread_umi polish_medaka: Nanopore UMI consensus polishing with Medaka

usage: $(basename "$0" .sh) [-h] [-X] [-l value] (-c file -m string -d dir -o dir -t value -n file -T value)

where:
    -h  Show this help text.
    -X  Resume mode: continue even if output folder exists.
    -c  File containing consensus sequences.
    -m  Medaka model.
    -l  Expected minimum chunk size. [Default = 6000]
    -d  Directory containing UMI read bins in the format
         'umi*bins.fastq'. Recursive search.
    -o  Output directory.
    -t  Number of threads to use.
    -n  Process n number of bins. If not defined all bins are processed.
    -T  Number of Medaka jobs to run. [Default = 1].
"

### Terminal Arguments ---------------------------------------------------------

# Import user arguments
while getopts ':hXc:m:l:d:o:t:n:T:' OPTION; do
  case $OPTION in
    h) echo "$USAGE"; exit 1;;
    X) RESUME_MODE=1;;   # Resume flag: no argument required.
    c) CONSENSUS_FILE=$OPTARG;;
    m) MEDAKA_MODEL=$OPTARG;;
    l) CHUNK_SIZE=$OPTARG;;
    d) BINNING_DIR=$OPTARG;;
    o) OUT_DIR=$OPTARG;;
    t) THREADS=$OPTARG;;
    n) SAMPLE=$OPTARG;;
    T) MEDAKA_JOBS=$OPTARG;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2; exit 1;;
    \?) printf "invalid option: -%s\n" "$OPTARG" >&2; exit 1;;
  esac
done

# Check missing arguments
MISSING="is missing but required. Exiting."
if [ -z ${CONSENSUS_FILE+x} ]; then echo "-c $MISSING"; echo "$USAGE"; exit 1; fi; 
if [ -z ${MEDAKA_MODEL+x} ]; then echo "-m $MISSING"; echo "$USAGE"; exit 1; fi; 
if [ -z ${CHUNK_SIZE+x} ]; then echo "-l missing. Defaulting to 6000."; CHUNK_SIZE=6000; fi;
if [ -z ${BINNING_DIR+x} ]; then echo "-d $MISSING"; echo "$USAGE"; exit 1; fi; 
if [ -z ${OUT_DIR+x} ]; then echo "-o $MISSING"; echo "$USAGE"; exit 1; fi; 
if [ -z ${THREADS+x} ]; then echo "-t $MISSING"; echo "$USAGE"; exit 1; fi; 
if [ -z ${MEDAKA_JOBS+x} ]; then echo "-T is missing. Defaulting to 1 Medaka job."; MEDAKA_JOBS=1; fi;

### Source commands and subscripts -------------------------------------
. $LONGREAD_UMI_PATH/scripts/dependencies.sh # Path to dependencies script

### Medaka polishing assembly -------------------------------------------------

# Format names
OUT_NAME=${OUT_DIR##*/}

# Medaka jobs
MEDAKA_THREADS=$(( THREADS / MEDAKA_JOBS ))

# Start medaka environment if relevant
eval "$MEDAKA_ENV_START"

# Prepare output folders
if [ -d "$OUT_DIR" ]; then
  if [ -z "$RESUME_MODE" ]; then
    echo "Output folder exists. Exiting..."
    exit 0
  else
    echo "Output folder exists. Continuing in resume mode..."
  fi
else
  mkdir -p "$OUT_DIR"
fi

# Individual mapping of UMI bins to consensus

mkdir -p "$OUT_DIR/mapping"

medaka_align() {
  # Input: a chunk of consensus header from STDIN
  local IN=$(cat)
  local BINNING_DIR=$1
  local OUT_DIR=$2

  # Extract UMI name (assumes filename format 'umi*bins')
  local UMI_NAME
  UMI_NAME=$(echo "$IN" | grep -o "umi.*bins")
  local UMI_BIN
  UMI_BIN=$(find "$BINNING_DIR" -name "${UMI_NAME}.fastq")

  # Setup working directory for this UMI
  mkdir -p "$OUT_DIR/$UMI_NAME"
  echo "$IN" > "$OUT_DIR/$UMI_NAME/$UMI_NAME.fa"

  # Map UMI reads to consensus using mini_align (assumes it's in your PATH)
  mini_align \
    -i "$UMI_BIN" \
    -r "$OUT_DIR/$UMI_NAME/$UMI_NAME.fa" \
    -m \
    -p "$OUT_DIR/$UMI_NAME/${UMI_NAME}" \
    -t 1
}

export -f medaka_align

cat "$CONSENSUS_FILE" |\
  $SEQTK seq -l0 - |\
  ( [[ -f "${SAMPLE}" ]] && grep -A1 -Ff "$SAMPLE" | sed '/^--$/d' || cat ) |\
  $GNUPARALLEL \
    --env medaka_align \
    --progress  \
    -j "$THREADS" \
    --recstart ">" \
    -N 1 \
    --pipe \
    "medaka_align '$BINNING_DIR' '$OUT_DIR/mapping'"

# Calculate consensus probabilities
mkdir -p "$OUT_DIR/consensus"

consensus_wrapper() {
  # Input parameters
  local JOB_NR=$1
  local OUT_DIR=$2
  local MEDAKA_MODEL=$3
  local MEDAKA_THREADS=$4
  local CHUNK_SIZE=$5

  # Custom function to merge bam files for > 1024 files
  bam_merge() {
    local OUT_DIR=$1
    local JOB_NR=$2
    awk -v OUT_BAM="$OUT_DIR/${JOB_NR}" '
      (NR==1 && $1 ~ /^@HD$/){print $0 > OUT_BAM ".header"}
      ($1 ~ /^@SQ$/){print $0 > OUT_BAM ".header"}
      ($1 !~ /^@/){print $0 > OUT_BAM ".body"}
    '
  }
  export -f bam_merge

  # Process bam files in parallel and merge them
  cat |\
    $GNUPARALLEL \
      --env bam_merge \
      -j "$MEDAKA_THREADS" \
      "$SAMTOOLS view -h {}" |\
      bam_merge "$OUT_DIR" "$JOB_NR"

  # Build bam file
  cat "$OUT_DIR/${JOB_NR}.header" "$OUT_DIR/${JOB_NR}.body" |\
    $SAMTOOLS view -b - > "$OUT_DIR/${JOB_NR}.bam"
  rm "$OUT_DIR/${JOB_NR}.header" "$OUT_DIR/${JOB_NR}.body"

  # Index bam file
  $SAMTOOLS index "$OUT_DIR/${JOB_NR}.bam"

  # Run Medaka consensus
  medaka consensus \
    "$OUT_DIR/${JOB_NR}.bam" \
    "$OUT_DIR/${JOB_NR}_consensus.hdf" \
    --threads "$MEDAKA_THREADS" \
    --model "$MEDAKA_MODEL" \
    --chunk_len "$CHUNK_SIZE"
}

export -f consensus_wrapper

find "$OUT_DIR/mapping/" \
  -mindepth 2 \
  -maxdepth 2 \
  -type f \
  -name "umi*bins.bam" |\
$GNUPARALLEL \
  --env consensus_wrapper \
  --progress \
  -j "$MEDAKA_JOBS" \
  -N1 \
  --roundrobin \
  --pipe \
  "consensus_wrapper {#} '$OUT_DIR/consensus' '$MEDAKA_MODEL' '$MEDAKA_THREADS' '$CHUNK_SIZE'"

# Stitch consensus sequences together
medaka stitch \
  --threads "$THREADS" \
  "$OUT_DIR/consensus/"*"_consensus.hdf" \
  "$CONSENSUS_FILE" \
  "$OUT_DIR/consensus_${OUT_NAME}.fa"

# Clean consensus header
sed -i -e "s/:.*//" -e "s/_segment.*//" "$OUT_DIR/consensus_${OUT_NAME}.fa"

# Deactivate medaka environment if relevant
eval "$MEDAKA_ENV_STOP"

exit 0
