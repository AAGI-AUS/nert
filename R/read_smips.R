#' Read SMIPS Soil Moisture Data from TERN
#'
#' @description
#' Wrapper around [read_tern()] for retrieving the SMIPS v1.0 daily soil
#' moisture data from the TERN Data Portal. SMIPS provides soil moisture
#' estimates at roughly 1km X 1km spatial resolution across Australia,
#' from 1st January 2015 onward (updated approximately daily on the TERN
#' server).
#'
#' @param date A day to download (Date or character, e.g.
#'   \code{"2024-01-15"} or \code{as.Date("2024-01-15")}).
#' @param collection SMIPS collection variant (default \code{"totalbucket"}). Options:
#'   \describe{
#'     \item{\code{"totalbucket"}}{**Soil moisture of the 0-90cm two-bucket store** (mm).
#'       An estimate of the volumetric soil moisture of the complete 0-90cm
#'       SMIPS two-bucket soil moisture store.}
#'     \item{\code{"SMindex"}}{**Soil moisture index, 0-1**.
#'       A unitless index between 0.0 and 1.0, approximating how full the
#'       complete SMIPS 0-90cm soil moisture two-bucket store is.}
#'     \item{\code{"bucket1"}}{**Soil moisture in the upper 0-10cm bucket** (mm).
#'       An estimate of the volumetric soil moisture of the upper 0-10cm
#'       soil bucket.}
#'     \item{\code{"bucket2"}}{**Soil moisture in the lower 10-90cm bucket** (mm).
#'       An estimate of the volumetric soil moisture of the lower 10-90cm
#'       soil bucket.}
#'     \item{\code{"deepD"}}{**Drainage between two buckets** (mm).
#'       An estimate of the drainage from the top 0-1cm soil bucket through
#'       to the lower 10-90cm bucket.}
#'     \item{\code{"runoff"}}{**Runoff/overtopping moisture loss** (mm).
#'       An estimate of the moisture lost from the top 0-10cm bucket due to
#'       runoff or overtopping.}
#'   }
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key. Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}.  See [get_key()] for setup.
#' @param max_tries Maximum number of download retries before an error is
#'   raised. Default=\code{NULL}, in which case the maximum retry number is
#'   resolved from the option \code{nert.max_tries} if that option exists.
#'   (Defaults to 3 retries if \code{nert.max_tries} has not been set.)
#' @param initial_delay Initial retry delay in seconds (doubles with each
#'   attempt). Default=\code{NULL}, in which case the initial delay is
#'   resolved from the option \code{nert.initial_delay} if that option exists.
#'   (Defaults to a 1 second initial delay if \code{nert.initial_delay} has
#'   not been set.)
#'
#' @returns
#' A [terra::SpatRaster] object of the requested SMIPS collection.
#'
#' @seealso
#' [read_tern()]
#'
#' @examplesIf interactive()
#' # Total volumetric soil moisture across both buckets (default)
#' r <- read_smips("2024-01-15")
#' autoplot(r)
#'
#' # Soil moisture index (0-1)
#' r_smi <- read_smips("2024-01-15", collection = "SMindex")
#'
#' # Upper soil bucket
#' r_bucket1 <- read_smips("2024-01-15", collection = "bucket1")
#'
#' # Lower soil bucket
#' r_bucket2 <- read_smips("2024-01-15", collection = "bucket2")
#'
#' # Drainage between upper and lower buckets
#' r_deep <- read_smips("2024-01-15", collection = "deepD")
#'
#' # Top bucket runoff
#' r_runoff <- read_smips("2024-01-15", collection = "runoff")
#'
#' @references
#'   Stenson, M., Searle, R., Malone, B., Sommer, A., Renzullo, L. & Di, H.
#'   (2021): Australia wide daily volumetric soil moisture estimates.
#'   Version 1.0. Terrestrial Ecosystem Research Network. (Dataset).
#'   \doi{10.25901/b020-nm39}.
#'
#'   TERN SMIPS Point-of-truth metadata URL:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#'
#' @autoglobal
#' @export
read_smips <- function(
  date,
  collection = "totalbucket",
  api_key = NULL,
  max_tries = NULL,
  initial_delay = NULL
) {
  read_tern(
    "SMIPS",
    date = date,
    collection = collection,
    api_key = api_key,
    max_tries = max_tries,
    initial_delay = initial_delay
  )
}


#' Internal handler for retrieving SMIPS datasets
#'
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#'
#' @autoglobal
#' @dev
.read_tern_smips <- function(dots, api_key, max_tries, initial_delay) {
  # Accept both 'date' and the legacy 'day' parameter name
  date <- if (!is.null(dots[["date"]])) {
    dots[["date"]]
  } else {
    dots[["day"]]
  }
  if (is.null(date)) {
    cli::cli_abort(
      "SMIPS requires a {.arg date} argument (daily resolution),
       e.g. {.code date = \"2024-01-15\"}."
    )
  }
  collection <- if (!is.null(dots[["collection"]])) {
    dots[["collection"]]
  } else {
    "totalbucket"
  }

  day <- .check_date(date)
  dl_file <- .make_smips_url(.collection = collection, .day = day)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/smips/v1_0/%s/%s/%s",
    api_key,
    collection,
    lubridate::year(day),
    dl_file
  )
  .read_cog(full_url, max_tries, initial_delay)
}


#' Validate date requested aligns with SMIPS collection extent
#'
#' SMIPS daily COGs are published from 2015-01-01 (the earliest archived
#' complete set of soil moisture GeoTIFFs available on the TERN Data Portal),
#' up to today. Requests outside that window will definitely return HTTP 404
#' from the GDAL vsicurl driver, resulting in a "file does not exist" error
#' from [terra::rast()].  This helper function catches this case before
#' any network I/O. (Note: the requested rasters may still be unavailable
#' even if this check passes, e.g., if the user has requested a very recent
#' raster that has not been added to the TERN server yet. This validation
#' function simply checks for the obviously impossible cases.)
#'
#' @param .collection The user-supplied SMIPS collection being asked for.
#' @param .day The user-supplied date being asked for.
#'
#' @autoglobal
#' @dev
.check_collection_agreement <- function(.collection, .day) {
  # Convert everything to Date objects to enable simple and sane comparison
  smips_start <- as.Date("2015-01-01")
  .day <- as.Date(as.character(.day))
  smips_end <- Sys.Date()

  if (.day < smips_start) {
    cli::cli_abort(
      "SMIPS data are not generally available before
      {format(smips_start, '%Y-%m-%d')}. \\
      You requested {format(.day, '%Y-%m-%d')}."
    )
  }
  if (.day > smips_end) {
    cli::cli_abort(
      "SMIPS data are not yet available for dates beyond
      {format(smips_end, '%Y-%m-%d')}. \\
      You requested {format(.day, '%Y-%m-%d')}."
    )
  }
}


#' Create a SMIPS URL
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
