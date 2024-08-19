library(mice, warn.conflicts = F, quietly = T)
library(imputeangles)

file_path <- file.path("R")
source(file.path(file_path, "generate_data.R"))
source(file.path(file_path, "impute.R"))
source(file.path(file_path, "analysis.R"))
source(file.path(file_path, "simulation.R"))
source(file.path(file_path, "utils.R"))

# From command line get the following arguments
N_sim <- 50 # Number of simulation iterations
N_sample <- 15 # Sample size
init_seed <- 91241 # Initial seed
M <- 50 # Number of imputations
pop_pars <- list(
    mu0 = c(1,0),
    B_vec = c(1, 3),
    sigma_w = 1,
    rho_w = 0,
    rho = 3,
    beta_y = c(5, 1, 0.5, -0.25),
    sigma_y = 0.5,
    rho_y = 0.65,
    alpha_y = 0.1
) # population parameters to draw samples from
miss_pars <- list(
    freq = c(1),
    mech = "MAR",
    p_miss = 0.5
) # Missingness mechanism parameters (also controls MAR/MNAR)

methods <- c("complete", "mean", "norm", "pgpreginc", "pnregid")

sim_data <- read.csv(paste0("data/simulated_data_mar_n_", N_sample, ".csv"), header = TRUE)

out_path <- file.path("sim-results")

f_out <- paste0(out_path, "/sim-results-mar-spat-mi-sim_setting-", 9)

x1 <- parallel::mclapply(1:N_sim,
                         mc.cores = 100,
                         function(x) {
                             # x1 <- lapply(1:N_sim, function(x) {
                             print(paste0("Iteration ", x+50, "; Generating data"))

                             inc_data <- sim_data |>
                                 dplyr::filter(.id == x+50)
                             prop_miss <- apply(as.matrix(inc_data[,c(4:6)]), 2, function(i) {mean(is.na(i))})

                             iter_res <- lapply(methods, function(mtd) {
                                 if (mtd == "complete") {
                                     print(paste0("Iteration ", x+50, "; Complete Data Geostat Analysis"))
                                     sample_data <- inc_data |>
                                         dplyr::mutate(
                                             theta = theta_obs,
                                             U1 = cos(theta_obs),
                                             U2 = sin(theta_obs)
                                         )
                                     res <- geostat_analysis(sample_data)
                                 }
                                 else if (mtd %in% c("pmm", "pnregid", "mean", "norm")) {
                                     print(paste0("Iteration ", x+50, "; Imputing with: ", mtd))
                                     imp_data <- impute(inc_data, method = mtd, M = M, maxit = 1, mc.cores = mc.cores)
                                     print(paste0("Iteration ", x+50, "; Geostat Analysis"))

                                     res <- geostat_analysis_imp(imp_data, mc.cores = mc.cores)
                                 }
                                 else if (mtd == "pgpreginc") {
                                     print(paste0("Iteration ", x+50, "; Imputing with: ", mtd))
                                     imp_data <- impute(inc_data, method = mtd, M = M, maxit = 1, mc.cores = mc.cores)
                                     print(paste0("Iteration ", x+50, "; Geostat Analysis"))

                                     res <- geostat_analysis_imp(imp_data, mc.cores = mc.cores)
                                 }

                                 res$par_val <- c(pop_pars$beta_y, pop_pars$sigma_y,
                                                  pop_pars$alpha_y, pop_pars$rho_y)
                                 res$p_miss <- c(0, prop_miss, 0,0,0)
                                 res$iter <- x
                                 res$method <- mtd
                                 return(res)
                             })
                             # print(iter_res)

                             iter_res |>
                                 dplyr::bind_rows() -> results
                             f_out <- paste0(f_out, "-iter-", x, ".csv")

                             if (file.exists(f_out)) {
                                 readr::write_csv(results, f_out, append = TRUE)
                             } else {
                                 readr::write_csv(results, f_out)
                             }

                             return(results)
                         })


saveRDS(x1, file = paste0(out_path, "/sim-results-mar-spat-mi-", Sys.Date(), "-sim_setting-", 9, "-2.rds"))
#
# x2 <- x1 |>
#     dplyr::bind_rows()


