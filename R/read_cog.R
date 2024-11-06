#' Read COGs from TERN
#'
#' Read Cloud Optimised Geotiff (\acronym{COG}) files from \acronym{TERN} in
#'   your active \R session.
#'
#' @note
#' Currently only Soil Moisture Integration and Prediction System
#'   (\acronym{SMIPS}) v1.0 is supported.
#'
#' @param data A character vector of the data source to be queried, currently
#'   only \dQuote{smips}.
#' @param collection A character vector of the data collection to be queried,
#'  currenly only \dQuote{smips} is supported with the following collections:
#'  * SMindex
#'  * bucket1
#'  * bucket2
#'  * deepD
#'  * runoff
#'  * totalbucket
#'  Defaults to \dQuote{totalbucket}. Multiple `collections` are supported,
#'  _e.g._, `collection = c("SMindex", "totalbucket")`.
#' @param day A vector of date(s) to query, _e.g._, `day = "2017-12-31"` or
#'  `day = seq.Date(as.Date("2017-12-01"), as.Date("2017-12-31"), "days")`, both
#'  `Character` and `Date` classes are accepted.
#' @param api_key A `character` string containing your \acronym{API} key,
#'   a random string provided to you by \acronym{TERN}, for the request.
#'   Defaults to automatically detecting your key from your local .Renviron,
#'   .Rprofile or similar.  Alternatively, you may directly provide your key as
#'   a string here or use functionality like that from \CRANpkg{keyring}.  If
#'   nothing is provided, you will be prompted on how to set up your \R session
#'   so that it is auto-detected and a browser window will open at the
#'   \acronym{TERN} website for you to request a key.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#'
#' r <- read_cog(day = "2024-01-01")
#'
#' # terra::plot() is re-exported for convenience
#' plot(r)
#'
#' @return A [terra::rast] object
#'
#' @autoglobal
#' @references <https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#' @export

read_cog <- function(data = "smips",
                     collection = "totalbucket",
                     day,
                     api_key = get_key()) {

  if (missing(day)) {
    cli::cli_abort("You must provide a single day's date for this request.")
  }
  day <- .check_date(day)
  url_year <- lubridate::year(day)

  if (data == "smips") {
    collection_url <- .make_smips_url(.collection = collection, .day = day)
    r <- (terra::rast(
      paste0(
        "/vsicurl/https://",
        paste0("apikey:", api_key),
        "@data.tern.org.au/model-derived/smips/v1_0/",
        collection,
        "/",
        url_year,
        "/",
        .make_smips_url(.collection = collection, .day = day)
      )
    )
    )

    return(r)
  }
}

#' Check User Input Dates for Validity
#'
#' @param x User entered date value
#' @return Validated date string as a `POSIXct` object.
#' @note This was taken from \CRANpkg{nasapower}.
#' @example .check_date(x)
#' @author Adam H. Sparks \email{adamhsparks@@curtin.edu.au}
#' @keywords Internal
#' @autoglobal
#' @noRd
.check_date <- function(x) {
  if (length(x) > 1) {
    cli::cli_abort("Only one day is allowed per request.")
  }
  tryCatch(
    x <- lubridate::parse_date_time(x,
                                    c(
                                      "Ymd",
                                      "dmY",
                                      "mdY",
                                      "BdY",
                                      "Bdy",
                                      "bdY",
                                      "bdy"
                                    ),
                                    tz = Sys.timezone()),
    warning = function(c) {
      cli::cli_abort(
        "{ x } is not in a valid date format. Please enter a valid date format.")
    }
  )
  return(x)
}


#' Check that the user hasn't blindly copied the "your_api_key" string from the
#' examples
#'
#' @keywords Internal
#' @autoglobal
#' @noRd

.check_not_example_api_key <- function(.api_key) {
  if (!is.null(.api_key) && .api_key == "your_api_key") {
    stop("You have copied the example code and not provided a proper API key.
         An API key may be requested from TERN to access this resource. Please
         see the help file for {.fn get_key} for more information.",
         call. = FALSE)
  }
  return(invisible(NULL))
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
#' @noRd
#' @keywords Internal

.check_collection_agreement <- function(.collection, .day) {
  .this_year <- lubridate::year(lubridate::today())
  .last_week <- lubridate::today() - 7
  .url_year <- lubridate::year(.day)

  if (.collection == "totalbucket" &&
      .url_year < 2005 ||
      .day > .last_week) {
    cli::cli_abort("The data are not available before 2005 and past { .last_week }")
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
#' @noRd
#' @keywords Internal

.make_smips_url <- function(.collection, .day) {
  url_date <- gsub("-", "", .day)

  approved_collections <- c("totalbucket",
                            "SMindex",
                            "bucket1",
                            "bucket2",
                            "deepD",
                            "runnoff")
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
}
