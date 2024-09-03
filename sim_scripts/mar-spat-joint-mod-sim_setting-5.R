library(mice, warn.conflicts = F, quietly = T)
library(imputeangles)

file_path <- file.path("R")
source(file.path(file_path, "generate_data.R"))
source(file.path(file_path, "impute.R"))
source(file.path(file_path, "analysis.R"))
source(file.path(file_path, "simulation.R"))
source(file.path(file_path, "utils.R"))

# From command line get the following arguments
N_sim <- 500 # Number of simulation iterations
N_sample <- 10 # Sample size
init_seed <- 9137 # Initial seed
M <- 25 # Number of imputations
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
    p_miss = 0.25
) # Missingness mechanism parameters (also controls MAR/MNAR)

methods <- c("complete", "cca", "jpgpmgpimp", "norm", "pnregid")

out_path <- file.path("sim-results", paste0("set-", 5))
f_out <- paste0(out_path, "/sim-results-mar-spat-joint-mod-sim_setting-", 5)

x1 <- simulation(N_sim, N_sample, init_seed, M, methods, pop_pars, miss_pars, f_out = f_out, mc.cores = N_sim)

saveRDS(x1, file = paste0(out_path, "/sim-results-mar-spat-joint-mod-", Sys.Date(), "-sim_setting-", 5, ".rds"))

# x2 <- x1 |>
#     dplyr::bind_rows()

# if (file.exists(f_out)) {
#     readr::write_csv(x2, f_out, append = TRUE)
# } else {
#     readr::write_csv(x2, f_out)
# }

