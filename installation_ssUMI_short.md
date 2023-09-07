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

## 
# install vsearch & usearch in /usr/local/bin
# install Medaka
