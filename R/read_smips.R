#' Read SMIPS Daily Soil Moisture from TERN
#'
#' Read daily Soil Moisture Information from Pedotransfer functions and
#' Satellite data (\acronym{SMIPS}) Cloud Optimised GeoTIFF (\acronym{COG})
#' files from \acronym{TERN}.  SMIPS provides Australia-wide volumetric soil
#' moisture estimates at approximately 1 km (0.01 degree) resolution, derived
#' from a combination of satellite observations and pedotransfer modelling.
#'
#' Six collection layers are available:
#' \describe{
#'   \item{\code{"totalbucket"}}{Total column soil moisture (0--90 cm) in mm
#'     (default).}
#'   \item{\code{"SMindex"}}{Soil moisture index expressed as a percentage.}
#'   \item{\code{"bucket1"}}{Upper layer moisture (0--10 cm) in mm.}
#'   \item{\code{"bucket2"}}{Lower layer moisture (10--90 cm) in mm.}
#'   \item{\code{"deepD"}}{Deep drainage flux in mm.}
#'   \item{\code{"runoff"}}{Surface runoff in mm.}
#' }
#'
#' Data are available from 2015-11-20 (\code{totalbucket} from 2005) to
#' approximately 7 days before today.
#'
#' This is a convenience wrapper around
#' \code{read_tern("SMIPS", ...)}; see [read_tern()] for full
#' details and additional datasets.
#'
#' @param date A single date to query, e.g.\ \code{"2024-01-15"} or
#'   \code{as.Date("2024-01-15")}.  Both \code{character} and \code{Date}
#'   classes are accepted.
#' @param collection One of \code{"totalbucket"} (default),
#'   \code{"SMindex"}, \code{"bucket1"}, \code{"bucket2"}, \code{"deepD"},
#'   or \code{"runoff"}.
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection via [get_key()].
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#' # Read total bucket soil moisture for a specific day
#' r <- read_smips(date = "2024-01-15")
#' autoplot(r)
#'
#' # Read soil moisture index
#' r_smi <- read_smips(date = "2024-01-15", collection = "SMindex")
#'
#' # Upper layer moisture only
#' r_b1 <- read_smips(date = "2024-06-01", collection = "bucket1")
#'
#' @returns A [terra::rast()] object of the national SMIPS mosaic for the
#'   requested day and collection.
#'
#' @references
#'   \url{https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0}
#'
#' @autoglobal
#' @export
read_smips <- function(
  date,
  collection    = "totalbucket",
  api_key       = get_key(),
  max_tries     = 3L,
  initial_delay = 1L
) {
  read_tern(
    "SMIPS",
    date          = date,
    collection    = collection,
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}


# ── Internal SMIPS helpers ───────────────────────────────────────────────────

#' Check User Input Dates for Validity
#'
#' @param x User entered date value
#' @returns Validated date string as a `POSIXct` object.
#' @note This was taken from \CRANpkg{nasapower}.
#' @examples
#' .check_date("2024-01-01")
#' @author Adam H. Sparks \email{adamhsparks@@curtin.edu.au}
#' @autoglobal
#' @dev
.check_date <- function(x) {
  if (length(x) > 1L) {
    cli::cli_abort("Only one day is allowed per request.")
  }

  if (lubridate::is.POSIXct(x) || lubridate::is.Date(x)) {
    tz <- lubridate::tz(x)
  } else {
    tz <- Sys.timezone()
  }

  tryCatch(
    x <- lubridate::parse_date_time(
      x,
      c(
        "Ymd",
        "dmY",
        "BdY",
        "Bdy"
      ),
      tz = tz
    ),
    warning = function(c) {
      cli::cli_abort(
        "{ x } is not in a valid date format.
                     Please enter a valid date format."
      )
    }
  )
  return(x)
}


#' Validate Days Requested Align With Collection
#'
#' Not all dates are offered by all collections. This checks the user inputs to
#' be sure that unavailable dates are not requested from collections that do not
#' provide them.
#'
#' @param .collection The user-supplied SMIPS collection being asked for.
#' @param .day The user-supplied date being asked for.
#'
#' @autoglobal
#'
#' @dev
.check_collection_agreement <- function(.collection, .day) {
  # .this_year <- lubridate::year(lubridate::today())
  .last_week <- lubridate::today() - 7
  .url_year <- lubridate::year(.day)

  if (
    .collection == "totalbucket" &&
      .url_year < 2005L ||
      # NOTE: this is throwing "'tzone' attributes are inconsistent"
      .day > .last_week
  ) {
    cli::cli_abort(
      "The data are not available before 2005 and roughly
                   much past { .last_week }"
    )
  }
}

#' Create an SMIPS URL
#'
#' Creates the SMIPS specific portion of a URL to read or fetch a COG.
#'
#' @param .collection The user-supplied SMIPS collection being asked for.
#' @param .day The user-supplied date being asked for.
#'
#' @autoglobal
#' @dev

.make_smips_url <- function(.collection, .day) {
  url_date <- gsub("-", "", .day, fixed = TRUE)

  approved_collections <- c(
    "totalbucket",
    "SMindex",
    "bucket1",
    "bucket2",
    "deepD",
    "runoff"
  )
  collection <- rlang::arg_match(.collection, approved_collections)

  .check_collection_agreement(.collection = .collection, .day = .day)

  collection_url <- data.table::fcase(
    collection == "totalbucket",
    paste0("smips_totalbucket_mm_", url_date, ".tif"),
    collection == "SMindex",
    paste0("smips_smi_perc_", url_date, ".tif"),
    collection == "bucket1",
    paste0("smips_bucket1_mm_", url_date, ".tif"),
    collection == "bucket2",
    paste0("smips_bucket2_mm_", url_date, ".tif"),
    collection == "deepD",
    paste0("smips_deepD_mm_", url_date, ".tif"),
    collection == "runoff",
    paste0("smips_runoff_mm_", url_date, ".tif")
  )

  return(collection_url)
}
