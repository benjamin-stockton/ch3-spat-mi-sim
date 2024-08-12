library(mice)
library(imputeangles)

file_path <- file.path("R")
source(file.path(file_path, "generate_data.R"))
source(file.path(file_path, "impute.R"))
source(file.path(file_path, "analysis.R"))
source(file.path(file_path, "simulation.R"))
source(file.path(file_path, "utils.R"))

# From command line get the following arguments
N_sim <- 5 # Number of simulation iterations
N_sample <- 7 # Sample size
init_seed <- 9137 # Initial seed
M <- 1 # Number of imputations
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
    p_miss = 0.1
) # Missingness mechanism parameters (also controls MAR/MNAR)

methods <- c("complete", "pmm", "pgpreginc", "pnregid")

x1 <- pop_pars

out_path <- file.path("sim-results")


saveRDS(x1, file = paste0(out_path, "/test-sim-results-mar-spat-mi-", Sys.Date(), "-sim_setting-", 1, ".rds"))

