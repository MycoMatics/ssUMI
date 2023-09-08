**Table of contents**

  1. [Installation](#Installation)   
    1.1 [Install](#Installlongreadumi)  
    1.2 [Move from UMI to ssUMI pipeline](#MovefromUMItossUMIpipeline)  
  2. [Install Usearch](#Usearch)  
  3. [Install Vsearch](#Vsearch)  
  4. [Install Medaka](#Medaka)  
  5. [Small changes in scripts](#Smallchangesinscripts)  
    5.1 [Filename: dependencies.sh](#Filenamedependencies)  
    5.2 [Filename: ssumi_std.sh](#Filenamessumistd)  
    5.3 [Filename: umi_binning.sh](#Filenameumibinning)

# Installation <a name="Installation"></a>
## Install longread umi <a name="Installlongreadumi"></a>

  1. download install_conda.sh: https://github.com/SorenKarst/longread_umi
  2. change porechop path in install_conda.sh: 
```bash
$CONDA_PREFIX/bin/pip install \
  git+https://github.com/rrwick/Porechop.git@master#egg=porechop
```
  3. delete medaka from yml conda
  4. run installation script

## Move from UMI to ssUMI pipeline <a name="MovefromUMItossUMIpipeline"></a>

  1. determine prefix  
Determine the location of the package contents. For instance, if longread_umi was installed via conda, type:
```bash
conda activate longread_umi
script_path="`echo "$CONDA_PREFIX/longread_umi"`"
conda deactivate
```  
  2. clone longread_umi
```bash
git clone https://github.com/ZielsLab/ssUMI.git
```
  3. Replace the longread_umi scripts folder with the new (ssUMI) scripts folder

```bash
mv $script_path/scripts $script_path/scripts_old
mv path/to/ssUMI/scripts $script_path/
chmod +x $script_path/scripts/*
```
  4. Replace the longread_umi test_Data folder with the new (ssUMI) scripts folder

```bash
mv $script_path/test_Data $script_path/test_data_old
mv path/to/ssUMI/test_data $script_path/
```

# Install Usearch <a name="Usearch"></a>
Usearch program is only one file, the free version is 32bit (slower than the paying version which is 64bit).  
If you need more information on the program follow [this website](https://www.drive5.com/usearch/manual/install.html).  

**Direct link to [download page](https://drive5.com/usearch/download.html)**
   1. Download binary file to /usr/local/bin
   2. Make a sym link to the file for keeping things easy
```bash
ln -s usearch6.0.98_i86linux32 usearch
```
**NOTE: Using a symbolic link has the advantage that the original name is preserved and will be shown by the ls -l command, e.g:**
```console
$ ls -l usearch
lrwxr-xr-x 1 robert admin 26 2012-07-19 08:55 usearch -> usearch6.0.98_i86linux32
 ```
   3. Make sure the 
# Install Vsearch <a name="Vsearch"></a>
Vsearch is the free version of 64bit Usearch sort of speak.  
For more info, detailed download and installtion instructions go to [VSEARCHgit](https://github.com/torognes/vsearch)  
Source distribution [all versions](https://github.com/torognes/vsearch/releases)

Famous last words: 
   > I know what I'm doing, I don't need no manual.
```bash
wget https://github.com/torognes/vsearch/archive/v2.23.0.tar.gz
tar xzf v2.23.0.tar.gz
cd vsearch-2.23.0
./autogen.sh
./configure CFLAGS="-O3" CXXFLAGS="-O3" --prefix=/usr/local
make
make install  # as root or sudo make install
```
# install Medaka <a name="Medaka"></a>

**Installation via pip env**
Bioinformatic tools are beeing installed in a central folder with symlinks to $PATH, in this case in /usr/local/bioinfo.

```bash
mkdir /usr/local/bioinfo
cd /usr/local/bioinfo

virtualenv medaka --python=python3 --prompt "(medaka_pipenv)" # creates a medaka folder in $PWD
. /usr/local/bioinfo/medaka/bin/activate # activates medaka pip env => ((medaka_pipenv)) (base) bioinfo:$
pip install --upgrade pip
pip install medaka # installs medaka and dependencies from pip into the medaka_pipenv
medaka tools download_models 
deactivate
```

**NOTE:** The bioconda medaka packages are no longer supported by Oxford Nanopore Technologies.  
See other installation [suggestions](https://github.com/nanoporetech/medaka) from ONT for medaka installations.

# Small changes in scripts <a name="Smallchangesinscripts"></a>
The ssUMI pipeline uses different scripts where you need to set parameters which are different on each system.
The scripts are found in the $script_path/ (see ## move to ssUMI) folder of the umi_pipeline.
General changes can be found in the github [Zielslab repo](https://github.com/ZielsLab/ssUMI).  
Other changes and optimizations are made by the mycology lab for fitting to the slightly changes in wet lab approach compared to the labwork used by the original authors.

## Filename: dependencies.sh <a name="Filenamedependencies"></a>

Adjust $PATH of following dependencies  

|  Tool |Line replace   |
|---|---|
|Usearch   | export USEARCH="/path/to/usearch"  |
|Vsearch   | export VSEARCH="/path/to/vsearch"  |
|Medaka   | export MEDAKA_ENV_START="source /path/to/medaka/bin/activate"   |

## Filename: ssumi_std.sh <a name="Filenamessumistd"></a>

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

## Filename: umi_binning.sh <a name="Filenameumibinning"></a>
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
