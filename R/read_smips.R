#' Read TERN SMIPS Soil Moisture Data
#'
#' @description
#' Wrapper around [read_tern()] for TERN/SMIPS daily soil moisture data.
#' Provides soil moisture estimates at 1 km resolution from November 2015
#' to approximately 7 days before today.
#'
#' @param date A day to download (Date or character, e.g.
#'   \code{"2024-01-15"} or \code{as.Date("2024-01-15")}).  Required.
#' @param collection SMIPS collection variant (default \code{"totalbucket"}). Options:
#'   \describe{
#'     \item{\code{"totalbucket"}}{**Total soil moisture in the full active layer** (mm).
#'       Represents the total water stored in all soil layers of the active profile.
#'       Use for: Overall soil water availability, drought monitoring.
#'       Output column: \code{SMIPS_totalbucket}}
#'     \item{\code{"SMindex"}}{**Soil Moisture Index, 0-100%** (standardized metric).
#'       Rescaled to 0-100% for comparison across regions and seasons.
#'       Use for: Regional comparisons, anomaly detection, percentage-based thresholds.
#'       Output column: \code{SMIPS_SMindex}}
#'     \item{\code{"bucket1"}}{**Top soil layer moisture** (mm, typically 0-10 cm).
#'       Represents water in surface soil where seeds germinate and shallow roots operate.
#'       Use for: Shallow-rooting plants, seed germination, surface runoff prediction.
#'       Output column: \code{SMIPS_bucket1}}
#'     \item{\code{"bucket2"}}{**Second soil layer moisture** (mm, typically 10-40 cm).
#'       Represents water in intermediate soil depth where many plant roots develop.
#'       Use for: Typical crop rooting depth, plant-available water.
#'       Output column: \code{SMIPS_bucket2}}
#'     \item{\code{"deepD"}}{**Deep soil layer moisture** (mm, typically >40 cm).
#'       Represents water in deeper soil layers accessed by deep-rooting plants.
#'       Use for: Deep-rooting trees/shrubs, groundwater recharge, long-term drought.
#'       Output column: \code{SMIPS_deepD}}
#'     \item{\code{"runoff"}}{**Surface runoff** (mm).
#'       Represents water predicted to run off the surface (not infiltrate).
#'       Use for: Flood risk, erosion modeling, drainage engineering.
#'       Output column: \code{SMIPS_runoff}}
#'   }
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
#' A [terra::rast()] object of the requested SMIPS collection.
#'
#' @seealso
#' [read_tern()], [read_aet()], [read_asc()]
#'
#' @examplesIf interactive()
#' # Total bucket soil moisture (default)
#' r <- read_smips("2024-01-15")
#' autoplot(r)
#'
#' # Soil moisture index (0-100%)
#' r_smi <- read_smips("2024-01-15", collection = "SMindex")
#'
#' # Top soil bucket (shallow rooting plants)
#' r_bucket1 <- read_smips("2024-01-15", collection = "bucket1")
#'
#' # Deep soil layer (deep rooting plants)
#' r_deep <- read_smips("2024-01-15", collection = "deepD")
#'
#' # Surface runoff
#' r_runoff <- read_smips("2024-01-15", collection = "runoff")
#'
#' @references
#'   SMIPS TERN GeoNetwork record:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#'
#' @autoglobal
#' @export
read_smips <- function(
  date,
  collection = "totalbucket",
  api_key    = NULL,
  max_tries  = NULL,
  initial_delay = NULL
) {
  read_tern(
    "SMIPS",
    date       = date,
    collection = collection,
    api_key    = api_key,
    max_tries  = max_tries,
    initial_delay = initial_delay
  )
}


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
