# description -------------------------------------------------------------



# r packages --------------------------------------------------------------

library(tabulizer)
library(dplyr)
library(tidyr)

# pdf path ---------------------------------------------------------------

basisghana_pdf <- "data-raw/ODF_Communities_-September_2017_1 (2).pdf"

# page 01 ----------------------------------------------------------------

# define area to extract data from. only use columns starting from
# "area council"
df01 <- extract_tables(basisghana_pdf,
                       pages = 1,
                       guess = FALSE,
                       # (top, left, bottom,right)
                       area = list(c(120, 200, 400, 800))) |>
  as.data.frame() |>
  # add a running id to enable a join later on
  mutate(no = seq(1:n())) |>
  relocate(no) |>
  as_tibble() |>
  mutate(across(X4:X8, as.numeric))

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




# export final dataframe --------------------------------------------------

basisghana <- page01

usethis::use_data(basisghana, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(basisghana, here::here("inst", "extdata", "basisghana.csv"))
openxlsx::write.xlsx(basisghana, here::here("inst", "extdata", "basisghana.xlsx"))
