#' Read Australian Soil Classification (ASC) Data from TERN
#'
#' @description
#' Wrapper around [read_tern()] for retrieving Australian Soil Classification
#' (\acronym{ASC}) soil order classes from the TERN Data Portal. The ASC dataset
#' provides a comprehensive map at 90m X 90m spatial resolution across
#' Australia, mapping each spatial pixel to one of 14 soil order classes using
#' a Random Forest classifier. The dataset also provides a confusion index
#' raster that estimates the uncertainty (between 0.0 and 1.0) associated with
#' the classification.
#'
#' @param collection The ASC dataset collection variant (default \code{"EV"}). Options:
#'   \describe{
#'     \item{\code{"EV"}}{**(Estimated) Soil Order Class** (character). The
#'       estimated ASC soil order class. Each pixel of the raster maps to one
#'       of 14 soil order classes: Vertosol, Sodosol, Dermosol, Chromosol,
#'       Ferrosol, Kurosol, Tenosol, Kandosol, Hydrosol, Podosol, Rudosol,
#'       Calcarasol, Organosol, Anthroposol.}
#'     \item{\code{"CI"}}{**Confusion Index** (0-1). A unitless index between
#'       0.0 and 1.0, approximating the uncertainty of the Random Forest
#'       classification for the soil order at each pixel. (A higher value of the
#'       confusion index means that the classification at that pixel is more
#'       uncertain.)}
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
#' A [terra::SpatRaster] object containing the soil order classes (or the
#' values of the confusion index).
#'
#' @seealso
#' [read_tern()]
#'
#' @examplesIf interactive()
#' # Australian Soil Classification (soil orders as character)
#' r_asc <- read_asc()
#' autoplot(r_asc)
#'
#' # Confusion Index (uncertainty of the classification, higher=more uncertain)
#' r_ci <- read_asc(collection = "CI")
#' autoplot(r_ci)
#'
#' @references
#'   Searle, R. (2021). Australian Soil Classification Map. Version 1.
#'   Terrestrial Ecosystem Research Network. (Dataset).
#'   \doi{10.25901/edyr-wg85}.
#'
#'   TERN ASC Point-of-truth metadata URL:
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/15728dba-b49c-4da5-9073-13d8abe67d7c>
#'
#' 
#' @export
read_asc <- function(
  collection = "EV",
  api_key = get_key(),
  max_tries = NULL,
  initial_delay = NULL
) {
  return(read_tern(
    "ASC",
    collection = collection,
    api_key = api_key,
    max_tries = max_tries,
    initial_delay = initial_delay
  ))
}


#' Internal handler for retrieving ASC rasters
#'
#' @param did Normalised 8-char dataset ID (unused; uniform handler signature).
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#' 
#' @dev
.read_tern_asc <- function(did, dots, api_key, max_tries, initial_delay) {
  collection <- if (!is.null(dots[["collection"]])) {
    dots[["collection"]]
  } else {
    "EV"
  }

  approved <- c("EV", "CI")
  collection <- rlang::arg_match(collection, approved)

  dl_file <- paste0("ASC_", collection, "_C_P_AU_TRN_N.cog.tif")
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/%s",
    api_key,
    dl_file
  )
  return(.read_cog(full_url, max_tries, initial_delay))
}
