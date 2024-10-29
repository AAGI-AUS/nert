#' Get Soil Moisture Integration and Prediction System (SMIPS) Data
#'
#' Soil Moisture Integration and Prediction System (\acronym{SMIPS}) v1.0.
#'
#' @param collection A character vector of the data collection to be queried,
#'  on of:
#'  * SMIndex
#'  * bucket1
#'  * bucket2
#'  * deepD
#'  * runoff
#'  * totalbucket
#'  Defaults to \dQuote{totalbucket}.
#' @param dates A date to query, _e.g._, `date = 2017-12-31`, both `Character` or
#'  `Date` classes are accepted.
#'
#' @return A [terra::rast] object

#' @references <https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
get_smips <- function(collection = "totalbucket",
                      dates,
                      api_key = get_key()) {

  dates <- lubridate::ymd(dates)
  url_dates <- gsub("-", "", dates)
  approved_collections <- c("totalbucket",
                            "SMIndex",
                            "bucket1",
                            "bucket2",
                            "deepD",
                            "runnoff")
  collection <- rlang::arg_match(collection, approved_collections)

  collection_url <- data.table::fcase(
    collection == "totalbucket",
    paste0("smips_totalbucket_mm_", url_dates, ".tif"),
    collection == "SMIndex",
    paste0("smips_smi_perc_", url_dates, ".tif"),
    collection == "bucket1",
    paste0("smips_bucket1_mm_", url_dates, ".tif"),
    collection == "bucket2",
    paste0("smips_bucket2_mm_", url_dates, ".tif"),
    collection == "deepD",
    paste0("smips_deepD_mm_", url_dates, ".tif"),
    collection == "runoff",
    paste0("smips_runoff_mm_", url_dates, ".tif")
  )

  r <- terra::rast(paste0("/vsicurl/https://",
                    paste0('apikey:', api_key),
                    "@data.tern.org.au/model-derived/smips/v1_0/",
                   collection,
                   "/",
                   lubridate::year(dates),
                   "/",
                   collection_url))
  return(r)
}

