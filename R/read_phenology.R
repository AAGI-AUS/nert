#' Read Land Surface Phenology Data (MODIS)
#'
#' @description
#' Wrapper around [read_tern()] for Land Surface Phenology derived from
#' \acronym{MODIS} \acronym{NDVI} (TERN/2bb0c81a).  Provides annual Start
#' and End of Growing Season for years 2003-2018 at 500 m resolution
#' (static, non-updated product).
#'
#' @param metric Phenology metric.  One of:
#'   \describe{
#'     \item{\code{"SGS"}}{Start of Growing Season (default)}
#'     \item{\code{"EGS"}}{End of Growing Season}
#'   }
#' @param year Year (2003-2018, default 2018).
#' @param season Season number (default 1).  For most Australian regions,
#'   season 1 is the primary growing season.  Additional seasons may be
#'   available for select regions.
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}.  See [get_key()] for setup.
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries before an error is raised.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
#'
#' @returns
#' A [terra::rast()] object (single layer).  Pixel values represent day-of-year
#' for the specified metric (e.g., 100 = ~April 10 in a non-leap year).
#'
#' @seealso
#' [read_tern()], [read_canopy_height()]
#'
#' @examplesIf interactive()
#' # Start of Growing Season (default: 2018, season 1)
#' r_sgs_2018 <- read_phenology()
#' autoplot(r_sgs_2018)
#'
#' # End of Growing Season, 2018
#' r_egs_2018 <- read_phenology(metric = "EGS", year = 2018)
#'
#' # Start of Growing Season, 2015
#' r_sgs_2015 <- read_phenology(metric = "SGS", year = 2015)
#'
#' # Start of Growing Season, 2003 (earliest year)
#' r_sgs_2003 <- read_phenology(metric = "SGS", year = 2003)
#'
#' # End of Growing Season, 2010, season 2 (if available)
#' r_egs_s2 <- read_phenology(metric = "EGS", year = 2010, season = 2)
#'
#' @references
#'   TERN portal:
#'   <https://portal.tern.org.au/metadata/TERN/2bb0c81a>
#'
#'   Hill et al. (2017). Land surface phenology and seasonality using
#'   Functional Data Analysis. _Remote Sensing of Environment_, 203, 49-60.
#'
#' @autoglobal
#' @export
read_phenology <- function(
  metric = "SGS",
  year   = 2018,
  season = 1,
  api_key    = NULL,
  max_tries  = 3L,
  initial_delay = 1L
) {
  read_tern(
    "PHENOLOGY",
    metric        = metric,
    year          = year,
    season        = season,
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}
