

library(tabulizer)
library(dplyr)
library(tidyr)

basisghana_pdf <- "data-raw/ODF_Communities_-September_2017_1 (2).pdf"

extract_tables(basisghana_pdf,
               pages = 1,
               guess = FALSE,
               columns = list(c(4, 5, 6, 7, 8, 9)))

df01 <- extract_tables(basisghana_pdf,
                       pages = 1,
                       guess = FALSE,
                       area = list(c(120, 200, 400, 800))) |>  # (top,left,bottom,right)
  as.data.frame() |>
  mutate(no = seq(1:n())) |>
  relocate(no) |>
  as_tibble() |>
  mutate(across(X4:X8, as.numeric))

names(df01) <- c("no","area_council", "partner", "community_name", "population", "households", "toilets", "hwf", "odfs")

m01_district <- extract_tables(basisghana_pdf,
                               pages = 1,
                               guess = FALSE,
                               area = list(c(100, 0, 400, 200)))     # (top,left,bottom,right)


colnames(m01_district[[1]]) <- paste0("no. districts")

df01_district <- m01_district |>
  as.data.frame() |>
  as_tibble() |>
  slice(-1) |>
  mutate(no = stringr::str_split(no..districts, "\\s", n = 2)) |>
  unnest_wider(col = no, names_sep = "_") |>
  select(no = no_1, district = no_2) |>
  fill(district, .direction = "down") |>
  mutate(no = as.numeric(no))

page01 <- df01_district |>
  left_join(df01)

basisghana <- page01

## code to prepare `DATASET` dataset goes here

usethis::use_data(basisghana, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(basisghana, here::here("inst", "extdata", "basisghana.csv"))
openxlsx::write.xlsx(basisghana, here::here("inst", "extdata", "basisghana.xlsx"))
