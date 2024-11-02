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
#' @section Argument details for `lonlat`:
#' \describe{
#'  \item{Single point}{To get a specific cell, 1/2 x 1/2 degree, supply a
#'  length-two numeric vector giving the decimal degree longitude and latitude
#'  in that order for data to download,\cr
#'  _e.g._, `lonlat = c(-179.5, -89.5)`.}
#'
#'  \item{Regional coverage}{To get a region, supply a length-four numeric
#'  vector as lower left (lon, lat) and upper right (lon, lat) coordinates,
#'  _e.g._, `lonlat = c(xmin, ymin, xmax, ymax)` in that order for a
#'  given region, _e.g._, a bounding box for the south western corner of
#'  Australia: `lonlat = c(112.5, -55.5, 115.5, -50.5)`.}
#' }
#'
#' @family COGs
#'
#' @examplesIf interactive()
#'
#' r <- read_cog(day = "2024-01-01", api_key = "your_api_key")
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
                     longitude = NULL,
                     latitude = NULL,
                     api_key = get_key()) {

  day <- .check_date(day)
  url_year <- lubridate::year(day)


  user_longitude <- lonlat["longitude"]
  user_latitude <- lonlat["latitude"]

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
    cli::cli_abort("The data are not available before 2005 and past {.last_week}")
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
