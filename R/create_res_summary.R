simsum_plots <- function(res_sum, var, true_val) {
    s0 <- res_sum[which(res_sum$term == var),]

    # s0 |> print(n = 24)

    s0 <- s0 |>
        simsum(estvarname = "mean", se = "sd", true = true_val, df = "df",
               methodvar = "method", ref = "complete",
               by = c("set_n"), x = TRUE)

    smry_0 <- summary(s0)

    p0 <- autoplot(s0, type = "est_ridge") +
        labs(title = var)
    p1 <- autoplot(smry_0, type = "lolly", "bias") +
        labs(title = var)
    p2 <- autoplot(smry_0, type = "lolly", "cover") +
        labs(title = var)
    p3 <- autoplot(smry_0, type = "lolly", "becover") +
        labs(title = var)

    p4 <- cowplot::plot_grid(p0, p1, p2, p3, nrow = 2)
    return(list(summary = smry_0,
                p_bias = p1,
                p_cov = p2,
                p_becov = p3,
                p_grid = p4))
}

create_res_sum <- function(ll, load_rds = FALSE, file_prefix = "sim-results_", file_suffix = ".csv", in_dir = "sim-results", out_dir = "sim-summary") {
    res_sum <-
        map_df(ll,
               .f = function(sc) {
                   x1 <- readr::read_csv(file.path(in_dir, paste0(file_prefix, sc, file_suffix)))


                   x1 |>
                       group_by(method, variable) |>
                       mutate(
                           term = case_when(
                               variable == "beta0" ~ "intercept",
                               variable == "beta[1]" ~ "X",
                               variable == "beta[2]" ~ "cos_theta",
                               variable == "beta[3]" ~ "sin_theta",
                               TRUE ~ variable
                           ),
                           df = 1e6,
                           lb95 = q2.5,
                           ub95 = q97.5,
                           cov = case_when(
                               lb95 > par_val ~ 0,
                               ub95 < par_val ~ 0,
                               TRUE ~ 1
                           )
                       ) |>
                       # summarize(
                       #     n_sim = n(),
                       #     true_val = mean(par_val),
                       #     mean_est = mean(estimate),
                       #     mean_se = mean(se),
                       #     avg_bias = mean(estimate - par_val),
                       #     mse = mean((estimate - par_val)^2),
                       #     mad = mean(abs(estimate - par_val)),
                       #     ci_cov = mean(cov),
                       #     ci_width = mean(moe*2)
                       # ) |>
                   mutate(
                       set_n = sc
                   ) |>
                       left_join(setting, by = "set_n") |>
                       slice_head(n = 5)

               })

    res_sum |>
        group_by(set_n, method, term) |>
        summarize(
            n_sim = n()
        ) |>
        filter(term == "intercept") |>
        print(n = 30)
    # res_sum |>
    #     print(n = 30)
    f_out <- paste0("sum_", file_prefix)
    print(file.path(out_dir, f_out))
    # saveRDS(res_sum, file = file.path(out_dir, paste0(f_out, ".rds")))
    # readr::write_csv(res_sum, file = file.path(out_dir, paste0(f_out, ".csv")))

    beta0 <- simsum_plots(res_sum, var = "intercept", true_val = 5)
    beta1 <- simsum_plots(res_sum, var = "X", true_val = 1)
    beta2 <- simsum_plots(res_sum, var = "cos_theta", true_val = 0.5)
    beta3 <- simsum_plots(res_sum, var = "sin_theta", true_val = -0.25)
    sigma <- simsum_plots(res_sum, var = "sigma", true_val = 0.5)
    alpha <- simsum_plots(res_sum, var = "alpha", true_val = 0.1)
    rho <- simsum_plots(res_sum, var = "rho", true_val = 0.65)

    return(list(beta0 = beta0,
                beta1 = beta1,
                beta2 = beta2,
                beta3 = beta3,
                sigma = sigma,
                alpha = alpha,
                rho = rho))
}



