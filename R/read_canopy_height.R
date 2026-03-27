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
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
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
#'   <https://portal.tern.org.au/metadata/TERN/36c98155-c137-44b8-b4e0-6a3e824bbfba>
#'
#' @autoglobal
#' @export
read_canopy_height <- function(
  api_key       = get_key(),
  max_tries     = 3L,
  initial_delay = 1L
) {
  read_tern(
    "CANOPY",
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}
