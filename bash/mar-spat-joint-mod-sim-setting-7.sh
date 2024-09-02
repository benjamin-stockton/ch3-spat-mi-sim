#!/bin/bash 
#SBATCH --partition=general
#SBATCH --constraint='epyc128'
#SBATCH --cpus-per-task=100
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=benjamin.stockton@uconn.edu
source /etc/profile.d/modules.sh
module purge
module load r/4.3.2
cd .. 

echo "Running sim_scripts/mar-spat-joint-mod-sim_setting-7.R" 
time Rscript "sim_scripts/mar-spat-joint-mod-sim_setting-7.R"

echo "Done!"
