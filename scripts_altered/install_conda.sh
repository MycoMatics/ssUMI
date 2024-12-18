#!/bin/bash
# DESCRIPTION
#    Install longread_umi as conda environment, non-interactively.
#
# IMPLEMENTATION
#    author   Søren Karst (sorenkarst@gmail.com), Ryan Ziels (ziels@mail.ubc.ca)
#    modified by glen dierickx for non-interactive installation
#    license  GNU General Public License

# Terminal input
BRANCH=${1:-master} # Default to master branch

# Check conda installation ----------------------------------------------------
if [[ -z $(which conda) ]]; then
  # Install conda non-interactively
  [ -f Miniconda3-latest-Linux-x86_64.sh ] || \
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
  bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda
  export PATH="/opt/conda/bin:$PATH"
else
  echo "Conda found"
  echo "version: $(conda -V)"
fi

echo ""
echo "Installing longread_umi conda environment..."
echo ""

# Define conda env yml
echo "name: longread_umi
channels:
- conda-forge
- bioconda
- defaults
dependencies:
- seqtk=1.3
- parallel=20191122
- racon=1.4.10
- minimap2=2.17
- gawk=4.1.3
- cutadapt=2.7
- filtlong=0.2.0
- bwa=0.7.17
- samtools=1.9
- bcftools=1.9
- git
" > ./longread_umi.yml

# Install the environment
conda env create -f ./longread_umi.yml

eval "$(conda shell.bash hook)"
conda activate longread_umi

# List of dependencies to check
DEPENDENCIES=("seqtk" "parallel" "racon" "minimap2" "gawk" "cutadapt" "filtlong" "bwa" "samtools" "bcftools" "git")

# Check if each dependency is installed and available on PATH
for dep in "${DEPENDENCIES[@]}"; do
  if [[ -z $(which $dep) ]]; then
    echo "$dep not found in PATH. Exiting..."
    exit 1
  fi
done
# Install porechop
$CONDA_PREFIX/bin/pip install \
  git+https://github.com/rrwick/Porechop.git@master#egg=porechop

# Download longread-UMI pipeline
git clone \
  --branch "$BRANCH" \
  https://github.com/SorenKarst/longread-UMI-pipeline.git \
  $CONDA_PREFIX/longread_umi

# Modify adapters.py
# Adjust Python site-packages path if needed. Assuming Python 3.10 or newer:
PYTHON_SITE=$(python -c "import sysconfig; print(sysconfig.get_paths()['purelib'])")
cp \
  $CONDA_PREFIX/longread_umi/scripts/adapters.py \
  $PYTHON_SITE/porechop/adapters.py

# Make scripts executable and symlink main script
find \
  $CONDA_PREFIX/longread_umi/ \
  -name "*.sh" \
  -exec chmod +x {} \;

ln -s \
  $CONDA_PREFIX/longread_umi/longread_umi.sh \
  $CONDA_PREFIX/bin/longread_umi

# Set USEARCH path non-interactively
# Adjust this if your USEARCH is at a different location
USEARCH_PATH_F="/usr/local/bin/usearch"
chmod +x "$USEARCH_PATH_F"
ln -s "$USEARCH_PATH_F" $CONDA_PREFIX/bin/usearch

# Check installation
if [[ -z $(which longread_umi) ]]; then
  echo "longread_umi installation failed..."
  exit 1
else
  echo "longread_umi installation success..."
  echo "Path to conda environment: $CONDA_PREFIX"
  echo "Path to pipeline files: $CONDA_PREFIX/longread_umi"
fi

conda deactivate

# Cleanup
rm -f ./Miniconda3-latest-Linux-x86_64.sh
rm -f ./longread_umi.yml
rm -f ./install_conda.sh
