
<!-- README.md is generated from README.Rmd. Please edit that file -->

# basisghana

<!-- badges: start -->
<!-- badges: end -->

The goal of basisghana is to …

## Installation

You can install the development version of basisghana from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("openwashdata/basisghana")
```

## Example

``` r
library(tidyverse)
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.1.2     ✔ readr     2.1.4
#> ✔ forcats   1.0.0     ✔ stringr   1.5.0
#> ✔ ggplot2   3.4.2     ✔ tibble    3.2.1
#> ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
#> ✔ purrr     1.0.2     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
library(basisghana)
## basic example code

# Number of ODF communities in each region

basisghana |>
  group_by(region) |> 
  summarise(odfs = n(),
            population = sum(population, na.rm = TRUE))
#> # A tibble: 5 × 3
#>   region             odfs population
#>   <chr>             <int>      <dbl>
#> 1 Central Region       15        998
#> 2 Northern Region     998     288822
#> 3 Upper East Region   190      63925
#> 4 Upper West Region   232      74307
#> 5 Volta Region        183      18136

# Number of ODF communities in each district

basisghana |>
  group_by(region, district) |> 
  summarise(odfs = n())
#> `summarise()` has grouped output by 'region'. You can override using the
#> `.groups` argument.
#> # A tibble: 60 × 3
#> # Groups:   region [5]
#>    region          district               odfs
#>    <chr>           <chr>                 <int>
#>  1 Central Region  Abura Asebu Kwamankes     2
#>  2 Central Region  Ajumako Enyan Essiam      4
#>  3 Central Region  Asikuma Odoben Brakwa     3
#>  4 Central Region  Assin South               2
#>  5 Central Region  Gomoa East                4
#>  6 Northern Region Bole                     37
#>  7 Northern Region Bunkpurugu               17
#>  8 Northern Region Central Gonja            32
#>  9 Northern Region Chereponi                68
#> 10 Northern Region Damongo                   9
#> # ℹ 50 more rows

# Number of ODF communities in each district

basisghana |>
  group_by(council) |> 
  summarise(odfs = n())
#> # A tibble: 288 × 2
#>    council     odfs
#>    <chr>      <int>
#>  1 Abakrampa      2
#>  2 Afife          3
#>  3 Aflao Wego     2
#>  4 Afransi        2
#>  5 Agbedrafor     2
#>  6 Agumatsa       7
#>  7 Ahamansu      11
#>  8 Ajumako        1
#>  9 Anfoega        2
#> 10 Anyako         4
#> # ℹ 278 more rows
```
