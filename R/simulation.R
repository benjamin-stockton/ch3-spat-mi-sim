
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
simulation <- function(N_sim, N_sample, init_seed, M, methods, pop_pars, miss_pars, mc.cores = 20) {
    x1 <- parallel::mclapply(1:N_sim,
                             mc.cores = mc.cores,
                             function(x) {
    # x1 <- lapply(1:1, function(x) {
        print(x)
        # print("Generating data")
        sample_data <- generate_data(N_sample, pop_pars)

        inc_data <- impose_missingness(sample_data,
                                       freq = miss_pars$freq,
                                       mech = miss_pars$mech,
                                       p_miss = miss_pars$p_miss)
        prop_miss <- apply(as.matrix(inc_data[,c(4:6)]), 2, function(i) {mean(is.na(i))})

        iter_res <- lapply(methods, function(mtd) {
            if (mtd == "complete") {
                # print("Complete Data Geostat Analysis")
                res <- geostat_analysis(sample_data)
            }
            else if (mtd == "pmm" || mtd == "pnregid") {
                # print(paste0("Imputing with: ", mtd))
                imp_data <- impute(inc_data, method = mtd, M = M, maxit = 1)
                # print("Geostat Analysis")

                res <- geostat_analysis_imp(imp_data)
            }
            else if (mtd == "pgpreginc") {
                # print(paste0("Imputing with: ", mtd))
                imp_data <- impute(inc_data, method = mtd, M = M, maxit = 1)
                # print("Geostat Analysis")

                res <- geostat_analysis_imp(imp_data)
            }

            res$par_val <- c(pop_pars$beta_y, pop_pars$sigma_y,
                             pop_pars$alpha_y, pop_pars$rho_y)
            res$p_miss <- c(0, prop_miss, 0,0,0)
            res$iter <- x
            res$method <- mtd
            return(res)
        })

        iter_res |>
            dplyr::bind_rows() -> results

        return(results)
    })

    return(x1)
}
