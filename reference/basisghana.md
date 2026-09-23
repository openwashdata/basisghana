# Basic Sanitation Information System - BaSIS

The BaSIS dataset captures sanitation information across Ghana's
subnational regions, focusing on open defection free communities data
such as population, households, toilets, and handwashing facilities.

## Usage

``` r
basisghana
```

## Format

A tibble with 1618 rows and 10 variables:

- no:

  A running id for unique for each region.

- region:

  First level of subnational government administration within the
  Republic of Ghana.

- district:

  Second level administrative subdivision below region.

- area_council:

  Third level administrative unit below district level.

- community:

  Open defecation free (ODF) community. The community is the smallest
  level of local administration in Ghana (also called unit committees).

- partner:

  Implementing partner of the CLTS (Community-Led Total Sanitation)
  program in the respective community.

- population:

  Population size of the respective community.

- households:

  Number of households in the respective community.

- toilets:

  Number of toilets in the respective community.

- hwf:

  Number of handwashing facilities in the respective community.
