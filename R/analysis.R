lm_analysis <- function(imp_data) {
    fit <- with(imp_data, lm(Y ~ X + U1 + U2))

    if (mice::is.mira(fit)) {
        res_pool <- mice::pool(fit)
        res2 <- res_pool$pooled
        res2$se <- sqrt(res2$t)
        res2$q025 <- res2$mean - qt(0.025, res2$df) * res2$se
        res2$q975 <- res2$mean + qt(0.975, res2$df) * res2$se
        return(res2)
    }
    else if (class(fit) == "lm") {
        smry <- summary(fit)

        res <- as.data.frame(smry$coefficients)
        colnames(res) <- c("estimate", "se", "t_val", "p_val")
        res$term <- rownames(res)
        res$df <- nrow(imp_data) - 5
        rownames(res) <- 1:nrow(res)
        return(res)
    }
}

geostat_analysis <- function(df) {


    loc <- as.matrix(df[,c("long", "lat")])

    loc2 <- pnregstan::create_grid_df(2, 2)

    invisible(capture.output(fit <- pnregstan::fit_gp_geostat_reg_model(loc1 = loc,
                                               loc2 = loc2,
                                               Y = df$Y,
                                               X = as.matrix(df[,c("X", "U1", "U2")]),
                                               refresh = 0,
                                               show_messages = FALSE,
                                               show_exceptions = FALSE,
                                               adapt_delta = 0.85,
                                               chains = 2)))

    draws_df <- fit$draws(variables = c("beta0", "beta", "sigma", "alpha", "rho")) |>
        posterior::as_draws_df()

    smry <- draws_df |>
        posterior::summarize_draws(mean, median, sd, mad,
                                   ~posterior::quantile2(.x, probs = c(0.025, 0.975), names = TRUE),
                                   posterior::default_convergence_measures())

    return(smry)
}

geostat_analysis_imp <- function(imps, mc.cores = 20) {
    imps <- mice::complete(imps, "all", include = FALSE)
    M <- length(imps)

    fits <- lapply(1:M, function(m) {

        df <- imps[[m]]

        loc <- as.matrix(df[,c("long", "lat")])

        loc2 <- pnregstan::create_grid_df(2, 2)

        invisible(capture.output(fit <- pnregstan::fit_gp_geostat_reg_model(loc1 = loc,
                                                   loc2 = loc2,
                                                   Y = df$Y,
                                                   X = as.matrix(df[,c("X", "U1", "U2")]),
                                                   refresh = 0,
                                                   show_messages = FALSE,
                                                   show_exceptions = FALSE,
                                                   adapt_delta = 0.85,
                                                   chains = 2)))

        draws_df <- fit$draws(variables = c("beta0", "beta", "sigma", "alpha", "rho")) |>
            posterior::as_draws_df()

        draws_df$.imp <- m

        return(draws_df)
    })

    smry <- fits |>
        dplyr::bind_rows() |>
        dplyr::select(-.imp) |>
        posterior::summarize_draws(mean, median, sd, mad,
                                   ~posterior::quantile2(.x, probs = c(0.025, 0.975), names = TRUE),
                                   posterior::default_convergence_measures())

    return(smry)
}
