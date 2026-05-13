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


# -- Internal Soil Beta Diversity handler -----------------------------------

#' Internal handler for Soil Beta Diversity (\code{TERN/4a428d52})
#'
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_soil_diversity <- function(dots, api_key, max_tries, initial_delay) {
  collection <- if (!is.null(dots[["collection"]])) dots[["collection"]] else "Bacteria"
  axis       <- if (!is.null(dots[["axis"]])) as.integer(dots[["axis"]]) else 1L

  approved_collections <- c("Bacteria", "Fungi")
  collection <- rlang::arg_match(collection, approved_collections)

  if (!axis %in% 1L:3L) {
    cli::cli_abort("Soil Beta Diversity {.arg axis} must be 1, 2, or 3.")
  }

  fname <- sprintf("NMDS_%s_%d_%s_pred.tif", collection, axis, collection)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/slga/NationalMaps/Other/SoilBetaDiversity/%s",
    api_key, fname
  )
  .read_cog(full_url, max_tries, initial_delay)
}
