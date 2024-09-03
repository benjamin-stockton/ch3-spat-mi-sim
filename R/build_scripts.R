library(dplyr)
library(purrr)

#################################################
## Test: MAR Spat with Incompleteness only on Angles ##
#################################################

setting <- readRDS("sim-settings/test_setting.rds")

purrr::pwalk(.l = setting,
             .f = function(N_sample, N_sim, p_miss, M, set_n){
                 cat(
                     whisker::whisker.render(
                         readLines('tmpls/test-mar-spat-mi-sim.tmpl'),
                         data = list(
                             N_sample = N_sample,
                             N_sim = N_sim,
                             M = M,
                             p_miss = p_miss,
                             set_n = set_n)
                     ),
                     file = file.path('sim_scripts',
                                      sprintf("test-mar-spat-mi-sim_setting-%s.R",
                                              set_n)
                     ),
                     sep='\n')
             })

source("R/create_bash_scripts.R")

create_bash_scripts("sim_scripts",
                    script_base_name = "test-mar-spat-mi-sim_setting-%s.R",
                    sh_name = "test-mar-spat-mi-sim",
                    setting = setting,
                    n_cpus = 15)

#################################################
## MAR Spat with Incompleteness only on Angles ##
#################################################

setting <- readRDS("sim-settings/setting.rds")

purrr::pwalk(.l = setting,
             .f = function(N_sample, N_sim, p_miss, M, set_n){
                 cat(
                     whisker::whisker.render(
                         readLines('tmpls/mar-spat-mi-sim.tmpl'),
                         data = list(
                             N_sample = N_sample,
                             N_sim = N_sim,
                             M = M,
                             p_miss = p_miss,
                             set_n = set_n)
                     ),
                     file = file.path('sim_scripts',
                                      sprintf("mar-spat-mi-sim_setting-%s.R",
                                              set_n)
                     ),
                     sep='\n')
             })

source("R/create_bash_scripts.R")

create_bash_scripts("sim_scripts",
                    script_base_name = "mar-spat-mi-sim_setting-%s.R",
                    sh_name = "mar-spat-mi-sim",
                    setting = setting,
                    n_cpus = 50)

#################################################
## Test: MAR Spat with Incompleteness only on Angles ##
#################################################

setting <- readRDS("sim-settings/test_setting.rds")

purrr::pwalk(.l = setting,
             .f = function(N_sample, N_sim, p_miss, M, set_n){
                 cat(
                     whisker::whisker.render(
                         readLines('tmpls/test-mar-spat-joint-mod-sim.tmpl'),
                         data = list(
                             N_sample = N_sample,
                             N_sim = N_sim,
                             M = M,
                             p_miss = p_miss,
                             set_n = set_n)
                     ),
                     file = file.path('sim_scripts',
                                      sprintf("test-mar-spat-joint-mod-sim_setting-%s.R",
                                              set_n)
                     ),
                     sep='\n')
             })

source("R/create_bash_scripts.R")

create_bash_scripts("sim_scripts",
                    script_base_name = "test-mar-spat-joint-mod-sim_setting-%s.R",
                    sh_name = "test-mar-spat-joint-mod-sim",
                    setting = setting,
                    n_cpus = 15,
                    partition = "general")

#################################################
## MAR Spat Joint Modeling with Incompleteness only on Angles ##
#################################################

setting <- readRDS("sim-settings/jm_setting.rds")

purrr::pwalk(.l = setting,
             .f = function(N_sample, N_sim, p_miss, M, set_n){
                 cat(
                     whisker::whisker.render(
                         readLines('tmpls/mar-spat-joint-mod-sim.tmpl'),
                         data = list(
                             N_sample = N_sample,
                             N_sim = N_sim,
                             M = M,
                             p_miss = p_miss,
                             set_n = set_n)
                     ),
                     file = file.path('sim_scripts',
                                      sprintf("mar-spat-joint-mod-sim_setting-%s.R",
                                              set_n)
                     ),
                     sep='\n')
             })

source("R/create_bash_scripts.R")

create_bash_scripts("sim_scripts",
                    script_base_name = "mar-spat-joint-mod-sim_setting-%s.R",
                    sh_name = "mar-spat-joint-mod-sim",
                    setting = setting,
                    n_cpus = 100,
                    partition = "general")
