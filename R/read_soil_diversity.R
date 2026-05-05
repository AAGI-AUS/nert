#' Read Soil Beta Diversity from TERN
#'
#' Read Soil Beta Diversity Cloud Optimised GeoTIFF (\acronym{COG}) files
#' from \acronym{TERN}.  This product provides Non-metric Multidimensional
#' Scaling (\acronym{NMDS}) axes 1--3 for soil Bacteria and Fungi
#' communities across Australia at 90 m resolution.
#'
#' @section Collections:
#' \describe{
#'   \item{\code{"Bacteria"}}{Bacterial community beta diversity (default).}
#'   \item{\code{"Fungi"}}{Fungal community beta diversity.}
#' }
#'
#' This is a static product (no date argument required).
#'
#' This is a convenience wrapper around
#' \code{read_tern("SOILDIV", ...)}; see [read_tern()] for full
#' details and additional datasets.
#'
#' @param collection One of \code{"Bacteria"} (default) or \code{"Fungi"}.
#' @param axis \acronym{NMDS} axis number: \code{1} (default), \code{2}, or
#'   \code{3}.
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
#' # Read bacterial diversity NMDS axis 1
#' r <- read_soil_diversity()
#' autoplot(r)
#'
#' # Read fungal diversity NMDS axis 2
#' r_f2 <- read_soil_diversity(collection = "Fungi", axis = 2)
#' autoplot(r_f2)
#'
#' @returns A [terra::rast()] object of the national Soil Beta Diversity
#'   mosaic for the requested organism and NMDS axis.
#'
#' @references
#'   TERN GeoNetwork record:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4a428d52-d15c-4bfc-8a67-80697f8c0aa0>
#'
#' @autoglobal
#' @export
read_soil_diversity <- function(
  collection    = "Bacteria",
  axis          = 1L,
  api_key       = get_key(),
  max_tries     = NULL,
  initial_delay = NULL
) {
  read_tern(
    "SOILDIV",
    collection    = collection,
    axis          = axis,
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}
