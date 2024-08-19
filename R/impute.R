impute <- function(data, method = "pmm", M = 3, maxit = 5, mc.cores = 20) {
    if (method %in% c("mean", "norm", "pmm", "pnregid")) {
        imp0 <- mice::mice(data, method = method, m = 1, maxit = 0)

        mthd <- imp0$method

        mthd["theta"] <- method
        mthd["U1"] <- "~cos(theta)"
        mthd["U2"] <- "~sin(theta)"

        p_mat <- imp0$predictorMatrix
        p_mat[,c("theta", "theta_obs", "long", "lat")] <- 0
        p_mat[c("U1", "U2"), ] <- 0
        p_mat[c("U1", "U2"), "theta"] <- 1
        p_mat["theta", c("U1", "U2")] <- 0
        p_mat["theta", c("X", "Y")] <- 1
        if (method == "mean") {
            invisible(capture.output(imp <- mice::mice(data, m = 1, method = mthd,
                                                       predictorMatrix = p_mat, maxit = maxit)))
        }
        else {

            invisible(capture.output(imp <- mice::mice(data, m = M, method = mthd,
                                                       predictorMatrix = p_mat, maxit = maxit)))
        }
        return(imp)
    }
    else if (method == "pgpgeotat") {

    }
    else if (method == "pgpreginc") {
        loc <- data[,c("long", "lat")]
        theta <- data$theta
        X <- as.matrix(data[,c("Y", "X")])
        # imp <- imputeangles::impute_pgpreginc(loc = loc, theta = theta, x = X, M = M, iter_warmup = 500, iter_sampling = 500)
        invisible(capture.output(imp <- imputeangles::impute_pgpreginc(loc = loc, theta = theta, x = X, M = M,
                                                 iter_warmup = 500, iter_sampling = 500, adapt_delta = 0.85)))


        data$.imp <- 0
        data$.id <- 1:nrow(data)

        imp[[M+1]] <- data

        imp_long <- imp |> dplyr::bind_rows()

        # imp_long |>
        #     dplyr::group_by(.imp) |>
        #     dplyr::summarize(
        #         n = dplyr::n()
        #     ) |> print(n = M+1)

        imp <- mice::as.mids(imp_long)

        return(imp)
    }
}
