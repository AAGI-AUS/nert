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
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
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
#'   AWC: <https://portal.tern.org.au/metadata/TERN/482301c2-2837-4b0b-bf95-4883a04e5ff7>
#'
#'   SLGA: <https://www.clw.csiro.au/aclep/soilandlandscapegrid/>
#'
#' @autoglobal
#' @export
read_slga <- function(
  attribute,
  depth         = "000_005",
  collection    = "EV",
  api_key       = get_key(),
  max_tries     = 3L,
  initial_delay = 1L
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
