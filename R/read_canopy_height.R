#' Read Canopy Height from TERN
#'
#' Read the OzTreeMap Canopy Height composite Cloud Optimised GeoTIFF
#' (\acronym{COG}) from \acronym{TERN}.  This product provides a nationwide
#' canopy height map at 30 m resolution derived from Landsat imagery.
#'
#' This is a single static product --- no date or collection arguments are
#' required.
#'
#' This is a convenience wrapper around
#' \code{read_tern("CANOPY")}; see [read_tern()] for full details and
#' additional datasets.
#'
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection via [get_key()].
#' @param max_tries Maximum number of download retries before an error is
#'   raised.  When \code{NULL} (default), resolved from
#'   \code{getOption("nert.max_tries", 3L)}.  Pass an integer to override
#'   for a single call.
#' @param initial_delay Initial retry delay in seconds (doubles with each
#'   attempt).  When \code{NULL} (default), resolved from
#'   \code{getOption("nert.initial_delay", 1L)}.  Pass an integer to
#'   override for a single call.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#' r <- read_canopy_height()
#' autoplot(r)
#'
#' @returns A [terra::rast()] object of the national OzTreeMap canopy height
#'   composite.
#'
#' @references
#'   TERN GeoNetwork record:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/36c98155-c137-44b8-b4e0-6a3e824bbfba>
#'
#' @autoglobal
#' @export
read_canopy_height <- function(
  api_key       = get_key(),
  max_tries     = NULL,
  initial_delay = NULL
) {
  read_tern(
    "CANOPY",
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}
