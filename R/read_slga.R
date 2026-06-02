#' Read SLGA Soil Attributes from TERN
#'
#' Wrapper around [read_tern()] for retrieving various Soil and Landscape
#' Grid of Australia (SLGA) datasets from the TERN Data Portal. Eight soil
#' attributes are available at 90m X 90m spatial resolution across Australia,
#' each with six standard depth layers (0-5cm, 5-15cm, 15-30cm, 30-60cm,
#' 60-100cm, 100-200cm) and two statistics (estimated value, confidence
#' interval).
#'
#' @section Supported soil attributes:
#' \describe{
#'   \item{\code{"AWC"}}{Available Water Capacity (%)}
#'   \item{\code{"CLY"}}{Clay content (%)}
#'   \item{\code{"SND"}}{Sand content (%)}
#'   \item{\code{"SLT"}}{Silt content (%)}
#'   \item{\code{"BDW"}}{Bulk Density (Whole Earth) (g/cm3)}
#'   \item{\code{"PHC"}}{pH (of 1:5 soil/0.01M CaCl2 extract)}
#'   \item{\code{"PHW"}}{pH (of 1:5 soil water solution)}
#'   \item{\code{"NTO"}}{Total Nitrogen (%)}
#' }
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
#' A [terra::SpatRaster] object of the requested SLGA soil attribute.
#'
#' @seealso
#' [read_tern()]
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
#' @references
#' \describe{
#'   \item{**AWC: Available Volumetric Water Capacity**}{
#'     Searle, R., Nimalka Somarathna, P. & Malone, B. (2023). Soil and
#'     Landscape Grid National Soil Attribute Maps - Available Volumetric
#'     Water Capacity (Percent) (3 arc second resolution) Version 2.
#'     Version 2.0. Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/4jwj-na34}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/482301c2-b9a1-4345-b142-815f9b37890a>
#'   }
#'   \item{**CLY: Clay content**}{
#'     Malone, B. & Searle, R. (2022). Soil and Landscape Grid National
#'     Soil Attribute Maps - Clay (3" resolution) - Release 2. Version 2.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/hc4s-3130}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/f95dc442-013b-4fad-b31f-91ba86fbe7f5>
#'   }
#'   \item{**SND: Sand content**}{
#'     Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
#'     Attribute Maps - Sand (3" resolution) - Release 2. Version 2.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/rjmy-pa10}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4224ddff-5fb4-4170-b5ea-c0c500599700>
#'   }
#'   \item{**SLT: Silt content**}{
#'     Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
#'     Attribute Maps - Silt (3" resolution) - Release 2. Version 2.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/2ew1-0w57}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/11375f04-b5cd-46a7-bcac-0e83fcb58605>
#'   }
#'   \item{**BDW: Bulk Density (Whole Earth)**}{
#'     Malone, B. (2023). Soil and Landscape Grid National Soil Attribute
#'     Maps - Bulk Density - Whole Earth - Release 2. Version 2.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/gxyn-pd07}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/95978aec-6ba8-446b-a721-2b875d9f61a8>
#'   }
#'   \item{**PHC: pH (of 1:5 soil/0.01M CaCl2 extract)**}{
#'     Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
#'     Attribute Maps - pH - Calcium Chloride (3" resolution) - Release 2.
#'     Version 2. Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/7320-hw30}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/258afc98-7407-4781-b241-cb0293b4b8aa>
#'   }
#'   \item{**PHW: pH (of 1:5 soil water solution)**}{
#'     Malone, B. (2022). Soil and Landscape Grid National Soil Attribute
#'     Maps - pH (Water) (3" resolution) - Release 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/37z2-0q10}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/c37439a5-e622-44ab-9c24-bfd632d8203c>
#'   }
#'   \item{**NTO: Total nitrogen**}{
#'     Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
#'     Attribute Maps - Total Nitrogen (3" resolution) - Release 2. Version 2.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/pm2n-ww12}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/e9484508-c705-4c23-9195-f26d64b9d4f1>
#'   }
#' }
#'
#' @autoglobal
#' @export
read_slga <- function(
  attribute,
  depth = "000_005",
  collection = "EV",
  api_key = get_key(),
  max_tries = NULL,
  initial_delay = NULL
) {
  approved_attrs <- c("AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO")
  attribute <- toupper(attribute)
  attribute <- rlang::arg_match(attribute, approved_attrs)
  read_tern(
    attribute,
    depth = depth,
    collection = collection,
    api_key = api_key,
    max_tries = max_tries,
    initial_delay = initial_delay
  )
}


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
  #FIXME: Russell (02/06) Why is the AWC dispatch ID an alphanumeric
  #  instead of just "slga_awc" like the others?
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


#' Internal handler for retrieving SLGA soil attributes
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

  depth <- if (!is.null(dots[["depth"]])) {
    dots[["depth"]]
  } else {
    "000_005"
  }
  collection <- if (!is.null(dots[["collection"]])){
    dots[["collection"]]
  } else {
    "EV"
  }

  approved_depths <- c("000_005", "005_015", "015_030", "030_060", "060_100",
                       "100_200")
  depth <- rlang::arg_match(depth, approved_depths)

  #FIXME: Russell (02/06) as noted by Wasin in Issue #45, the "CI" statistic
  #  doesn't work. We need to return either of the lower or upper confidence
  #  interval limits separately.
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
