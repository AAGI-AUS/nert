#' Read SLGA Soil Attributes from TERN
#'
#' Wrapper around [read_tern()] for retrieving various Soil and Landscape
#' Grid of Australia (SLGA) datasets from the TERN Data Portal. 14 soil
#' attributes are available at 90m X 90m spatial resolution across Australia,
#' each with six standard depth layers (0-5cm, 5-15cm, 15-30cm, 30-60cm,
#' 60-100cm, 100-200cm) and three statistics (estimated value, and the lower
#' (05) and upper (95) percentile limits for the confidence interval).
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
#'   \item{\code{"AVP"}}{Available soil Phosphorus (mg/kg)}
#'   \item{\code{"PTO"}}{Total soil Phosphorus (%)}
#'   \item{\code{"CEC"}}{Cation Exchange Capacity (meq/100g)}
#'   \item{\code{"ECE"}}{Effective Cation Exchange Capacity (meq/100g)}
#'   \item{\code{"DUL"}}{Drained Upper Limit volumetric water content (%)}
#'   \item{\code{"L15"}}{15 Bar Lower Limit volumetric water content (%)}
#' }
#'
#' @param attribute One of \code{"AWC"}, \code{"CLY"}, \code{"SND"},
#'   \code{"SLT"}, \code{"BDW"}, \code{"PHC"}, \code{"PHW"}, \code{"NTO"},
#'   \code{"AVP"}, \code{"PTO"}, \code{"CEC"}, \code{"ECE"}, \code{"DUL"}, or
#'   \code{"L15"}.
#' @param depth One of \code{"000_005"} (default), \code{"005_015"},
#'   \code{"015_030"}, \code{"030_060"}, \code{"060_100"}, or
#'   \code{"100_200"}.
#' @param collection One of \code{"EV"} (estimated value, default),
#'   \code{"05"} (lower percentile limit for the 95% confidence interval) or
#'   \code{"95"} (upper percentile limit for the confidence interval).
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
#' # Read clay content at 0-5 cm depth (default depth)
#' r <- read_slga("CLY")
#' autoplot(r)
#'
#' # Read available water capacity at 15-30 cm
#' r_awc <- read_slga("AWC", depth = "015_030")
#'
#' # Read pH (CaCl2) confidence interval at 30-60 cm
#' r_phc_low <- read_slga("PHC", depth = "030_060", collection = "05")
#' r_phc_up <- read_slga("PHC", depth = "030_060", collection = "95")
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
#'   \item{**AVP: Available phosphorus**}{
#'     Zund, P. (2022). Soil and Landscape Grid National Soil Attribute Maps
#'     - Available Phosphorus (3" resolution) - Release 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/6qzh-b979}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/c6ef289b-1ca8-4e53-b8b4-aa97e4706c63>
#'   }
#'   \item{**PTO: Total phosphorus**}{
#'     Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
#'     Attribute Maps - Total Phosphorus (3" resolution) - Release 2.
#'     Version 2. Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/7j78-md43}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/be382e63-5ff6-40a9-930f-c84655a5bd87>
#'   }
#'   \item{**CEC: Cation exchange capacity**}{
#'     Malone, B. (2024). Soil and Landscape Grid National Soil Attribute Maps
#'     - Cation Exchange Capacity (3" resolution) - Release 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/pkva-gf85}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/5b4b2991-bfa6-41df-be33-7009a5d0a5b0>
#'   }
#'   \item{**ECE: Effective cation exchange capacity**}{
#'     Viscarra Rossel, R., Chen, C., Grundy, M., Searle, R., Clifford, D.,
#'     Odgers, N., Holmes, K., Griffin, T., Liddicoat, C. & Kidd, D. (2014).
#'     Soil and Landscape Grid National Soil Attribute Maps - Effective Cation
#'     Exchange Capacity (3" resolution) - Release 1. Version 1. Terrestrial
#'     Ecosystem Research Network. (Dataset).
#'     \doi{10.4225/08/546F091C11777}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/0d27cf8b-6627-4f33-8398-1b525bc1a210>
#'   }
#'   \item{**DUL: Drained upper limit volumetric water content**}{
#'     Searle, R. & Nimalka Somarathna, P. (2022). Soil and Landscape Grid
#'     National Soil Attribute Maps - Drained Upper Limit Volumetric Water
#'     Content (Percent) (3 arc second resolution) Version 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/jnvd-3a26}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/de9ddc12-b8e4-4ff2-99c4-390227a848aa>
#'   }
#'   \item{**L15: 15 bar lower limit volumetric water content**}{
#'     Searle, R. & Nimalka Somarathna, P. (2022). Soil and Landscape Grid
#'     National Soil Attribute Maps - 15 Bar Lower Limit Volumetric Water
#'     Content (Percent) (3 arc second resolution) Version 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/awp8-nv68}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4443f5df-a0b2-4352-b44b-83f7feb1e27d>
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
  approved_attrs <- c(
    "AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO", "AVP", "PTO",
    "CEC", "ECE", "DUL", "L15"
  )
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
  "482301c2" = list(dir = "AWC", prefix = "AWC", version = "v2",
                    date = "20210614", suffix = "AU_TRN_N"),
  "f95dc442" = list(dir = "CLY", prefix = "CLY", version = "v2",
                    date = "20210902", suffix = "AU_TRN_N"),
  "4224ddff" = list(dir = "SND", prefix = "SND", version = "v2",
                    date = "20210902", suffix = "AU_TRN_N"),
  "11375f04" = list(dir = "SLT", prefix = "SLT", version = "v2",
                    date = "20210902", suffix = "AU_TRN_N"),
  "95978aec" = list(dir = "BDW", prefix = "BDW", version = "v2",
                    date = "20230607", suffix = "AU_TRN_N"),
  "258afc98" = list(dir = "pHc", prefix = "PHC", version = "v2",
                    date = "20210913", suffix = "AU_NAT_C"),
  "c37439a5" = list(dir = "PHW", prefix = "PHW", version = "v1",
                    date = "20220520", suffix = "AU_TRN_N"),
  "e9484508" = list(dir = "NTO", prefix = "NTO", version = "v2",
                    date = "20231101", suffix = "AU_NAT_C"),
  "c6ef289b" = list(dir = "AVP", prefix = "AVP", version = "v1",
                    date = "20220826", suffix = "AU_TRN_N"),
  "be382e63" = list(dir = "PTO", prefix = "PTO", version = "v2",
                    date = "20231101", suffix = "AU_NAT_C"),
  "5b4b2991" = list(dir = "CEC", prefix = "CEC", version = "v1",
                    date = "20220826", suffix = "AU_TRN_N"),
  "0d27cf8b" = list(dir = "ECE", prefix = "ECE", version = "v1",
                    date = "20140801", suffix = "AU_NAT_C"),
  "de9ddc12" = list(dir = "DUL", prefix = "DUL", version = "v1",
                    date = "20210614", suffix = "AU_TRN_N"),
  "4443f5df" = list(dir = "L15", prefix = "L15", version = "v1",
                    date = "20210614", suffix = "AU_TRN_N")
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
  collection <- if (!is.null(dots[["collection"]])) {
    dots[["collection"]]
  } else {
    "EV"
  }

  approved_depths <- c("000_005", "005_015", "015_030", "030_060", "060_100",
                       "100_200")
  depth <- rlang::arg_match(depth, approved_depths)

  approved_stats <- c("EV", "05", "95")
  collection <- rlang::arg_match(collection, approved_stats)

  fname <- sprintf("%s_%s_%s_N_P_%s_%s.tif",
                   cfg$prefix, depth, collection, cfg$suffix, cfg$date)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/slga/NationalMaps/SoilAndLandscapeGrid/%s/%s/%s",
    api_key, cfg$dir, cfg$version, fname
  )
  .read_cog(full_url, max_tries, initial_delay)
}
