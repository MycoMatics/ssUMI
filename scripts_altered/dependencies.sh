#!/bin/bash
# DESCRIPTION
#    Paths to dependencies for longread-UMI-pipeline 
#
# IMPLEMENTATION
#    author   Søren Karst (sorenkarst@gmail.com)
#             Ryan Ziels (ziels@mail.ubc.ca)
#    license  GNU General Public License

# Program paths

export SEQTK=seqtk
export GNUPARALLEL=parallel
export RACON=racon
export MINIMAP2=minimap2
export GAWK=gawk
export SAMTOOLS=samtools
export BCFTOOLS=bcftools
export CUTADAPT=cutadapt
export PORECHOP_UMI=porechop
export FILTLONG=filtlong
export BWA=bwa
export USEARCH="path/to/usearch"
export MEDAKA_ENV_START="$CONDA_PREFIX/envs/medaka/bin/activate"
export MEDAKA_ENV_STOP="deactivate"
export VSEARCH="path/to/vsearch"

# longread_umi paths
#export REF_CURATED=$LONGREAD_UMI_PATH/scripts/zymo-ref-uniq_2019-10-28.fa
#export REF_VENDOR=$LONGREAD_UMI_PATH/scripts/zymo-ref-uniq_vendor.fa
export BARCODES=$LONGREAD_UMI_PATH/scripts/barcodes.tsv

# Version dump
longread_umi_version_dump (){
  local OUT=${1:-./longread_umi_version_dump.txt}

  echo "Script start: $(date +%Y-%m-%d-%T)"  >> $OUT
  echo "Software Version:" >> $OUT
  echo "longread_umi - $(git --git-dir ${LONGREAD_UMI_PATH}/.git describe --tag)" >> $OUT
  echo "seqtk - $($SEQTK 2>&1 >/dev/null | grep 'Version')" >> $OUT 
  echo "Parallel - $($GNUPARALLEL --version | head -n 1)" >> $OUT 
  echo "Usearch - $($USEARCH --version)" >> $OUT 
  echo "Racon - $($RACON --version)" >> $OUT
  echo "Minimap2 - $($MINIMAP2 --version)" >> $OUT
  echo "medaka - $(eval $MEDAKA_ENV_START; medaka --version | cut -d" " -f2; eval $MEDAKA_ENV_STOP)"  >> $OUT
  echo "medaka model - ${MEDAKA_MODEL##*/}"  >> $OUT
  echo "Gawk - $($GAWK --version | head -n 1)" >> $OUT 
  echo "Cutadapt - $($CUTADAPT --version | head -n 1)" >> $OUT 
  echo "Porechop - $($PORECHOP_UMI --version) + add UMI adaptors to adaptors.py" >> $OUT 
  echo "Filtlong - $($FILTLONG --version)" >> $OUT
  echo "BWA - $($BWA 2>&1 >/dev/null | grep 'Version')" >> $OUT
  echo "Samtools - $($SAMTOOLS 2>&1 >/dev/null | grep 'Version')" >> $OUT
  echo "Bcftools - $($BCFTOOLS --version | head -n 1)" >> $OUT
  echo "vsearch - $($VSEARCH --version | head -n 1)" >> $OUT
}

### Version dump
# source dependencies.sh
# longread_umi_version_dump
