#' Read CMRSET Actual Evapotranspiration Data
#'
#' @description
#' Wrapper around [read_tern()] for TERN/CMRSET evapotranspiration data.
#' Provides monthly estimates of actual ET (mm/month) at 30 m resolution
#' from February 2000 onwards.
#'
#' @param date A month to download (Date or character, e.g.
#'   \code{"2023-06-01"} or \code{as.Date("2023-06-01")}).  The value
#'   is snapped to the first of the month internally.  Required.
#' @param collection One of \code{"ETa"} (actual evapotranspiration in
#'   mm/month, default) or \code{"pixel_qa"} (quality assurance flags).
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}.  See [get_key()] for setup.
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries before an error is raised.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
#'
#' @returns
#' A [terra::rast()] object of the requested ET collection.
#'
#' @seealso
#' [read_tern()], [read_smips()], [read_asc()]
#'
#' @examplesIf interactive()
#' # Actual evapotranspiration (ETa) for June 2023 (mm/month)
#' r_eta <- read_aet("2023-06-01")
#' autoplot(r_eta)
#'
#' # January 2023 ET
#' r_jan <- read_aet("2023-01-01")
#'
#' # Quality assurance flags for June 2023
#' r_qa <- read_aet("2023-06-01", collection = "pixel_qa")
#'
#' # ET from February 2000 (earliest available)
#' r_early <- read_aet("2000-02-01")
#'
#' # Current/recent ET (within last month)
#' r_recent <- read_aet(Sys.Date())
#'
#' @references
#'   CMRSET portal:
#'   <https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
#'
#'   CMRSET DOI: <https://dx.doi.org/10.25901/gg27-ck96>
#'
#' @autoglobal
#' @export
read_aet <- function(
  date,
  collection = "ETa",
  api_key    = NULL,
  max_tries  = 3L,
  initial_delay = 1L
) {
  read_tern(
    "AET",
    date       = date,
    collection = collection,
    api_key    = api_key,
    max_tries  = max_tries,
    initial_delay = initial_delay
  )
}
