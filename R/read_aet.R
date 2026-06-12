#' Read CMRSET Actual Evapotranspiration Data from TERN
#'
#' @description
#' Wrapper around [read_tern()] for retrieving the CMRSET actual
#' evapotranspiration data (v2.2) from the TERN Data Portal. This dataset
#' provides monthly estimates of actual ET (mm/month) at 30 m resolution
#' from May 1987 onwards, using the CSIRO MODIS Reflectance-based Scaling
#' EvapoTranspiration (CMRSET) algorithm that combines potential
#' evapotranspiration data from the Bureau of Meteorology together with
#' satellite image data provided by MODIS, VIIRS, Landsat and Sentinel-2.
#'
#' @param date A month to download (Date or character, e.g.
#'   \code{"2023-06-01"} or \code{as.Date("2023-06-01")}).  The value
#'   is snapped to the first of the month internally.  Required.
#' @param collection One of \code{"ETa"} (actual evapotranspiration in
#'   mm/month, default) or \code{"pixel_qa"} (quality assurance attributes).
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
#' A [terra::SpatRaster] object of the requested Evapotranspiration collection.
#'
#' @seealso
#' [read_tern()]
#'
#' @examplesIf interactive()
#' # Actual evapotranspiration (ETa) for June 2023 (mm/month)
#' r_eta <- read_aet("2023-06-01")
#' autoplot(r_eta)
#'
#' # January 2023 ET
#' r_jan <- read_aet("2023-01-01")
#'
#' # Quality assurance flags for June 2023
#' r_qa <- read_aet("2023-06-01", collection = "pixel_qa")
#'
#' # ET from May 1987 (earliest available)
#' r_early <- read_aet("1987-05-01")
#'
#' # Current/recent ET (within last month)
#' r_recent <- read_aet(Sys.Date())
#'
#' @references
#'   McVicar, T., Vleeshouwer, J., Van Niel, T., Guerschman, J. &
#'   Peña-Arancibia, J. (2022). Actual Evapotranspiration for Australia
#'   using CMRSET algorithm. Version 1.0. Terrestrial Ecosystem Research
#'   Network. (Dataset). \doi{10.25901/gg27-ck96}.
#'
#'   TERM CMRSET Actual Evapotranspiration Point-of-truth metadata URL:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
#'
#' @autoglobal
#' @export
read_aet <- function(
  date,
  collection = "ETa",
  api_key = NULL,
  max_tries = NULL,
  initial_delay = NULL
) {
  return(read_tern(
    "AET",
    date = date,
    collection = collection,
    api_key = api_key,
    max_tries = max_tries,
    initial_delay = initial_delay
  ))
}


#' Internal handler for retrieving the AET data
#'
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_aet <- function(dots, api_key, max_tries, initial_delay) {
  # Accept both 'date' and the legacy 'month' parameter name
  date <- if (!is.null(dots[["date"]])) {
    dots[["date"]]
  } else {
    dots[["month"]]
  }
  if (is.null(date)) {
    cli::cli_abort(
      "AET requires a {.arg date} argument (monthly resolution),
       e.g.  {.code date = \"2023-06-01\"}."
    )
  }
  collection <- if (!is.null(dots[["collection"]])) {
    dots[["collection"]]
  } else {
    "ETa"
  }

  month <- .check_aet_date(date)
  full_url <- .make_aet_url(
    .collection = collection,
    .month = month,
    .api_key = api_key
  )
  return(.read_cog(full_url, max_tries, initial_delay))
}


#' Check User Input Months for AET Validity
#'
#' Validates and snaps a user-supplied date value to the first of the month,
#' then checks it against the \acronym{AET} data availability window
#' (from 1987-05-01 onwards).
#'
#' @param x User-entered date value (any format accepted by [.check_date()]).
#' @returns A \code{POSIXct} object snapped to the first of the requested
#'   month.
#' @autoglobal
#' @dev
.check_aet_date <- function(x) {
  x <- .check_date(x)
  x <- lubridate::floor_date(x, "month")
  if (x < as.POSIXct("1987-05-01")) {
    cli::cli_abort(
      "AET data are not available before 1987-05-01.
       You requested {format(x, '%Y-%m-%d')}."
    )
  }
  return(x)
}


#' Build a GDAL vsicurl URL to retrieve AET data
#'
#' @param .collection The user-supplied \acronym{AET} collection
#'   (\code{"ETa"} or \code{"pixel_qa"}).
#' @param .month The validated \code{POSIXct} date snapped to the first of
#'   the month.
#' @param .api_key The \acronym{URL}-encoded \acronym{API} key.
#' @returns A \code{character} GDAL vsicurl URL string.
#' @autoglobal
#' @dev
.make_aet_url <- function(.collection, .month, .api_key) {
  approved_collections <- c("ETa", "pixel_qa")
  collection <- rlang::arg_match(.collection, approved_collections)

  year <- lubridate::year(.month)
  date_str <- format(.month, "%Y_%m_%d")

  return(sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/aet/v2_2/%s/%s/CMRSET_LANDSAT_V2_2_%s_%s.vrt",
    .api_key,
    year,
    date_str,
    date_str,
    collection
  ))
}
