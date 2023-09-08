# Installation
## Install longread umi

  1. download install_conda.sh: https://github.com/SorenKarst/longread_umi
  2. change porechop path in install_conda.sh: 
```bash
$CONDA_PREFIX/bin/pip install \
  git+https://github.com/rrwick/Porechop.git@master#egg=porechop
```
  3. delete medaka from yml conda
  4. run installation script

## move to ssUMI
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

# TODO edit file dependencies from: https://github.com/ZielsLab/ssUMI
## $script_path/scripts/dependencies.sh
Adjust $PATH of following dependencies
|  Tool |Line replace   |
|---|---|
|Usearch   | export USEARCH="/path/to/usearch"  |
|Vsearch   | export VSEARCH="/path/to/vsearch"  |
|Medaka   | export MEDAKA_ENV_START="source /path/to/medaka/bin/activate"   |
# TODO TEST RUN
