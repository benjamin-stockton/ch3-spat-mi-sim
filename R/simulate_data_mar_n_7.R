library(dplyr)

source("R/generate_data.R")

N_sim <- 500 # Number of simulation iterations
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

sim_data <- parallel::mclapply(1:500, mc.cores = 20, function(i) {
    sample_data <- generate_data(N_sample, pop_pars)

    inc_data <- impose_missingness(sample_data,
                                   freq = miss_pars$freq,
                                   mech = miss_pars$mech,
                                   p_miss = miss_pars$p_miss)
    inc_data$theta_obs <- sample_data$theta
    inc_data$.id <- i
    # print(apply(as.matrix(inc_data[,c(4:6)]), 2, function(i) {mean(is.na(i))}))

    return(inc_data)
}) |> bind_rows()

readr::write_csv(sim_data, "data/simulated_data_mar_n_7.csv")
