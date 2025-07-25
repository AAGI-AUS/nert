#' Read SMIPS COGs from TERN
#'
#' Read Soil Moisture Integration and Prediction System (\acronym{SMIPS}) Cloud
#'  Optimised Geotiff (\acronym{COG}) files from \acronym{TERN} in your \R
#'  session.
#'
#' @param day A date to query, _e.g._, `day = "2017-12-31"` or `day =
#'  as.Date("2017-12-01")`, both `Character` and `Date` classes are accepted.
#' @param collection A character vector of the \dQuote{SMIPS} data collection to
#' be queried:
#'  * SMindex: the \acronym{SMIPS} Soil Moisture Index (\emph{i.e.}, a number
#'  between 0 and 1 that indicates how full the \acronym{SMIPS} bucket moisture
#'  store is relative to its 90 cm capacity),
#'  * totalbucket: an estimate of the \emph{volumetric soil moisture (in mm)
#'  from the \acronym{SMIPS} bucket moisture store},
#'  Defaults to \dQuote{totalbucket}. Multiple `collections` are supported,
#'  _e.g._, `collection = c("SMindex", "totalbucket")`.
#' @param api_key A `character` string containing your \acronym{API} key,
#'   a random string provided to you by \acronym{TERN}, for the request.
#'   Defaults to automatically detecting your key from your local .Renviron,
#'   .Rprofile or similar.  Alternatively, you may directly provide your key as
#'   a string here or use functionality like that from \CRANpkg{keyring}.  If
#'   nothing is provided, you will be prompted on how to set up your \R session
#'   so that it is auto-detected and a browser window will open at the
#'   \acronym{TERN} website for you to request a key.
#' @param max_tries An integer `Integer` with the number of times to retry a
#'   failed download before emitting an error message.  Defaults to 3.
#' @param initial_delay An `Integer` with the number of seconds to delay before
#'   retrying the download.  This increases as the tries increment.  Defaults to
#'   1.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#'
#' r <- read_smips("2024-01-01")
#'
#' # `tidyterra::autoplot` is re-exported for convenience
#' autoplot(r)
#'
#' @returns A [terra::rast()] object.
#'
#' @autoglobal
#' @references <https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0> and
#' <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#' @export
read_smips <- function(
  day,
  collection = "totalbucket",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
) {
  api_key <- .check_api_key(api_key)
  if (missing(day)) {
    cli::cli_abort("You must provide a single day's date for this request.")
  }
  day <- .check_date(day)
  url_year <- lubridate::year(day)

  dl_file <- .make_smips_url(.collection = collection, .day = day)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/smips/v1_0/%s/%s/%s",
    api_key,
    collection,
    url_year,
    dl_file
  )
  return(.read_cog(full_url, max_tries, initial_delay))
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
