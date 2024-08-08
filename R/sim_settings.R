#simulation set-up
library(dplyr)

test_setting <- expand.grid(N_sample = c(7),
                            N_sim = c(5),
                       M = c(1, 5, 10),
                       p_miss = c(0.1))

test_setting <- test_setting |>
    dplyr::mutate(set_n = seq(1, length(test_setting$N_sample), 1))

saveRDS(test_setting, 'sim-settings/test_setting.rds')

setting <- expand.grid(N_sample = c(7, 10, 15),
                       N_sim = c(100),
                       p_miss = c(0.1, 0.5, 0.5))

setting <- setting |>
    dplyr::mutate(set_n = seq(1, length(setting$N_sample), 1),
                  M = p_miss * 100)

saveRDS(setting, 'sim-settings/setting.rds')

