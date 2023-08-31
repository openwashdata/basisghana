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
  left_join(df01) |>
  mutate(region = "Central Region") |>
  relocate(region, .after = no)



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

vector_area0206_district <- c(50, 0, 600, 120)

m0206_district <- extract_tables(basisghana_pdf,
                                 pages = 2:6,
                                 guess = FALSE,
                                 # (top, left, bottom, right)
                                 area = c(
                                   list(c(100, 0, 600, 100)),
                                   lapply(1:4, function(x) vector_area0206_district)
                                 ))

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
  left_join(df0206) |>
  mutate(region = "Volta Region") |>
  relocate(region, .after = no)


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
  left_join(df0813) |>
  mutate(region = "Upper East Region") |>
  relocate(region, .after = no)


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

df1421 <- df1420 |>
  bind_rows(df21)

# extract district names

df1421_district <- extract_tables_district(data = basisghana_pdf,
                                           pages = 14:21,
                                           vec_area1 = c(100, 0, 800, 180),
                                           vec_area2 = c(50, 0, 800, 180))


page1421 <- df1421_district |>
  left_join(df1421) |>
  mutate(region = "Upper West Region") |>
  relocate(region, .after = no)


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
  mutate(no = 59:89) |>
  select(-V8)

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

## page 33


df33_1 <- extract_tables(basisghana_pdf,
                         pages = 33,
                         guess = FALSE,
                         area = list(c(50, 100, 90, 1000))) |>
  as.data.frame() |>
  # add a running id to enable a join later on
  mutate(no = seq(1:n())) |>
  relocate(no) |>
  as_tibble() |>
  mutate(X0 = NA_character_,
         X8 = NA_character_) |>
  relocate(X0, .after = no) |>
  mutate(across(X3:X8, as.numeric))

names(df33_1) <- col_names


df33_2 <- extract_tables_typ3(basisghana_pdf,
                              pages = 33,
                              # (top, left, bottom,right)
                              vec_area = c(90, 150, 700, 1000))

names(df33_2) <- col_names

df33 <- bind_rows(df33_1, df33_2) |>
  mutate(no = 340:370)

## page 34

df34 <- extract_tables_typ1(basisghana_pdf,
                            pages = 34,
                            # (top, left, bottom,right)
                            vec_area = c(50, 150, 700, 1000))

names(df34) <- col_names

## page 35

df35_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 35,
                              # (top, left, bottom,right)
                              vec_area = c(50, 150, 300, 1000))


df35_2 <- extract_tables_typ3(basisghana_pdf,
                              pages = 35,
                              # (top, left, bottom,right)
                              vec_area = c(300, 150, 700, 1000))

df35 <- bind_rows(df35_1, df35_2) |>
  mutate(no = 402:432)

names(df35) <- col_names

## page 36

df36_1 <- extract_tables(basisghana_pdf,
                         pages = 36,
                         guess = FALSE,
                         area = list(c(50, 100, 90, 1000))) |>
  as.data.frame() |>
  # add a running id to enable a join later on
  mutate(no = seq(1:n())) |>
  relocate(no) |>
  as_tibble() |>
  mutate(X8 = NA_character_) |>
  mutate(across(X4:X8, as.numeric))

names(df36_1) <- col_names

df36_2 <- extract_tables_typ1(basisghana_pdf,
                              pages = 36,
                              # (top, left, bottom,right)
                              vec_area = c(80, 150, 200, 1000))

names(df36_2) <- col_names

df36_3 <- extract_tables_typ3(basisghana_pdf,
                              pages = 36,
                              # (top, left, bottom,right)
                              vec_area = c(190, 150, 700, 1000))

names(df36_3) <- col_names

df36 <- bind_rows(df36_1, df36_2, df36_3) |>
  mutate(no = 433:463)


## page 37

df37_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 37,
                              # (top, left, bottom,right)
                              vec_area = c(50, 150, 250, 1000))

names(df37_1) <- col_names

df37_2 <- extract_tables_typ1(basisghana_pdf,
                              pages = 37,
                              # (top, left, bottom,right)
                              vec_area = c(240, 150, 460, 1000))


names(df37_2) <- col_names

df37_3 <- extract_tables_typ3(basisghana_pdf,
                              pages = 37,
                              # (top, left, bottom,right)
                              vec_area = c(460, 150, 600, 1000))


names(df37_3) <- col_names

df37 <- bind_rows(df37_1, df37_2, df37_3) |>
  mutate(no = 464:494)


## page 38

df38_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 38,
                              # (top, left, bottom,right)
                              vec_area = c(50, 150, 160, 1000))

names(df38_1) <- col_names

df38_2 <- extract_tables_typ1(basisghana_pdf,
                              pages = 38,
                              # (top, left, bottom,right)
                              vec_area = c(160, 150, 480, 1000))

names(df38_2) <- col_names


df38_3 <- extract_tables_typ3(basisghana_pdf,
                              pages = 38,
                              # (top, left, bottom,right)
                              vec_area = c(470, 150, 700, 1000))

names(df38_3) <- col_names

df38 <- bind_rows(df38_1, df38_2, df38_3) |>
  mutate(no = 495:525)

## pages 39 to 40

df3940_list <- extract_tables_typ2(data = basisghana_pdf,
                                   pages = 39:40,
                                   vec_area1 = c(50, 140, 600, 1000),
                                   vec_area2 = c(50, 170, 600, 1000))


df3940_list[[1]] <- df3940_list[[1]] |>
  mutate(V8 = NA_character_)

df3940_list[[2]] <- df3940_list[[2]] |>
  mutate(V8 = NA_character_)


df3940 <- format_df(data = df3940_list) |>
  mutate(no = 526:587)

names(df3940) <- col_names

## page 41

df41_1 <- extract_tables_typ1(basisghana_pdf,
                              pages = 41,
                              # (top, left, bottom,right)
                              vec_area = c(50, 150, 200, 800)) |>
  select(-X4) |>
  mutate(X9 = NA_integer_)

names(df41_1) <- col_names

df41_2 <- extract_tables_typ1(basisghana_pdf,
                              pages = 41,
                              # (top, left, bottom,right)
                              vec_area = c(190, 150, 700, 1000))

names(df41_2) <- col_names

df41 <- bind_rows(df41_1, df41_2) |>
  mutate(no = 588:618)

## page 42

df42_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 42,
                              # (top, left, bottom,right)
                              vec_area = c(50, 150, 120, 1000))

names(df42_1) <- col_names

df42_2 <- extract_tables_typ3(basisghana_pdf,
                              pages = 42,
                              # (top, left, bottom,right)
                              vec_area = c(120, 150, 600, 1000))

names(df42_2) <- col_names

df42 <- bind_rows(df42_1, df42_2) |>
  mutate(no = 619:649)

## page 43

df43_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 43,
                              # (top, left, bottom,right)
                              vec_area = c(50, 150, 250, 1000))

names(df43_1) <- col_names

df43_2 <- extract_tables_typ1(basisghana_pdf,
                              pages = 43,
                              # (top, left, bottom,right)
                              vec_area = c(240, 160, 370, 1000))

names(df43_2) <- col_names

df43_3 <- extract_tables_typ3(basisghana_pdf,
                              pages = 43,
                              # (top, left, bottom,right)
                              vec_area = c(360, 160, 430, 1000))

names(df43_3) <- col_names

df43_4 <- extract_tables_typ1(basisghana_pdf,
                              pages = 43,
                              # (top, left, bottom,right)
                              vec_area = c(430, 160, 600, 1000))

names(df43_4) <- col_names

df43 <- bind_rows(df43_1, df43_2, df43_3, df43_4) |>
  mutate(no = 650:680)

## page 44

df44 <- extract_tables_typ3(basisghana_pdf,
                            pages = 44,
                            # (top, left, bottom,right)
                            vec_area = c(50, 160, 600, 1000)) |>
  mutate(no = 681:711)

names(df44) <- col_names

## page 45

df45_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 45,
                              # (top, left, bottom,right)
                              vec_area = c(50, 150, 120, 1000))

names(df45_1) <- col_names


df45_2 <- extract_tables_typ3(basisghana_pdf,
                              pages = 45,
                              # (top, left, bottom,right)
                              vec_area = c(120, 150, 340, 1000))

names(df45_2) <- col_names


df45_3 <- extract_tables_typ1(basisghana_pdf,
                              pages = 45,
                              # (top, left, bottom,right)
                              vec_area = c(330, 150, 600, 1000))

names(df45_3) <- col_names


df45 <- bind_rows(df45_1, df45_2, df45_3) |>
  mutate(no = 712:742)

## page 46 to 48

df4648_list <- extract_tables_typ2(data = basisghana_pdf,
                                   pages = 46:48,
                                   vec_area1 = c(50, 170, 600, 1000),
                                   vec_area2 = c(50, 170, 600, 1000))


df4648_list [[2]] <- df4648_list[[2]] |>
  mutate(V8 = NA_character_)


df4648 <- format_df(data = df4648_list) |>
  mutate(no = 743:835)

names(df4648) <- col_names

## page 49

df49_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 49,
                              # (top, left, bottom,right)
                              vec_area = c(50, 150, 260, 1000))

names(df49_1) <- col_names

df49_2 <- extract_tables_typ3(basisghana_pdf,
                              pages = 49,
                              # (top, left, bottom,right)
                              vec_area = c(260, 150, 600, 1000))

names(df49_2) <- col_names


df49 <- bind_rows(df49_1, df49_2) |>
  mutate(no = 836:866)

## page 50

df50_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 50,
                              # (top, left, bottom,right)
                              vec_area = c(50, 150, 430, 1000))

names(df50_1) <- col_names

df50_2 <- extract_tables_typ1(basisghana_pdf,
                              pages = 50,
                              # (top, left, bottom,right)
                              vec_area = c(430, 150, 600, 1000))

names(df50_2) <- col_names

df50 <- bind_rows(df50_1, df50_2) |>
  mutate(no = 867:897)


## page 51

df51_1 <- extract_tables_typ1(basisghana_pdf,
                              pages = 51,
                              # (top, left, bottom,right)
                              vec_area = c(50, 160, 340, 1000))

names(df51_1) <- col_names

df51_2 <- extract_tables_typ3(basisghana_pdf,
                              pages = 51,
                              # (top, left, bottom,right)
                              vec_area = c(330, 160, 460, 1000))

names(df51_2) <- col_names


df51_3 <- extract_tables_typ1(basisghana_pdf,
                              pages = 51,
                              # (top, left, bottom,right)
                              vec_area = c(460, 160, 600, 1000))

names(df51_3) <- col_names



df51 <- bind_rows(df51_1, df51_2, df51_3) |>
  mutate(no = 898:928)

## page 52

df52_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 52,
                              # (top, left, bottom,right)
                              vec_area = c(50, 160, 230, 1000))

names(df52_1) <- col_names

df52_2 <- extract_tables_typ3(basisghana_pdf,
                              pages = 52,
                              # (top, left, bottom,right)
                              vec_area = c(220, 160, 400, 1000))

names(df52_2) <- col_names


df52_3 <- extract_tables_typ1(basisghana_pdf,
                              pages = 52,
                              # (top, left, bottom,right)
                              vec_area = c(390, 160, 600, 1000))

names(df52_3) <- col_names

df52 <- bind_rows(df52_1, df52_2, df52_3) |>
  mutate(no = 929:959)

## page 53


df53_1 <- extract_tables_typ3(basisghana_pdf,
                              pages = 53,
                              # (top, left, bottom,right)
                              vec_area = c(50, 160, 150, 1000))

names(df53_1) <- col_names


df53_2 <- extract_tables_typ3(basisghana_pdf,
                              pages = 53,
                              # (top, left, bottom,right)
                              vec_area = c(150, 160, 460, 1000))

names(df53_2) <- col_names


df53_2

extract_tables_typ1(basisghana_pdf,
                    pages = 53,
                    # (top, left, bottom,right)
                    vec_area = c(440, 160, 600, 1000))

names(df53_2) <- col_names


m53_3 <- extract_tables(basisghana_pdf,
                        pages = 53,
                        guess = FALSE,
                        # (top, left, bottom, right)
                        area = list(c(450, 100, 600, 1000)))


df53_3 <- as.data.frame(m53_3[[1]])

df53_3 <- df53_3 |>
  mutate(no = seq(1:n())) |>
  relocate(no) |>
  as_tibble() |>
  mutate(V0 = NA_character_,
         V7 = NA_integer_) |>
  relocate(V0, .after = no) |>
  mutate(across(V3:V7, as.numeric))


names(df53_3) <- col_names

df53 <- bind_rows(df53_1, df53_2, df53_3) |>
  mutate(no = 960:990)

## page 54

m54_1 <- extract_tables(basisghana_pdf,
                        pages = 54,
                        guess = FALSE,
                        # (top, left, bottom, right)
                        area = list(c(50, 100, 600, 1000)))


df54_1 <- as.data.frame(m54_1[[1]])

df54 <- df54_1 |>
  mutate(no = 991:998) |>
  relocate(no) |>
  as_tibble() |>
  mutate(V0 = NA_character_,
         V7 = NA_integer_) |>
  relocate(V0, .after = no) |>
  mutate(across(V3:V7, as.numeric))

names(df54) <- col_names


# pages 22 to 54 ----------------------------------------------------------

df2254 <- bind_rows(df22,
                    df23,
                    df24,
                    df25,
                    df26,
                    df27,
                    df28,
                    df29,
                    df30,
                    df31,
                    df32,
                    df33,
                    df34,
                    df35,
                    df36,
                    df37,
                    df38,
                    df3940,
                    df41,
                    df42,
                    df43,
                    df44,
                    df45,
                    df4648,
                    df49,
                    df50,
                    df51,
                    df52,
                    df53,
                    df54) |>
  mutate(no = seq(1:n()))

# extract district names

df2254_district <- extract_tables_district(data = basisghana_pdf,
                                           pages = 22:54,
                                           # (top, left, bottom, right)
                                           vec_area1 = c(110, 0, 800, 180),
                                           vec_area2 = c(50, 0, 800, 180))
page2254 <- df2254_district |>
  left_join(df2254) |>
  mutate(region = "Northern Region") |>
  relocate(region, .after = no)

# export final dataframe --------------------------------------------------

basisghana_complete <- bind_rows(page01,
                                 page0206,
                                 page0813,
                                 page1421,
                                 page2254)


# tests -------------------------------------------------------------------

## test 1: Manually checked that numbers for odfs column and district is equal
## values in PDF

# basisghana |>
#   select(district, odfs) |>
#   drop_na() |> View()


# split data in two resources ---------------------------------------------

odfs <- basisghana_complete |>
  select(region, district, odfs) |>
  drop_na()

# manipulation: check what empty fields are

basisghana <- basisghana_complete |>
  select(-odfs) |>
  # replace empty fields with NA -> assumption is that the area council is not
  # the same as the previous value in the table
  mutate(area_council = na_if(area_council, "")) |>
  mutate(no = as.integer(no)) |>
  rename(community = community_name,
         council = area_council) |>
  relocate(partner, .after = community)

# export data -------------------------------------------------------------

usethis::use_data(odfs, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(odfs, here::here("inst", "extdata", "odfs.csv"))
openxlsx::write.xlsx(odfs, here::here("inst", "extdata", "odfs.xlsx"))

usethis::use_data(basisghana, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(basisghana, here::here("inst", "extdata", "basisghana.csv"))
openxlsx::write.xlsx(basisghana, here::here("inst", "extdata", "basisghana.xlsx"))

