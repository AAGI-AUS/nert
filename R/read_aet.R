#' Read CMRSET Actual Evapotranspiration Data from TERN
#'
#' @description
#' Wrapper around [read_tern()] for retrieving the CMRSET actual
#' evapotranspiration data (v2.2) from the TERN Data Portal. This dataset
#' provides monthly estimates of actual ET (mm/month) at 30 m resolution
#' from February 2000 onwards. #FIXME: May 1987 actually.
#'
#' @param date A month to download (Date or character, e.g.
#'   \code{"2023-06-01"} or \code{as.Date("2023-06-01")}).  The value
#'   is snapped to the first of the month internally.  Required.
#' @param collection One of \code{"ETa"} (actual evapotranspiration in
#'   mm/month, default) or \code{"pixel_qa"} (quality assurance flags).
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}.  See [get_key()] for setup.
#' @param max_tries Maximum number of download retries before an error is
#'   raised.  When \code{NULL} (default), resolved from
#'   \code{getOption("nert.max_tries", 3L)}.  Pass an integer to override
#'   for a single call.
#' @param initial_delay Initial retry delay in seconds (doubles with each
#'   attempt).  When \code{NULL} (default), resolved from
#'   \code{getOption("nert.initial_delay", 1L)}.  Pass an integer to
#'   override for a single call.
#'
#' @returns
#' A [terra::rast()] object of the requested ET collection.
#'
#' @seealso
#' [read_tern()], [read_smips()], [read_asc()]
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
#' # ET from February 2000 (earliest available)
#' r_early <- read_aet("2000-02-01")
#'
#' # Current/recent ET (within last month)
#' r_recent <- read_aet(Sys.Date())
#'
#' @references
#'   CMRSET portal:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
#'
#'   CMRSET DOI: \doi{10.25901/gg27-ck96}
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
  read_tern(
    "AET",
    date = date,
    collection = collection,
    api_key = api_key,
    max_tries = max_tries,
    initial_delay = initial_delay
  )
}


# -- Internal AET handler ----------------------------------------------------

#' Internal handler for AET/CMRSET (\code{TERN/9fefa68b})
#'
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_aet <- function(dots, api_key, max_tries, initial_delay) {
  # Accept both 'date' and the legacy 'month' parameter name
  date <- if (!is.null(dots[["date"]])) dots[["date"]] else dots[["month"]]
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
  .read_cog(full_url, max_tries, initial_delay)
}


# -- AET date and URL helpers -----------------------------------------------

#' Check User Input Months for AET Validity
#'
#' Validates and snaps a user-supplied date value to the first of the month,
#' then checks it against the \acronym{AET} data availability window
#' (from 2000-02-01 onwards).
#'
#' @param x User-entered date value (any format accepted by [.check_date()]).
#' @returns A \code{POSIXct} object snapped to the first of the requested
#'   month.
#' @autoglobal
#' @dev
.check_aet_date <- function(x) {
  x <- .check_date(x)
  x <- lubridate::floor_date(x, "month")
  yr <- lubridate::year(x)
  mo <- lubridate::month(x)
  if (yr < 2000L || (yr == 2000L && mo < 2L)) {
    cli::cli_abort(
      "AET data are not available before 2000-02-01.
       You requested {format(x, '%Y-%m-%d')}."
    )
  }
  return(x)
}


#' Build a GDAL vsicurl URL for an AET Collection
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

  sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/aet/v2_2/%s/%s/CMRSET_LANDSAT_V2_2_%s_%s.vrt",
    .api_key,
    year,
    date_str,
    date_str,
    collection
  )
}
