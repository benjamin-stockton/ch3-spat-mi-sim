get.seed <- function() {.Random.seed}

write_results <- function(results_list, methods, out_path) {
    for (mthd in methods) {
        out_path_1 <- file.path(out_path, paste0(out_path, "_", mthd, "_", Sys.Date(), ".csv"))
        write.csv(results_list[[mthd]], out_path_1, row.names = FALSE)
    }
}
