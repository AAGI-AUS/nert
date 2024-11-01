#' Read COGs from TERN
#'
#' Read Cloud Optimised Geotiff (\acronym(COG)) files from \acronym{TERN} in
#'   your active \R session.
#'
#' @note
#' Currently only Soil Moisture Integration and Prediction System
#'   (\acronym{SMIPS}) v1.0 is supported.
#'
#' @param data A character vector of the data source to be queried, currently
#'   only \dQuote{smips}
#' @param collection A character vector of the data collection to be queried,
#'  currenly only \dQuote{smips} is supported with the following collections:
#'  * SMindex
#'  * bucket1
#'  * bucket2
#'  * deepD
#'  * runoff
#'  * totalbucket
#'  Defaults to \dQuote{totalbucket}.
#' @param day A single day's date to query, _e.g._, `day = "2017-12-31"`, both
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
#' @references <https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#' @export

read_cog <- function(data = "smips",
                     collection = "totalbucket",
                     day,
                     api_key = get_key()) {
  day <- lubridate::ymd(day)
  url_year <- lubridate::year(day)

  if (data == "smips") {
    collection_url <- .make_smips_url(.collection = collection, .day = day)
    return(terra::rast(
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
  }
}
