# description -------------------------------------------------------------



# r packages --------------------------------------------------------------

library(tabulizer)
library(dplyr)
library(tidyr)

# helper functions --------------------------------------------------------

extract_tables_typ1 <- function(data, pages) {
  extract_tables(data,
                 pages = pages,
                 guess = FALSE,
                 # (top, left, bottom,right)
                 area = list(c(120, 200, 400, 800))) |>
    as.data.frame() |>
    # add a running id to enable a join later on
    mutate(no = seq(1:n())) |>
    relocate(no) |>
    as_tibble() |>
    mutate(across(X4:X8, as.numeric))
}

extract_tables_typ2 <- function(data, pages, vec_area1, vec_area2) {

  sequence <- seq_along(pages)[-length(seq_along(pages))]

  list_data <- extract_tables(data,
                              pages = pages,
                              guess = FALSE,
                              # (top, left, bottom, right)
                              area = c(
                                list(vec_area1),
                                lapply(sequence,
                                       function(x) vec_area2)
                              ))
  lapply(list_data, as.data.frame)


}

format_df <- function(data) {
  do.call(rbind, data) |>
    mutate(no = seq(1:n())) |>
    relocate(no) |>
    as_tibble() |>
    mutate(across(V4:V8, as.numeric))
}

extract_tables_district <- function(data, pages, vec_area1, vec_area2) {

  sequence <- seq_along(pages)[-length(seq_along(pages))]

  list_data <- extract_tables(data,
                              pages = pages,
                              guess = FALSE,
                              # (top,left,bottom,right)
                              area = c(
                                list(vec_area1),
                                lapply(sequence,
                                       function(x) vec_area2)
                              ))


  district_df <- lapply(list_data, as.data.frame)
  district_df <- do.call(rbind, district_df)

  district_df |>
    as_tibble() |>
    mutate(no = stringr::str_split(V1, "\\s", n = 2)) |>
    unnest_wider(col = no, names_sep = "_") |>
    select(no = no_1, district = no_2) |>
    fill(district, .direction = "down") |>
    mutate(no = as.numeric(no))

}


# pdf path ---------------------------------------------------------------

basisghana_pdf <- "data-raw/ODF_Communities_-September_2017_1 (2).pdf"

# page 01 ----------------------------------------------------------------

# define area to extract data from. only use columns starting from
# "area council"
df01 <- extract_tables_typ1(basisghana_pdf, pages = 1)

# define column names
col_names <- c("no","area_council", "partner", "community_name", "population", "households", "toilets", "hwf", "odfs")

names(df01) <- col_names

# define area to extract data from. only use columns No. and District
m01_district <- extract_tables(basisghana_pdf,
                               pages = 1,
                               guess = FALSE,
                               # (top,left,bottom,right)
                               area = list(c(100, 0, 400, 200)))

# add colnames
colnames(m01_district[[1]]) <- "no. districts"

# wrangle data get a complete dataframe for no. and district
df01_district <- m01_district |>
  as.data.frame() |>
  as_tibble() |>
  slice(-1) |>
  mutate(no = stringr::str_split(no..districts, "\\s", n = 2)) |>
  unnest_wider(col = no, names_sep = "_") |>
  select(no = no_1, district = no_2) |>
  fill(district, .direction = "down") |>
  mutate(no = as.numeric(no))

# join the no and district with data
page01 <- df01_district |>
  left_join(df01)


# page 02 to page 06 -----------------------------------------------------------

vector_area0206 <- c(50, 90, 600, 1000)

m0206_list <- extract_tables(basisghana_pdf,
                             pages = 2:6,
                             guess = FALSE,
                             # (top, left, bottom, right)
                             area = c(
                               list(c(110, 100, 600, 1000)),
                               lapply(1:4, function(x) vector_area0206)
                             ))

m0206_df <- lapply(m0206_list, as.data.frame)

m0206_df[[4]] <- m0206_df[[4]] |>
  mutate(V8 = NA_character_)

df0206 <- format_df(m0206_df)

# define column names
names(df0206) <- col_names

# define area to extract data from. only use columns No. and District

m0206_district <- extract_tables(basisghana_pdf,
                                 pages = 2:6,
                                 guess = FALSE,
                                 # (top,left,bottom,right)
                                 area = list(c(100, 0, 400, 100)))


m0206_district_df <- lapply(m0206_district, as.data.frame)
m0206_district_df <- do.call(rbind, m0206_district_df)

# wrangle data get a complete dataframe for no. and district

df0206_district <- m0206_district_df |>
  as_tibble() |>
  mutate(no = stringr::str_split(V1, "\\s", n = 2)) |>
  unnest_wider(col = no, names_sep = "_") |>
  select(no = no_1, district = no_2) |>
  fill(district, .direction = "down") |>
  mutate(no = as.numeric(no))

page0206 <- df0206_district |>
  left_join(df0206)


# page 07 -----------------------------------------------------------------

## Note: page 7 is identical to page 1. Do not include again.
## extract_tables_typ1(basisghana_pdf, pages = 7)


# page 08 to page 13 ------------------------------------------------------

m0813_df <- extract_tables_typ2(data = basisghana_pdf,
                                pages = 8:13,
                                vec_area1 = c(100, 140, 600, 1000),
                                vec_area2 = c(50, 170, 600, 1000))


m0813_df[[6]] <- m0813_df[[6]] |>
  mutate(V8 = NA_character_)

df0813 <- format_df(data = m0813_df)

# define column names
names(df0813) <- col_names


# extract district names

df0813_district <- extract_tables_district(data = basisghana_pdf,
                        pages = 8:13,
                        vec_area1 = c(100, 0, 800, 180),
                        vec_area2 = c(50, 0, 800, 180))


page0813 <- df0813_district |>
  left_join(df0813)

# export final dataframe --------------------------------------------------

basisghana <- bind_rows(page01,
                        page0206,
                        page0813)

usethis::use_data(basisghana, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(basisghana, here::here("inst", "extdata", "basisghana.csv"))
openxlsx::write.xlsx(basisghana, here::here("inst", "extdata", "basisghana.xlsx"))
