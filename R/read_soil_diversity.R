#' Read Soil Beta Diversity from TERN
#'
#' Wrapper around [read_tern()] for retrieving the v1.0 datasets for
#' soil bacteria and soil fungi Beta Diversity from the TERN Data Portal.
#' The Beta Diversity datasets were constructed using Digital Soil Mapping
#' techniques together with Biome of Australia Soil Environments (BASE)
#' DNA sequences, and provide Non-metric MultiDimensional Scaling (NMDS)
#' axes for soil bacteria and fungi at 90m X 90m spatial resolution across
#' Australia.
#'
#' @param collection One of \code{"Bacteria"} (default) or \code{"Fungi"}.
#' @param axis \acronym{NMDS} axis number: \code{1} (default), \code{2}, or
#'   \code{3}.
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key. Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}. See [get_key()] for setup.
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
#' A [terra::SpatRaster] object of the requested Beta Diversity NMDS axis.
#'
#' @seealso
#' [read_tern()]
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
#' @references
#'   Dobarco, M., Wadoux, A. & Xue, P. (2024). Soil and Landscape Grid National
#'   Soil Attribute Maps - Soil Bacteria and Fungi Beta Diversity (3"
#'   resolution) - Release 1. Version 1.0. Terrestrial Ecosystem Research
#'   Network. (Dataset). \doi{10.25919/4x7n-y874}.
#'
#'   TERN Soil Beta Diversity Point-of-truth metadata URL:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4a428d52-dda6-4097-8dd9-d3ec63973029>
#'
#'
#' @export
read_soil_diversity <- function(
  collection = "Bacteria",
  axis = 1L,
  api_key = get_key(),
  max_tries = NULL,
  initial_delay = NULL
) {
  return(read_tern(
    "SOILDIV",
    collection = collection,
    axis = axis,
    api_key = api_key,
    max_tries = max_tries,
    initial_delay = initial_delay
  ))
}


#' Internal handler for retrieving Soil Beta Diversity datasets
#'
#' @param did Normalised 8-char dataset ID (unused; uniform handler signature).
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#'
#' @dev
.read_tern_soil_diversity <- function(
  did,
  dots,
  api_key,
  max_tries,
  initial_delay
) {
  collection <- if (!is.null(dots[["collection"]])) {
    dots[["collection"]]
  } else {
    "Bacteria"
  }
  axis <- if (!is.null(dots[["axis"]])) {
    as.integer(dots[["axis"]])
  } else {
    1L
  }

  approved_collections <- c("Bacteria", "Fungi")
  collection <- rlang::arg_match(collection, approved_collections)

  if (!axis %in% 1L:3L) {
    cli::cli_abort("Soil Beta Diversity {.arg axis} must be 1, 2, or 3.")
  }

  fname <- sprintf("NMDS_%s_%d_%s_pred.tif", collection, axis, collection)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/slga/NationalMaps/Other/SoilBetaDiversity/%s",
    api_key,
    fname
  )
  return(.read_cog(full_url, max_tries, initial_delay))
}
