# description -------------------------------------------------------------



# r packages --------------------------------------------------------------

library(tabulizer)
library(dplyr)
library(tidyr)

# helper functions --------------------------------------------------------

extract_tables_typ1 <- function(data,
                                pages,
                                vec_area = c(120, 200, 400, 800)) {
  extract_tables(data,
                 pages = pages,
                 guess = FALSE,
                 # (top, left, bottom,right)
                 area = list(vec_area)) |>
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


extract_tables_typ3 <- function(data,
                                pages,
                                vec_area) {
  extract_tables(data,
                 pages = pages,
                 guess = FALSE,
                 # (top, left, bottom,right)
                 area = list(vec_area)) |>
    as.data.frame() |>
    # add a running id to enable a join later on
    mutate(no = seq(1:n())) |>
    relocate(no) |>
    as_tibble() |>
    mutate(across(X4:X7, as.numeric)) |>
    mutate(V8 = NA_integer_)
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


# pages 14 to 20 ----------------------------------------------------------

m1420_df <- extract_tables_typ2(data = basisghana_pdf,
                    pages = 14:20,
                    # (top, left, bottom, right)
                    vec_area1 = c(100, 180, 600, 1000),
                    vec_area2 = c(50, 170, 600, 1000))

m1420_df[[6]] <- m1420_df[[6]] |>
  mutate(V8 = NA_character_)

m1420_df[[7]] <- m1420_df[[7]] |>
  mutate(V8 = NA_character_)

df1420 <- format_df(data = m1420_df)

# define column names
names(df1420) <- col_names

# page 21 -----------------------------------------------------------------
## this page is part of pages 14 to 20, but has a different structure so
## it's extracted individually

df21_1 <- extract_tables(basisghana_pdf, pages = 21,
                         # (top, left, bottom, right)
               area = list(c(50, 200, 190, 1000))) |>
  as.data.frame() |>
  # add a running id to enable a join later on
  mutate(no = seq(1:n())) |>
  relocate(no) |>
  as_tibble() |>
  mutate(across(X4:X8, as.numeric))

names(df21_1) <- col_names

df21_2 <- extract_tables_typ1(basisghana_pdf,
                    pages = 21,
                    vec_area = c(180, 200, 450, 1000))

names(df21_2) <- col_names

df21 <- bind_rows(df21_1, df21_2) |>
  mutate(no = 208:232)


# bind 14 to 20 & 21 ------------------------------------------------------

df1421 <- df1420 |> bind_rows(df21)

# extract district names

df1421_district <- extract_tables_district(data = basisghana_pdf,
                                           pages = 14:21,
                                           vec_area1 = c(100, 0, 800, 180),
                                           vec_area2 = c(50, 0, 800, 180))


page1421 <- df1421_district |>
  left_join(df1421)


# page 22 to page 54 ------------------------------------------------------

## page 22 separate because 23 is a mess

df22 <- extract_tables_typ1(data = basisghana_pdf,
                    pages = 22, vec_area = c(110, 160, 600, 1000))

names(df22) <- col_names

## page 23 which has three individual formats

df23_1 <- extract_tables_typ1(basisghana_pdf,
                    pages = 23,
                    vec_area = c(50, 150, 220, 1000)) |>
  filter(no != 11)


df23_2 <- extract_tables_typ1(basisghana_pdf,
                    pages = 23,
                    vec_area = c(210, 150, 480, 1000))



df23_3 <- extract_tables_typ1(basisghana_pdf,
                    pages = 23,
                    vec_area = c(470, 150, 800, 1000))


df23 <- bind_rows(df23_1, df23_2, df23_3) |>
  mutate(no = 28:58)

names(df23) <- col_names

## page 24 with three formats

df24_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 24,
                              vec_area = c(50, 150, 360, 1000))

df24_2 <- extract_tables(basisghana_pdf,
               pages = 24,
               area = list(c(350, 150, 500, 1000))) |>
  as.data.frame() |>
  # add a running id to enable a join later on
  mutate(no = seq(1:n())) |>
  relocate(no) |>
  as_tibble() |>
  mutate(across(X4:X8, as.numeric))


df24_3 <- extract_tables_typ1(basisghana_pdf,
                    pages = 24,
                    vec_area = c(480, 150, 700, 1000))


df24 <- bind_rows(df24_1, df24_2, df24_3) |>
  mutate(no = 59:89)

names(df24) <- col_names

## page 25

df25 <- extract_tables_typ3(basisghana_pdf,
                            pages = 25,
                            vec_area = c(50, 150, 700, 1000))

names(df25) <- col_names

## page 26

df26_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 26,
                              vec_area = c(50, 150, 250, 1000))


df26_2 <- extract_tables_typ3(basisghana_pdf,
                    pages = 26,
                    vec_area = c(240, 150, 520, 1000))


df26_3 <- extract_tables_typ1(basisghana_pdf,
               pages = 26,
               vec_area = c(520, 150, 550, 1000)) |>
  rename(V8 = X8)

df26 <- bind_rows(df26_1, df26_2, df26_3) |>
  mutate(no = 123:155)

names(df26) <- col_names

## page 27

df27 <- extract_tables_typ1(basisghana_pdf,
               pages = 27,
               vec_area = c(50, 150, 700, 1000)) |>
  mutate(no = 156:186)


names(df27) <- col_names

## page 28

df28_1 <- extract_tables_typ3(basisghana_pdf,
                      pages = 28,
                      vec_area = c(50, 150, 250, 1000))

df28_2 <- extract_tables_typ3(basisghana_pdf,
                    pages = 28,
                    vec_area = c(240, 150, 340, 1000))



df28_3 <- extract_tables_typ1(basisghana_pdf,
               pages = 28,
               vec_area = c(330, 150, 600, 1000)) |>
  rename(V8 = X8)

df28 <- bind_rows(df28_1, df28_2, df28_3) |>
  mutate(no = 187:217)

names(df28) <- col_names

## page 29

df29 <- extract_tables_typ3(basisghana_pdf,
                      pages = 29,
                      vec_area = c(50, 150, 600, 1000))



names(df29) <- col_names

## page 30

df30_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 30,
                              vec_area = c(50, 150, 400, 1000))


df30_2 <- extract_tables_typ3(basisghana_pdf,
                      pages = 30,
                      vec_area = c(390, 150, 600, 1000))

df30 <- bind_rows(df30_1, df30_2) |>
  mutate(no = 248:277)

names(df30) <- col_names

## page 31

df31 <- extract_tables_typ1(basisghana_pdf,
                    pages = 31,
                    vec_area = c(50, 150, 700, 1000))

names(df31) <- col_names

## page 32

df32 <- extract_tables_typ3(basisghana_pdf,
                            pages = 32,
                            vec_area = c(50, 150, 700, 1000))

names(df32) <- col_names


# pages 22 to 54 ----------------------------------------------------------

bind_rows(df22,
          df23,
          df24,
          df25,
          df26,
          df27,
          df28,
          df29,
          df30,
          df31,
          df32)

# export final dataframe --------------------------------------------------

basisghana <- bind_rows(page01,
                        page0206,
                        page0813,
                        page1421)

usethis::use_data(basisghana, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(basisghana, here::here("inst", "extdata", "basisghana.csv"))
openxlsx::write.xlsx(basisghana, here::here("inst", "extdata", "basisghana.xlsx"))
