# Table of contents
1. [Introduction](#Introduction)
2. [Install conda](#Installconda)
3. [Create a conda environment](#Create_a_conda_environment)
4. 
# Introduction <a name="Introduction"></a>

Installing the UMI pipeline (https://github.com/ZielsLab/ssUMI) can be tricky and the install.sh script doesn't work on every machine.  
Below you can find a break down on how to install the pipeline manually.

# Install conda <a name="Installconda"></a>
Many of the dependencies can be installed with the packaging management system called conda.
Go to the [conda docs](https://docs.conda.io) and learn how to install conda on your machine.

# Create a conda environment <a name="Create_a_conda_environment"></a>
  - Download the environment file (.yml format) [HERE]()
```bash
conda env create -f ./longread_umi.yml
```
