#' Get Soil Moisture Integration and Prediction System (SMIPS) Data
#'
#' Soil Moisture Integration and Prediction System (\acronym{SMIPS}) v1.0.
#'
#' @param collection A character vector of the data collection to be queried,
#'  on of:
#'  * SMindex
#'  * bucket1
#'  * bucket2
#'  * deepD
#'  * runoff
#'  * totalbucket
#'  Defaults to \dQuote{totalbucket}.
#' @param day A single day's date to query, _e.g._, `day = "2017-12-31"`, both
#'  `Character` and `Date` classes are accepted.
#'
#' @examples
#' r <- get_smips(day = "2024-01-01")
#'
#' # terra::plot() is re-exported for convenience
#' plot(r)
#'
#' @return A [terra::rast] object
#' @references <https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#' @export
get_smips <- function(collection = "totalbucket",
                      day,
                      api_key = get_key()) {

  day <- lubridate::ymd(day)
  url_date <- gsub("-", "", day)
  url_year <- lubridate::year(url_date)

  .check_years(.collection = collection, .url_date = url_date)

  approved_collections <- c("totalbucket",
                            "SMindex",
                            "bucket1",
                            "bucket2",
                            "deepD",
                            "runnoff")
  collection <- rlang::arg_match(collection, approved_collections)

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

  r <- terra::rast(paste0("/vsicurl/https://",
                    paste0('apikey:', api_key),
                    "@data.tern.org.au/model-derived/smips/v1_0/",
                   collection,
                   "/",
                   url_year,
                   "/",
                   collection_url))
  return(r)
}

