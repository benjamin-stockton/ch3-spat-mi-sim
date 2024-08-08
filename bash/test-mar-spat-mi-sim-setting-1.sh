#!/bin/bash 
#SBATCH --partition=general
#SBATCH --constraint='epyc128'
#SBATCH --cpus-per-task=15
#SBATCH --ntasks=1
#SBATCH --nnodes=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=benjamin.stockton@uconn.edu
cd .. 

echo "Running sim_scripts/test-mar-spat-mi-sim_setting-1.R" 
time Rscript "sim_scripts/test-mar-spat-mi-sim_setting-1.R"

echo "Done!"
