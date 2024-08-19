
#' Spatial Multiple Imputation Simulation
#'
#' @param N_sim int Number of simulation iterations to run.
#' @param N_sample int N for an NxN grid of sites. Total sites is N^2.
#' @param init_seed int Initial seed for the PRNG
#' @param M int M Number of imputations
#' @param methods character vector of imputation methods.
#' @param pop_pars list of population parameters for the DGP
#' @param miss_pars list of missingness mechanism parameters.
#'
#' @return List of resutls data frames
#' @export
#'
#' @examples
#'
simulation <- function(N_sim, N_sample, init_seed, M, methods, pop_pars, miss_pars, f_out, mc.cores = 20) {
    sim_data <- read.csv(paste0("data/simulated_data_mar_n_", N_sample, ".csv"), header = TRUE)

    x1 <- parallel::mclapply(1:N_sim,
                             mc.cores = mc.cores,
                             function(x) {
    # x1 <- lapply(1:N_sim, function(x) {
        print(paste0("Iteration ", x, "; Generating data"))

        inc_data <- sim_data |>
            dplyr::filter(.id == x)
        prop_miss <- apply(as.matrix(inc_data[,c(4:6)]), 2, function(i) {mean(is.na(i))})

        iter_res <- lapply(methods, function(mtd) {
            if (mtd == "complete") {
                print(paste0("Iteration ", x, "; Complete Data Geostat Analysis"))
                sample_data <- inc_data |>
                    dplyr::mutate(
                        theta = theta_obs,
                        U1 = cos(theta_obs),
                        U2 = sin(theta_obs)
                    )
                res <- geostat_analysis(sample_data)
            }
            else if (mtd %in% c("pmm", "pnregid", "mean", "norm")) {
                print(paste0("Iteration ", x, "; Imputing with: ", mtd))
                imp_data <- impute(inc_data, method = mtd, M = M, maxit = 1, mc.cores = mc.cores)
                print(paste0("Iteration ", x, "; Geostat Analysis"))

                res <- geostat_analysis_imp(imp_data, mc.cores = mc.cores)
            }
            else if (mtd == "pgpreginc") {
                print(paste0("Iteration ", x, "; Imputing with: ", mtd))
                imp_data <- impute(inc_data, method = mtd, M = M, maxit = 1, mc.cores = mc.cores)
                print(paste0("Iteration ", x, "; Geostat Analysis"))

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

    return(x1)
}
