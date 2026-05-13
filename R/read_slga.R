#' Read SLGA Soil Attributes from TERN
#'
#' Read Soil and Landscape Grid of Australia (\acronym{SLGA}) Cloud Optimised
#' GeoTIFF (\acronym{COG}) files from \acronym{TERN}.  Eight soil attributes
#' are available as static 90 m national products, each with six standard
#' depth layers and two statistics (estimated value or confidence interval).
#'
#' @section Supported attributes:
#' \describe{
#'   \item{\code{"AWC"}}{Available Water Capacity (mm)}
#'   \item{\code{"CLY"}}{Clay content (percent)}
#'   \item{\code{"SND"}}{Sand content (percent)}
#'   \item{\code{"SLT"}}{Silt content (percent)}
#'   \item{\code{"BDW"}}{Bulk Density whole earth (g/cm3)}
#'   \item{\code{"PHC"}}{pH (CaCl2)}
#'   \item{\code{"PHW"}}{pH (water)}
#'   \item{\code{"NTO"}}{Total Nitrogen (percent)}
#' }
#'
#' @section Depth layers:
#' Six standard \acronym{GlobalSoilMap} depth intervals are available
#' (values in cm):
#' \tabular{l}{
#'   \code{"000_005"} — 0--5 cm (default) \cr
#'   \code{"005_015"} — 5--15 cm \cr
#'   \code{"015_030"} — 15--30 cm \cr
#'   \code{"030_060"} — 30--60 cm \cr
#'   \code{"060_100"} — 60--100 cm \cr
#'   \code{"100_200"} — 100--200 cm \cr
#' }
#'
#' This is a convenience wrapper around
#' \code{read_tern(<attribute>, ...)}; see [read_tern()] for full
#' details and additional datasets.
#'
#' @param attribute One of \code{"AWC"}, \code{"CLY"}, \code{"SND"},
#'   \code{"SLT"}, \code{"BDW"}, \code{"PHC"}, \code{"PHW"}, or
#'   \code{"NTO"}.
#' @param depth One of \code{"000_005"} (default), \code{"005_015"},
#'   \code{"015_030"}, \code{"030_060"}, \code{"060_100"}, or
#'   \code{"100_200"}.
#' @param collection One of \code{"EV"} (estimated value, default) or
#'   \code{"CI"} (confidence interval).
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
#' # Read clay content at 0-5 cm depth
#' r <- read_slga("CLY")
#' autoplot(r)
#'
#' # Read available water capacity at 15-30 cm
#' r_awc <- read_slga("AWC", depth = "015_030")
#'
#' # Read pH (CaCl2) confidence interval at 30-60 cm
#' r_phc <- read_slga("PHC", depth = "030_060", collection = "CI")
#'
#' @returns A [terra::rast()] object of the national SLGA mosaic for the
#'   requested attribute, depth, and statistic.
#'
#' @references
#'   AWC: <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/482301c2-2837-4b0b-bf95-4883a04e5ff7>
#'
#'   SLGA: <https://esoil.io/TERNLandscapes/Public/Pages/SLGA/>
#'
#' @autoglobal
#' @export
read_slga <- function(
  attribute,
  depth         = "000_005",
  collection    = "EV",
  api_key       = get_key(),
  max_tries     = NULL,
  initial_delay = NULL
) {
  approved_attrs <- c("AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO")
  attribute <- toupper(attribute)
  attribute <- rlang::arg_match(attribute, approved_attrs)
  read_tern(
    attribute,
    depth         = depth,
    collection    = collection,
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}


# -- SLGA attribute registry -------------------------------------------------

#' SLGA attribute configuration registry
#'
#' Named list mapping normalised dispatch IDs to their SLGA file-naming
#' parameters: directory name, file prefix, version, release date, and
#' filename suffix.
#'
#' @format A named \code{list} of \code{list}s.
#' @autoglobal
#' @dev
.slga_config <- list(
  "482301c2" = list(dir = "AWC", prefix = "AWC", version = "v2",
                    date = "20210614", suffix = "AU_TRN_N"),
  "slga_cly" = list(dir = "CLY", prefix = "CLY", version = "v2",
                    date = "20210902", suffix = "AU_TRN_N"),
  "slga_snd" = list(dir = "SND", prefix = "SND", version = "v2",
                    date = "20210902", suffix = "AU_TRN_N"),
  "slga_slt" = list(dir = "SLT", prefix = "SLT", version = "v2",
                    date = "20210902", suffix = "AU_TRN_N"),
  "slga_bdw" = list(dir = "BDW", prefix = "BDW", version = "v2",
                    date = "20230607", suffix = "AU_TRN_N"),
  "slga_phc" = list(dir = "pHc", prefix = "PHC", version = "v2",
                    date = "20210913", suffix = "AU_NAT_C"),
  "slga_phw" = list(dir = "PHW", prefix = "PHW", version = "v1",
                    date = "20220520", suffix = "AU_TRN_N"),
  "slga_nto" = list(dir = "NTO", prefix = "NTO", version = "v2",
                    date = "20231101", suffix = "AU_NAT_C")
)


# -- Internal SLGA handler ---------------------------------------------------

#' Internal handler for SLGA soil attributes
#'
#' A generic handler that covers all eight SLGA soil attributes.  Each
#' attribute has a fixed file-naming pattern encoded in [.slga_config].
#'
#' @param did Normalised dispatch ID (e.g.\ \code{"482301c2"}, \code{"slga_cly"}).
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_slga <- function(did, dots, api_key, max_tries, initial_delay) {
  cfg <- .slga_config[[did]]

  depth      <- if (!is.null(dots[["depth"]])) dots[["depth"]] else "000_005"
  collection <- if (!is.null(dots[["collection"]])) dots[["collection"]] else "EV"

  approved_depths <- c("000_005", "005_015", "015_030",
                       "030_060", "060_100", "100_200")
  depth <- rlang::arg_match(depth, approved_depths)

  approved_stats <- c("EV", "CI")
  collection <- rlang::arg_match(collection, approved_stats)

  fname <- sprintf("%s_%s_%s_N_P_%s_%s.tif",
                   cfg$prefix, depth, collection, cfg$suffix, cfg$date)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/%s/%s/%s",
    api_key, cfg$dir, cfg$version, fname
  )
  .read_cog(full_url, max_tries, initial_delay)
}
