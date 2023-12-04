#' Basic Sanitation Information System - BaSIS
#'
#' The BaSIS dataset captures sanitation information across Ghana's subnational regions,
#' focusing on open defection free communities data such as population, households, toilets, and handwashing facilities.
#'
#' @format A tibble with 1618 rows and 10 variables:
#' \describe{
#'   \item{ no}{ A running id for unique for each region.}
#'   \item{ region}{ First level of subnational government administration within the Republic of Ghana.}
#'   \item{ district}{ Second level administrative subdivision below region.}
#'   \item{ area_council}{ Third level administrative unit below district level.}
#'   \item{ community}{ Open defecation free (ODF) community. The community is the smallest level of local administration in Ghana (also called unit committees).}
#'   \item{ partner}{ Implementing partner of the CLTS (Community-Led Total Sanitation) program in the respective community.}
#'   \item{ population}{ Population size of the respective community.}
#'   \item{ households}{ Number of households in the respective community.}
#'   \item{ toilets}{ Number of toilets in the respective community.}
#'   \item{ hwf}{ Number of handwashing facilities in the respective community.}
#' }
"basisghana"
