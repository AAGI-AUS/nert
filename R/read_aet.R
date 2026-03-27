#' Read AET Monthly Evapotranspiration from TERN
#'
#' Read monthly Actual Evapotranspiration (\acronym{AET}) Cloud Optimised
#' GeoTIFF (\acronym{COG}) files from \acronym{TERN}.  This product is
#' derived from the CMRSET (CSIRO MODIS Reflectance-based Scaling
#' EvapoTranspiration) algorithm applied to Landsat imagery, providing
#' Australia-wide monthly actual evapotranspiration estimates.
#'
#' Two collection layers are available:
#' \describe{
#'   \item{\code{"ETa"}}{Actual evapotranspiration in mm per month
#'     (default).}
#'   \item{\code{"pixel_qa"}}{Quality assurance flags for each pixel.}
#' }
#'
#' Data are available from 2000-02-01 onwards.  The supplied date is
#' snapped to the first of the month internally.
#'
#' This is a convenience wrapper around
#' \code{read_tern("AET", ...)}; see [read_tern()] for full
#' details and additional datasets.
#'
#' @param date A single date identifying the month to query, e.g.\
#'   \code{"2023-06-01"} or \code{as.Date("2023-06-01")}.  Both
#'   \code{character} and \code{Date} classes are accepted.
#' @param collection One of \code{"ETa"} (default) or \code{"pixel_qa"}.
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
#' # Read monthly actual evapotranspiration
#' r <- read_aet(date = "2023-06-01")
#' autoplot(r)
#'
#' # Read quality assurance layer
#' r_qa <- read_aet(date = "2023-06-01", collection = "pixel_qa")
#'
#' # Summer month
#' r_jan <- read_aet(date = "2024-01-01")
#' autoplot(r_jan)
#'
#' @returns A [terra::rast()] object of the national AET/CMRSET mosaic for
#'   the requested month and collection.
#'
#' @references
#'   \url{https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97}
#'
#'   DOI: \doi{10.25901/gg27-ck96}
#'
#' @autoglobal
#' @export
read_aet <- function(
  date,
  collection    = "ETa",
  api_key       = get_key(),
  max_tries     = 3L,
  initial_delay = 1L
) {
  read_tern(
    "AET",
    date          = date,
    collection    = collection,
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}
