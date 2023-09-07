# Table of contents
1. [Introduction](#Introduction)
2. [Install conda](#Installconda)
3. [Create a conda environment](#Create_a_conda_environment)
   - [From predefined yml file](#From_predefined_yml_file)
   - [Manual](#Manual)
4. [Install longread UMI sofware packages](#install_software)
     
# Introduction <a name="Introduction"></a>

Installing the UMI pipeline (https://github.com/ZielsLab/ssUMI) can be tricky and the install.sh script doesn't work on every machine.  
Below you can find a break down on how to install the pipeline manually.

# Install conda <a name="Installconda"></a>
Many of the dependencies can be installed with the packaging management system called conda.
Go to the [conda docs](https://docs.conda.io) and learn how to install conda on your machine.

# Create a conda environment <a name="Create_a_conda_environment"></a>

## From predefined yml file <a name="From_predefined_yml_file"></a>
Download the environment file (.yml format) [HERE]()
```bash
conda env create -f ./longread_umi.yml
```
## Manual <a name="Manual"></a>
Create a new environment
```bash
conda env create -n longread_umi
```

# Install longread UMI sofware packages <a name="install_software"></a>
   - Activate your conda environment          
```console
(base) bioinfo:~$ conda activate longread_umi
(longread_umi) bioinfo:~$
```
**NOTE: avoid installing software in your base env, always check first if you are working in the correct env, notice *base* => *longread_umi***  
   - Install necessary packages one by one
```bash
conda install seqtk=1.3
conda install parallel=20191122
conda install racon=1.4.10
conda install minimap2=2.17
conda install medaka=0.11.5
conda install gawk=4.1.3
conda install cutadapt=2.7
conda install filtlong=0.2.0
conda install bwa=0.7.17
conda install samtools=1.9
conda install bcftools=1.9
conda install git
```
You might notice this is a long process, the connection to the conda repo's can be quite slow. An alternative is **Mamba**.
**Mamba** is a reimplementation of the conda package manager in C++. Basically it runs faster compared to **Conda** using the same repos.
Lear more on Mamba [HERE](https://anaconda.org/conda-forge/mamba)
