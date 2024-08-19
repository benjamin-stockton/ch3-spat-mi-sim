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

echo "Running R/simulate_data_mar_n_7.R"
time Rscript "R/simulate_data_mar_n_7.R"
echo "Running R/simulate_data_mar_n_10.R"
time Rscript "R/simulate_data_mar_n_10.R"
echo "Running R/simulate_data_mar_n_15.R"
time Rscript "R/simulate_data_mar_n_15.R"

echo "Done!"
