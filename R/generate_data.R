generate_data <- function(N_sample, population_parameters) {

    df_x <- pnregstan::gp_geostat_sim_data(N_sample, N_sample,
                                           sigma = 0.5, rho = 3, alpha = 2,
                                           show_messages = FALSE,
                                           show_exceptions = FALSE)

    loc <- df_x[,c("long", "lat")]
    X <- as.matrix(df_x$X, ncol = 1)
    rho <- population_parameters$rho
    B <- matrix(population_parameters$B_vec, ncol = 2, byrow = TRUE)
    mu0 <- population_parameters$mu0
    sigma_w <- population_parameters$sigma_w
    rho_w <- population_parameters$rho_w

    df <- pnregstan::pgp_geostat_reg_sim_data(
        loc = loc, X = X,
        sigma_w = sigma_w, rho_w = rho_w, rho = rho,
        mu0 = mu0, B = B,
        refresh = 0,
        show_messages = FALSE,
        show_exceptions = FALSE
    )
    df$U1 <- cos(df$theta)
    df$U2 <- sin(df$theta)

    beta_y <- population_parameters$beta_y
    sigma_y <- population_parameters$sigma_y
    rho_y <- population_parameters$rho_y
    alpha_y <- population_parameters$alpha_y

    mu_y <- beta_y[1] + as.matrix(df[,c("X", "U1", "U2")]) %*% beta_y[2:4]
    df_y <- pnregstan::gp_geostat_sim_data(N_sample, N_sample,
                                           sigma = sigma_y, rho = rho_y, alpha = alpha_y,
                                           refresh = 0,
                                           show_messages = FALSE,
                                           show_exceptions = FALSE)
    df_y$X <- df_y$X + mu_y

    df$Y <- df_y$X[,1]

    return(df)
}

impose_missingness <- function(df, freq = c(1), mech = "MAR", p_miss = 0.5) {
    # mads_df <- mice::ampute(data = df)
    #
    # amp_p <- mads_df$patterns[1,]
    # amp_p[1, c(1, 5, 6)] <- 0
    #
    # amp_w <- mads_df$weights[1,]
    # amp_w[1, c(1, 5,6)] <- 0
    #
    # mads_df1 <- mice::ampute(data = df, patterns = amp_p, prop = p_miss,
    #                    weights = amp_w, freq = freq, mech = mech, type = "RIGHT")

    col_means <- apply(df, 2, mean)
    alpha <- c(0,0,0,-0.5,0,0,2)
    alpha0 <- (-t(alpha) %*% col_means - log(1/p_miss - 1))[1,1]

    alpha_vec <- alpha0 + as.matrix(df) %*% alpha

    p_miss_vec <- boot::inv.logit(alpha_vec)

    miss_ind <- sample(1:nrow(df), prob = p_miss_vec, replace = FALSE, size = ceiling(p_miss * nrow(df)))

    amp <- df

    amp[miss_ind, c("theta", "U1", "U2")] <- NA

    return(amp)
}

