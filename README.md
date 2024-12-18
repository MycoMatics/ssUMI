# ssUMI apptainer branch
This branch of the pipeline runs in a containerized environment for ease of use using [Apptainer/Singularity](https://github.com/apptainer/apptainer) .

Original pipeline: https://github.com/SorenKarst/longread_umi  
ssUMi pipeline: https://github.com/ZielsLab/ssUMI

In this repo you'll find an overview of the changes to both installation process and scripts to the above pipelines.
On the one hand solving installation issues, on the other hand fitting it to our wetlab conditions.


**Table of contents**
                
1. [Installation](#Installation)   
                    1.1 [Install longread umi](#Installlongreadumi)  
                    1.2 [Move from UMI to ssUMI pipeline](#MovefromUMItossUMIpipeline)  
2. [Install Usearch](#Usearch)  
3. [Install Vsearch](#Vsearch)  
4. [Install Medaka](#Medaka)  
5. [Small changes in scripts](#Smallchangesinscripts)  
                    5.1 [Filename: dependencies.sh](#Filenamedependencies)  
                    5.2 [Filename: ssumi_std.sh](#Filenamessumistd)  
                    5.3 [Filename: umi_binning.sh](#Filenameumibinning)
     
<a name="Installation"></a>
# Installation
<a name="Installlongreadumi"></a>
Having [Apptainer](https://github.com/apptainer/apptainer) (previously Singularity) is a prerequisite for install using this branch .
Also detailed in [install.txt](./build/install.txt)
Download the definition file and provide it (or the path) to Apptainer.
```shell
apptainer build ssUMI.sif ssUMI_definition
```
This build the container, which can be run using the flags detailed in the [Zielslab repo](https://github.com/ZielsLab/ssUMI) .
```shell
# display help for standard ssUMI pipeline
apptainer run ssUMI.sif ssumi_std -h
# example flags for fungal ITS amplicon
apptainer run ssUMI.sif ssumi_std \
  -d barcode43.fastq \
  -v 3 \
  -o barcode43_umi_out \
  -s 200 \
  -e 200 \
  -E 0.2 \
  -m 500 \
  -M 1200 \
  -f GTATCGTGTAGAGACTGCGTAGG \
  -F TGTACACACCGCCCGTCG \
  -r AGTGATCGAGTCAGTGCGAGTG \
  -R TCGCCTSCSCTTANTDATATGC \
  -c 3 \
  -p 2 \
  -q r1041_e82_400bps_sup_v5.0.0 \
  -t 12 \
  -T 4
```



<a name="Smallchangesinscripts"></a>
# Small changes in scripts  
The ssUMI pipeline uses different scripts where you need to set parameters which are different on each system.
The scripts are found in the $script_path/ see [Move from UMI to ssUMI pipeline](#MovefromUMItossUMIpipeline) folder of the umi_pipeline.
General changes can be found in the github [Zielslab repo](https://github.com/ZielsLab/ssUMI).  
Other changes and optimizations are made by the mycology lab for fitting to the slightly changes in wet lab approach compared to the labwork used by the original authors.  

Direct [download for adjusted script](https://github.com/MycoMatics/ssUMI/tree/Apptainer/scripts_altered) 

<a name="Filenamedependencies"></a>
## Filename: dependencies.sh  
Dependency paths are fixed in the container
<a name="Filenamessumistd"></a>
## Filename: ssumi_std.sh   

  - LINE 222: for correct directory
```bash
tar -czvf ${CON_DIR2}/mapping.tar.gz >${CON_DIR2}/mapping/umi*bins --remove-files
```

  - LINE 209: Clean-up (compressing) of medaka mapping directory should be moved within the for loop
```bash
## Polishing
CON=${CON_DIR}/consensus_${CON_NAME}.fa
for j in `seq 1 $POL_N`; do
  POLISH_NAME=medakax${j}
  POLISH_DIR=${CON_DIR}_${POLISH_NAME}
  longread_umi polish_medaka \
    -c $CON                              `# Path to consensus data`\
    -m $MEDAKA_MODEL                     `# Path to consensus data`\
    -l $MAX_LENGTH                       `# Sensible chunk size`\
    -d $UMI_DIR/read_binning/bins        `# Path to UMI bins`\
    -o $POLISH_DIR                       `# Output folder`\
    -t $THREADS                          `# Number of threads`\
    -n $OUT_DIR/sample$UMI_SUBSET_N.txt  `# List of bins to process` \
    -T $MEDAKA_JOBS                      `# Uses ALL threads with medaka`
  CON=$POLISH_DIR/consensus_${CON_NAME}_${POLISH_NAME}.fa
  #Tidy up
  tar -czvf ${POLISH_DIR}/mapping.tar.gz ${POLISH_DIR}/mapping --remove-files
done
```

  - LINE224 – 225: Clean-up of final racon polishing should compress and remove correct directory
```bash
## Final racon polishing
CON_N2=1
CON_NAME2=${CON_NAME}_${POLISH_NAME}_raconx${CON_N2}
CON_DIR2=$OUT_DIR/$CON_NAME2
longread_umi polish_racon \
    -c $CON                              `# Path to consensus data`\
    -d $UMI_DIR/read_binning/bins        `# Path to UMI bins`\
    -o $CON_DIR2                          `# Output folder`\
    -t $THREADS                          `# Number of threads`
#Tidy up
tar -czvf ${CON_DIR2}/mapping.tar.gz ${CON_DIR2}/mapping/umi*bins --remove-files
rmdir ${CON_DIR2}/mapping
```
<a name="Filenameumibinning"></a>
## Filename: umi_binning.sh   
  - Last line of the scirpt
```bash
tail -n +1 > $BINNING_DIR/pass_bins.txt
```

  - LINE223: Cutadapt should filter for UMIs that are 28 bp long
```bash
$CUTADAPT -j $THREADS -e 0.1 -O 11 -m 28 -M 28 \
```

  - LINE 237–239: pattern should be replaced by the used ONT UMI pattern (we used Nanopore’s)
```bash
#new pattern from ONT (less homopolymers) (TTTVVVVTTVVVVTTVVVVTTVVVVTTT AAABBBBAABBBBAABBBBAABBBBAAA)
PATTERN="[T]{3}[ACG]{4}[T]{2}[ACG]{4}[T]{2}[ACG]{4}[T]{2}[ACG]{4}[T]{3}\
[A]{3}[CGT]{4}[A]{2}[CGT]{4}[A]{2}[CGT]{4}[A]{2}[CGT]{4}[A]{3}"
```

  - LINE 245: Speed up USEARCH commands by using all available threads
```bash
$USEARCH \
  -fastx_uniques $UMI_DIR/umi12f.fa \
  -fastaout $UMI_DIR/umi12u.fa \
  -sizeout \
  -minuniquesize 1 \
  -relabel umi \
  -strand both \
  -threads all
```

  - LINE 254: Speed up USEARCH commands by using all available threads
```bash
$USEARCH \
  -cluster_fast $UMI_DIR/umi12u.fa \
  -id 0.90 \
  -centroids $UMI_DIR/umi12c.fa \
  -uc $UMI_DIR/umi12c.txt \
  -sizein \
  -sizeout \
  -strand both \
  -sort size \
  -maxaccepts 0 \
  -maxrejects 0 \
  -threads all \
  -mincols 34
```

  - LINE 285: Adjust gawk that splits UMIs into forward/rev UMIs for 28 bp
```bash
$GAWK \
  '
    /^>/{
      HEAD=$0
      getline
      print HEAD "_1\n" substr($0,1,28) "\n" HEAD "_2\n" substr($0,29,28)
    }
  ' $UMI_DIR/umi_ref.fa \
  > $UMI_DIR/umi_ref_sub.fa
```

  - LINE 296: Speed up USEARCH commands by using all available threads
```bash
$USEARCH \
  -cluster_fast $UMI_DIR/umi_ref_sub.fa \
  -id 0.94 \
  -uc $UMI_DIR/umi_ref_chimera.txt \
  -sizein \
  -sizeout \
  -strand both \
  -sort size \
  -maxaccepts 0 \
  -maxrejects 0 \
  -mincols 17 \
  -threads all
```

  - LINE 311: Speed up USEARCH command by using all available threads
```bash
$USEARCH \
  -cluster_fast $UMI_DIR/umi_ref.fa \
  -id 0.83 \
  -uc $UMI_DIR/umi_ref_derivates.txt \
  -sizein \
  -sizeout \
  -strand both \
  -sort size \
  -maxaccepts 0 \
  -maxrejects 0 \
  -mincols 56 \
  -threads all
```

  - LINE 349: Adjust correct UMI size to 28 bp
```bash
# Divide in barcode1 and barcode2 files
cat $UMI_DIR/umi_ref.fa <($SEQTK seq -r $UMI_DIR/umi_ref.fa |\
  $GAWK 'NR%2==1{print $0 "_rc"; getline; print};') |\
  $GAWK -v BD="$BINNING_DIR" 'NR%2==1{
       print $0 > BD"/umi_ref_b1.fa";
       print $0 > BD"/umi_ref_b2.fa";  
     }
     NR%2==0{
       print substr($0, 1, 28) > BD"/umi_ref_b1.fa";
       print substr($0, 29, 28)  > BD"/umi_ref_b2.fa";  
     }'
```
# TODO TEST RUN
