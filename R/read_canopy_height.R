#' Read OzTreeMap Canopy Height Data from TERN
#'
#' @description
#' Wrapper around [read_tern()] for retrieving the OzTreeMap Best-Pick
#' Canopy Height model dataset from the TERN Data Portal. The model estimates
#' the vegetation canopy height (in metres) at 30m X 30m spatial resolution
#' across Australia, based on underlying ML-derived vegetation models
#' tuned to variable time periods between 2007 and 2020.
#'
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
#' A [terra::SpatRaster] object of the requested vegetation canopy height.
#' Note that the raster returned by this function uses the Australian Albers
#' (EPSG:3577) coordinate reference system, not WGS84 (EPSG:4326).
#'
#' @seealso
#' [read_tern()]
#'
#' @examplesIf interactive()
#' r <- read_canopy_height()
#' autoplot(r)
#'
#' @references
#'   Pucino, N., McVicar, T., Levick, S. & Albert van Dijk (2025).
#'   Australia-Wide 30 m Machine Learning-Derived Canopy Height Models
#'   Composites: Best Pick and Median. Version 1. Terrestrial Ecosystem
#'   Research Network. (Dataset). \doi{10.25901/xqv7-jk46}.
#'
#'   TERN Canopy Height model Point-of-truth metadata URL:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/36c98155-39c8-4eec-9070-a978933f3fa3>
#'
#'
#' @export
read_canopy_height <- function(
  api_key = get_key(),
  max_tries = NULL,
  initial_delay = NULL
) {
  return(read_tern(
    "CANOPY",
    api_key = api_key,
    max_tries = max_tries,
    initial_delay = initial_delay
  ))
}


#' Internal handler for retrieving Canopy Height data
#'
#' @param did Normalised 8-char dataset ID (unused; uniform handler signature).
#' @param dots Named list of \code{...} args from [read_tern()] (unused).
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#'
#' @dev
.read_tern_canopy_height <- function(
  did,
  dots,
  api_key,
  max_tries,
  initial_delay
) {
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/OzTreeMap/CanopyHeightComposite/best_pick_files_bhLNnun.tif",
    api_key
  )
  return(.read_cog(full_url, max_tries, initial_delay))
}
