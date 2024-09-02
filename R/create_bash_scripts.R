create_bash_scripts <- function(sim_file_path, script_base_name, sh_name, setting, n_cpus = 15, partition = "lo-core") {

    lapply(setting$set_n, function(sc) {
        bash_script_content <- paste0("#!/bin/bash \n#SBATCH --partition=", partition, "\n#SBATCH --constraint='epyc128'\n#SBATCH --cpus-per-task=", n_cpus, "\n#SBATCH --ntasks=1\n#SBATCH --nodes=1\n#SBATCH --mail-type=ALL\n#SBATCH --mail-user=benjamin.stockton@uconn.edu\nsource /etc/profile.d/modules.sh\nmodule purge\nmodule load r/4.3.2\ncd .. \n\n")

        script_name <- file.path(sim_file_path,
                                 sprintf(script_base_name, sc)
        )

        new_lines <- paste0('echo "Running ', script_name, '" \ntime Rscript "', script_name, '"\n')
        bash_script_content <- paste0(bash_script_content, new_lines)


        bash_script_content <- paste0(bash_script_content, '\necho "Done!"')

        sh_name <- paste0(sh_name, "-setting-", sc, ".sh")

        sh_name <- file.path("bash", sh_name)

        writeLines(bash_script_content, sh_name)

        print(paste0("Script at: ", sh_name))
    })

}

