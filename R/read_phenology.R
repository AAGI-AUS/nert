#' Read Land Surface Phenology from TERN
#'
#' Wrapper around [read_tern()] for retrieving the Australian land surface
#' phenology dataset (v1.0) from the TERN Data Portal. This data comprises
#' phenology metrics from two growing seasons per year between 2003 and
#' 2018 (inclusive), estimated at 500m X 500m spatial resolution across
#' all of Australia using thresholded MODIS Enhanced Vegetation Index (EVI)
#' imagery.
#'
#' @section Phenology metrics:
#' Eleven phenological metrics are available via the \code{collection}
#' argument:
#' \describe{
#'   \item{\code{"SGS"}}{**Start of Growing Season** (default). A number
#'     between -150 and 345 indicating the start of the growing season (with
#'     negative numbers meaning the prior year).}
#'   \item{\code{"PGS"}}{**Peak of Growing Season**. A number between 9 and
#'     361 indicating the day of the year for the peak of the growing season.}
#'   \item{\code{"EGS"}}{**End of Growing Season**. A number between 25 and
#'     519 indicating the day of the year that marks the end of the growing
#'     season, with numbers above 365 (or 366 for leap years) meaning the
#'     following year.}
#'   \item{\code{"LGS"}}{**Length of Growing Season**, measured in days.}
#'   \item{\code{"EVI1"}}{**Minimum of EVI before peak**. A unitless index
#'     between 0 and 10000 (i.e., scaled by 10000) for the minimum
#'     value of the Enhanced Vegetation Index *before* the peak of the growing
#'     season.}
#'   \item{\code{"EVI2"}}{**Minimum of EVI after peak**. A unitless index
#'     between 0 and 10000 (i.e., scaled by 10000) for the minimum
#'     value of the Enhanced Vegetation Index *after* the peak of the growing
#'     season.}
#'   \item{\code{"EVIP"}}{**Peak EVI**. A unitless index between 0 and 10000
#'     (i.e., scaled by 10000) for the value of the Enhanced Vegetation Index
#'     *at* the peak of the growing season.}
#'   \item{\code{"EVII"}}{**Integral of the EVI across the season**. The
#'     calculated integral of the Enhanced Vegetation Index (including the
#'     factor of 10000 scaling) under the growing season cycle curve.}
#'   \item{\code{"SGS_month"}}{**Start of the growing season by month**.
#'     A number between 1 and 12, indicating the month for the start of the
#'     growing season (i.e., the \code{"SGS"} metric but reprocessed to
#'     monthly time resolution).}
#'   \item{\code{"PGS_month"}}{**Peak of the growing season by month**.
#'     A number between 1 and 12, indicating the month for the peak of the
#'     growing season (i.e., the \code{"PGS"} metric but reprocessed to
#'     monthly time resolution).}
#'   \item{\code{"EGS_month"}}{**End of the growing season by month**.
#'     A number between 1 and 12, indicating the month for the end of the
#'     growing season (i.e., the \code{"EGS"} metric but reprocessed to
#'     monthly time resolution).}
#' }
#'
#' @param year An integer year (2003--2018).
#' @param season Season number: \code{1} (default) or \code{2}.
#' @param collection Phenology metric abbreviation.  One of \code{"SGS"}
#'   (default), \code{"PGS"}, \code{"EGS"}, \code{"LGS"}, \code{"EVI1"},
#'   \code{"EVI2"}, \code{"EVIP"}, \code{"EVII"}, \code{"SGS_month"},
#'   \code{"PGS_month"} or \code{"EGS_month"}.
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key. Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}.  See [get_key()] for setup.
#' @param max_tries Maximum number of download retries before an error is
#'   raised. Default=\code{NULL}, in which case the maximum retry number is
#'   resolved from the option \code{nert.max_tries} if that option exists.
#'   (Defaults to 3 retries if \code{nert.max_tries} has not been set.)
#' @param initial_delay Initial retry delay in seconds (doubles with each
#'   attempt). Default=\code{NULL}, in which case the initial delay is
#'   resolved from the option \code{nert.initial_delay} if that option exists.
#'   (Defaults to a 1 second initial delay if \code{nert.initial_delay} has
#'   not been set.)
#'
#' @returns
#' A [terra::SpatRaster] object of the requested phenology metric.
#'
#' @seealso
#' [read_tern()]
#'
#' @examplesIf interactive()
#' # Read Start of Growing Season for 2018, Season 1
#' r <- read_phenology(year = 2018)
#' autoplot(r)
#'
#' # Read End of Growing Season for 2015, Season 2
#' r_egs <- read_phenology(year = 2015, season = 2, collection = "EGS")
#' autoplot(r_egs)
#'
#' @references
#'   Xie, Q. & Huete, A. (2024). Australian land surface phenology dataset at
#'   500m resolution. Version 1.0. Terrestrial Ecosystem Research Network.
#'   (Dataset). URL: <https://portal.tern.org.au/metadata/2bb0c81a-41a9-434c-b87a-db0301cb52fb>.
#'
#'   TERN Land Surface Phenology Point-of-truth metadata URL:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/2bb0c81a-41a9-434c-b87a-db0301cb52fb>
#'
#' @autoglobal
#' @export
read_phenology <- function(
  year = NULL,
  season = 1L,
  collection = "SGS",
  api_key = get_key(),
  max_tries = NULL,
  initial_delay = NULL
) {
  read_tern(
    "PHENOLOGY",
    year = year,
    season = season,
    collection = collection,
    api_key = api_key,
    max_tries = max_tries,
    initial_delay = initial_delay
  )
}


#' Phenology metric registry
#'
#' Named list mapping metric abbreviations to their subdirectory names on
#' the TERN data server.
#'
#' @format A named \code{list} of \code{character} strings.
#' @autoglobal
#' @dev
.phenology_metrics <- list(
  SGS = "1_Start_of_the_growing_season",
  PGS = "2_Peak_of_the_growing_season",
  EGS = "3_End_of_the_growing_season",
  LGS = "4_Length_of_the_growing_season",
  EVI1 = "5_Minimum_EVI_value_before_PGS",
  EVI2 = "6_Minimum_EVI_value_after_PGS",
  EVIP = "7_Peak_EVI_value_of_the_growing_season",
  EVII = "8_Integral_EVI_value_of_the_growing_season",
  SGS_month = "9_Start_of_the_growing_season_by_month",
  PGS_month = "10_Peak_of_the_growing_season_by_month",
  EGS_month = "11_End_of_the_growing_season_by_month"
)


#' Internal handler for Land Surface Phenology (\code{TERN/2bb0c81a})
#'
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_phenology <- function(dots, api_key, max_tries, initial_delay) {
  year <- as.integer(dots[["year"]])
  season <- if (!is.null(dots[["season"]])) {
    as.integer(dots[["season"]])
  } else {
    1L
  }
  collection <- if (!is.null(dots[["collection"]])) {
    dots[["collection"]]
  } else {
    "SGS"
  }

  approved_metrics <- names(.phenology_metrics)
  collection <- rlang::arg_match(collection, approved_metrics)

  if (!season %in% 1L:2L) {
    cli::cli_abort("Phenology {.arg season} must be 1 or 2.")
  }

  metric_dir <- .phenology_metrics[[collection]]

  # For the monthly rasters, strip the "_month" bit off the end
  # to match to the raster filenames in the TERN server directory
  fname <- sprintf(
    "%s_%d_Season%d.tif",
    sub("_month", "", collection, fixed = TRUE),
    year,
    season
  )
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/%s/%s",
    api_key, metric_dir, fname
  )
  .read_cog(full_url, max_tries, initial_delay)
}
