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
