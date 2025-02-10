# ssUMI apptainer branch
This branch of the pipeline runs in a containerized environment for ease of use using [Apptainer/Singularity](https://github.com/apptainer/apptainer) .

Original pipeline: https://github.com/SorenKarst/longread_umi  
ssUMi pipeline: https://github.com/ZielsLab/ssUMI

**Table of contents**
                
1. [Installation](#Installation)   

2. [Small changes in scripts](#Smallchangesinscripts)  

3. [Test run](#Testrun)
   
<a name="Installation"></a>
# Installation
<a name="Installlongreadumi"></a>
Having [Apptainer](https://github.com/apptainer/apptainer) (previously Singularity) is a prerequisite for install using this branch .
Also detailed in [install.txt](./build/install.txt)
Download the definition file and provide it (or the path) to Apptainer .
```shell
apptainer build ssUMI.sif ssUMI_definition
```
This build the container, which can be run using the flags detailed in the [Zielslab repo](https://github.com/ZielsLab/ssUMI) .
For now, the container is build by cloning the longread_umi and ssUMI githubs and moving the correct scripts around .
While this works, it will break if those repos change significantly. This will be adressed in a future update when I find the time .

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
  -T 4 \
  -P TTTVVVVTTVVVVTTVVVVTTVVVVTTT
```



<a name="Smallchangesinscripts"></a>
# Small changes in scripts  
Some small changes have been made to the original ssUMI pipeline scripts, the revised scripts can be found in [scripts_altered](https://github.com/MycoMatics/ssUMI/tree/Apptainer/scripts_altered)
This includes the addition of a flag that allows the user to specify the UMI pattern (e.g. ONT advises TTTVVVVTTVVVVTTVVVVTTVVVVTTT, while the original pipeline is hardcoded for NNNYRNNNYRNNNYRNNN).
Be sure to check out the githubs of the original pipelines [Zielslab/ssUMI](https://github.com/ZielsLab/ssUMI) and [SorenKarst/longread_umi](https://github.com/SorenKarst/longread_umi) for extended information and documentation.

<a name="Testrun"></a>
# TEST RUN
```shell
# download test data and unzip
wget -O bc43.fastq.gz https://raw.githubusercontent.com/MycoMatics/ssUMI/refs/heads/Apptainer/test_data/bc43.fastq.gz
gunzip bc43.fastq.gz

# Make sure you have ssUMI.sif in the working dir or point to its location
apptainer run ssUMI.sif  ssumi_std \
  -d bc43.fastq \
  -v 3 \
  -o bc43_out \
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
  -T 4 \
  -P TTTVVVVTTVVVVTTVVVVTTVVVVTTT

```
The test data should run in <10 minutes (more if using a single thread) .
The main output is the fasta file [consensus_raconx3_medakax2_raconx1.fa](./test_data/consensus_raconx3_medakax2_raconx1.fa) containing 58 UMIs.

