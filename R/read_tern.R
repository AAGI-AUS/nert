#' Read TERN COG Datasets
#'
#' A unified interface for reading Cloud Optimised GeoTIFF (\acronym{COG})
#' data from the \acronym{TERN} Data Portal. This function effectively
#' dispatches to dataset-specific handlers based on the dataset requested
#' (e.g., SMIPS, SLGA, AET, and so on), and passes any additional arguments
#' through `...`.  The returned object is a [terra::SpatRaster] that
#' can be plotted, cropped, or extracted with standard \pkg{terra} or
#' \pkg{tidyterra} workflows.
#'
#' @section Dataset aliases:
#' In addition to full \acronym{TERN} portal keys and 8-character prefixes,
#' `read_tern()` accepts short human-readable aliases (case-insensitive):
#' \tabular{lll}{
#'   \strong{Alias} \tab \strong{Dataset ID} \tab \strong{Description} \cr
#'   `"SMIPS"` \tab `TERN/d1995ee8` \tab Daily soil moisture (~1 km) \cr
#'   `"ASC"` \tab `TERN/15728dba` \tab Australian Soil Classification (90 m) \cr
#'   `"AET"` \tab `TERN/9fefa68b` \tab Monthly evapotranspiration via CMRSET (30 m) \cr
#'   `"AWC"` \tab `TERN/482301c2` \tab Available Water Capacity (90 m) \cr
#'   `"CLY"` \tab `TERN/f95dc442` \tab Clay content (90 m) \cr
#'   `"SND"` \tab `TERN/4224ddff` \tab Sand content (90 m) \cr
#'   `"SLT"` \tab `TERN/11375f04` \tab Silt content (90 m) \cr
#'   `"BDW"` \tab `TERN/95978aec` \tab Bulk density whole earth (90 m) \cr
#'   `"PHC"` \tab `TERN/258afc98` \tab pH CaCl2 (90 m) \cr
#'   `"PHW"` \tab `TERN/c37439a5` \tab pH water (90 m) \cr
#'   `"NTO"` \tab `TERN/e9484508` \tab Total Nitrogen (90 m) \cr
#'   `"AVP"` \tab `TERN/c6ef289b` \tab Available Phosphorus (90 m) \cr
#'   `"PTO"` \tab `TERN/be382e63` \tab Total Phosphorus (90 m) \cr
#'   `"CEC"` \tab `TERN/5b4b2991` \tab Cation Exchange Capacity (90 m) \cr
#'   `"ECE"` \tab `TERN/0d27cf8b` \tab Effective Cation Exchange Capacity (90 m) \cr
#'   `"DUL"` \tab `TERN/de9ddc12` \tab Drained Upper Limit water content (90 m) \cr
#'   `"L15"` \tab `TERN/4443f5df` \tab 15 Bar Lower Limit water content (90 m) \cr
#'   `"SOILDIV"` \tab `TERN/4a428d52` \tab Soil Beta Diversity (90 m) \cr
#'   `"CANOPY"` \tab `TERN/36c98155` \tab Canopy Height (30 m) \cr
#'   `"PHENOLOGY"` \tab `TERN/2bb0c81a` \tab Land Surface Phenology (500 m) \cr
#' }
#' Convenience wrappers [read_smips()], [read_asc()], [read_aet()],
#' [read_slga()], [read_soil_diversity()], [read_canopy_height()], and
#' [read_phenology()] are also provided for simplified access to each dataset.
#'
#' @section SMIPS — daily soil moisture (`"SMIPS"`):
#' \describe{
#'   \item{`date`}{Required. A single day to query, _e.g._
#'     `"2024-01-15"` or `as.Date("2024-01-15")`.  Both
#'     `character` and `Date` classes are accepted.}
#'   \item{`collection`}{One of `"totalbucket"` (default),
#'     `"SMindex"`, `"bucket1"`, `"bucket2"`,
#'     `"deepD"`, or `"runoff"`.}
#' }
#' Data availability: `totalbucket` and `SMindex` from 2005-01-01;
#' `bucket1`, `bucket2`, `deepD`, and `runoff` from 2015-01-01; to today.
#' (Updated regularly.)
#'
#' @section ASC -- Australian Soil Classification (`"ASC"`):
#' \describe{
#'   \item{`collection`}{One of `"EV"` (estimated soil order
#'     class, default) or `"CI"` (confusion index -- a measure of the
#'     classification uncertainty).}
#' }
#'
#' @section AET -- Actual Evapotranspiration/CMRSET (`"AET"`):
#' \describe{
#'   \item{`date`}{Required. A month to query, _e.g._
#'     `"2023-06-01"` or `as.Date("2023-06-01")`.  Both
#'     `character` and `Date` classes are accepted.  The value is
#'     snapped to the first of the month.}
#'   \item{`collection`}{One of `"ETa"` (primary AET band in
#'     mm/month, default) or `"pixel_qa"` (quality assurance attributes).}
#' }
#' Data availability: 1987-05-01 onward, monthly.
#'
#' @section SLGA soil attributes (`"AWC"`, `"CLY"`, etc.):
#' 14 \acronym{SLGA} (Soil and Landscape Grid of Australia) soil
#' attributes are available as static 90 m products, each with six standard
#' depth layers and three statistics:
#' \describe{
#'   \item{`depth`}{One of `"000_005"` (default), `"005_015"`,
#'     `"015_030"`, `"030_060"`, `"060_100"`, or
#'     `"100_200"` (cm).}
#'   \item{`collection`}{One of `"EV"` (estimated value, default),
#'     `"05"` (lower percentile limit for the 95% confidence interval)
#'     or `"95"` (upper percentile limit for the confidence interval).}
#' }
#' Supported attributes (use as the `dataset_id` alias):
#' \describe{
#'   \item{`"AWC"`}{Available Water Capacity (percent)}
#'   \item{`"CLY"`}{Clay content (percent)}
#'   \item{`"SND"`}{Sand content (percent)}
#'   \item{`"SLT"`}{Silt content (percent)}
#'   \item{`"BDW"`}{Bulk Density whole earth (g/cm3)}
#'   \item{`"PHC"`}{pH (CaCl2)}
#'   \item{`"PHW"`}{pH (water)}
#'   \item{`"NTO"`}{Total Nitrogen (percent)}
#'   \item{`"AVP"`}{Available Phosphorus (mg/kg)}
#'   \item{`"PTO"`}{Total Phosphorus (percent)}
#'   \item{`"CEC"`}{Cation Exchange Capacity (meq/100g)}
#'   \item{`"ECE"`}{Effective Cation Exchange Capacity (meq/100g)}
#'   \item{`"DUL"`}{Drained Upper Limit volumetric water content (percent)}
#'   \item{`"L15"`}{15 Bar Lower Limit volumetric water content (percent)}
#' }
#'
#' @section Soil Beta Diversity (`"SOILDIV"`):
#' \describe{
#'   \item{`collection`}{One of `"Bacteria"` (default) or
#'     `"Fungi"`.}
#'   \item{`axis`}{NMDS axis: `1` (default), `2`, or
#'     `3`.}
#' }
#'
#' @section Canopy Height (`"CANOPY"`):
#' Single static 30 m X 30 m best-pick canopy height model composite,
#' from the OzTreeMap project. No function arguments required.
#'
#' @section Land Surface Phenology (`"PHENOLOGY"`):
#' \describe{
#'   \item{`year`}{Required. An integer year (2003--2018).}
#'   \item{`season`}{Season number: `1` (default) or `2`.}
#'   \item{`collection`}{Phenology metric — one of `"SGS"`
#'     (Start of Growing Season, default), `"PGS"` (Peak of Growing Season),
#'     `"EGS"` (End of Growing Season), `"LGS"` (Length of Growing Season),
#'     `"EVI1"` (Minimum EVI before peak), `"EVI2"` (Minimum EVI after peak),
#'     `"EVIP"` (EVI at Peak of Growing Season),
#'     `"EVII"` (Integral of EVI under growing season curve),
#'     `"SGS_month"` (Start of Growing Season, monthly resolution),
#'     `"PGS_month"` (Peak of the Growing Season, monthly resolution),
#'     `"EGS_month"` (End of Growing Season, monthly resolution).}
#' }
#'
#' @section Datasets not accessible:
#' The following datasets are tracked in the \acronym{TERN} catalogue but
#' cannot be accessed via COG HTTP range requests:
#' \itemize{
#'   \item `TERN/0997cb3c` — Seasonal Fractional Cover (Landsat)
#'   \item `TERN/fe9d86e1` — Seasonal Ground Cover (Landsat)
#' }
#' Datasets with integration level L2 or higher (e.g.\ AusEFlux via
#' \acronym{THREDDS}/OPeNDAP, GEE-based products, site-level API streams)
#' cannot be read via simple COG HTTP range requests and are outside the
#' current scope of \pkg{nert}.
#'
#' @param dataset_id A `character` string identifying the dataset.
#'   Accepts a short alias, the full \acronym{TERN} portal key (e.g.\
#'   `"TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0"`), or the
#'   8-character key prefix (e.g.\ `"TERN/d1995ee8"`).  See the
#'   \strong{Dataset aliases} section for the complete table of supported
#'   aliases.
#' @param ... Dataset-specific arguments — `date`, `collection`,
#'   etc.  See the relevant section above for each dataset.
#' @param api_key A `character` string containing your \acronym{TERN}
#'   \acronym{API} key. Defaults to automatic detection from your
#'   `.Renviron` or `.Rprofile`.  See [get_key()] for setup.
#' @param max_tries Maximum number of download retries before an error is
#'   raised. Default=`NULL`, in which case the maximum retry number is
#'   resolved from the option `nert.max_tries` if that option exists.
#'   (Defaults to 3 retries if `nert.max_tries` has not been set.)
#' @param initial_delay Initial retry delay in seconds (doubles with each
#'   attempt). Default=`NULL`, in which case the initial delay is
#'   resolved from the option `nert.initial_delay` if that option exists.
#'   (Defaults to a 1 second initial delay if `nert.initial_delay` has
#'   not been set.)
#'
#' @returns A [terra::SpatRaster] object for the requested dataset.
#'
#' @section Package options:
#' \pkg{nert} reads two package-level options on every call.  Both are
#' set to package defaults at load time and may be overridden globally
#' (e.g. in `.Rprofile`) without changing any individual call:
#' \describe{
#'   \item{`nert.max_tries`}{Default maximum number of download
#'     retries.  Default `3L`.}
#'   \item{`nert.initial_delay`}{Default initial retry delay in
#'     seconds (doubles each attempt).  Default `1L`.}
#' }
#' Per-call values supplied via the `max_tries` or
#' `initial_delay` arguments always override the option.  Example:
#' \preformatted{
#'   options(nert.max_tries = 5L, nert.initial_delay = 2L)
#' }
#'
#' @examplesIf interactive()
#' # Using aliases (recommended)
#' r <- read_tern("SMIPS", date = "2024-01-15")
#' r_asc <- read_tern("ASC")
#' autoplot(r_asc)
#'
#' # SLGA soil attributes
#' r_clay <- read_tern("CLY", depth = "000_005")
#' r_awc_upper  <- read_tern("AWC", depth = "015_030", collection = "95")
#' r_awc_lower  <- read_tern("AWC", depth = "015_030", collection = "05")
#'
#' # Soil Beta Diversity
#' r_bact <- read_tern("SOILDIV", collection = "Bacteria", axis = 1)
#'
#' # Canopy Height
#' r_ch <- read_tern("CANOPY")
#'
#' # Land Surface Phenology
#' r_phen <- read_tern("PHENOLOGY", year = 2018, collection = "SGS")
#'
#' # Full TERN dataset IDs also work
#' r2 <- read_tern("TERN/d1995ee8", date = "2024-01-15")
#'
#' @references
#' \describe{
#'   \item{**SMIPS: Daily volumetric soil moisture**}{
#'     Stenson, M., Searle, R., Malone, B., Sommer, A., Renzullo, L. & Di, H.
#'     (2021): Australia wide daily volumetric soil moisture estimates.
#'     Version 1.0. Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25901/b020-nm39}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#'   }
#'   \item{**ASC: Australian Soil Classification Map**}{
#'     Searle, R. (2021). Australian Soil Classification Map. Version 1.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25901/edyr-wg85}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/15728dba-b49c-4da5-9073-13d8abe67d7c>
#'   }
#'   \item{**AET: Actual Evapotranspiration using the CMRSET algorithm**}{
#'     McVicar, T., Vleeshouwer, J., Van Niel, T., Guerschman, J. &
#'     Peña-Arancibia, J. (2022). Actual Evapotranspiration for Australia
#'     using CMRSET algorithm. Version 1.0. Terrestrial Ecosystem Research
#'     Network. (Dataset). \doi{10.25901/gg27-ck96}.\cr\cr
#'     TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
#'   }
#'   \item{**AWC: SLGA Attribute - Available Volumetric Water Capacity**}{
#'     Searle, R., Nimalka Somarathna, P. & Malone, B. (2023). Soil and
#'     Landscape Grid National Soil Attribute Maps - Available Volumetric
#'     Water Capacity (Percent) (3 arc second resolution) Version 2.
#'     Version 2.0. Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/4jwj-na34}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/482301c2-b9a1-4345-b142-815f9b37890a>
#'   }
#'   \item{**CLY: SLGA Attribute - Clay content**}{
#'     Malone, B. & Searle, R. (2022). Soil and Landscape Grid National
#'     Soil Attribute Maps - Clay (3" resolution) - Release 2. Version 2.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/hc4s-3130}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/f95dc442-013b-4fad-b31f-91ba86fbe7f5>
#'   }
#'   \item{**SND: SLGA Attribute - Sand content**}{
#'     Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
#'     Attribute Maps - Sand (3" resolution) - Release 2. Version 2.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/rjmy-pa10}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4224ddff-5fb4-4170-b5ea-c0c500599700>
#'   }
#'   \item{**SLT: SLGA Attribute - Silt content**}{
#'     Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
#'     Attribute Maps - Silt (3" resolution) - Release 2. Version 2.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/2ew1-0w57}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/11375f04-b5cd-46a7-bcac-0e83fcb58605>
#'   }
#'   \item{**BDW: SLGA Attribute - Bulk Density (Whole Earth)**}{
#'     Malone, B. (2023). Soil and Landscape Grid National Soil Attribute
#'     Maps - Bulk Density - Whole Earth - Release 2. Version 2.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/gxyn-pd07}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/95978aec-6ba8-446b-a721-2b875d9f61a8>
#'   }
#'   \item{**PHC: SLGA Attribute - pH (of 1:5 soil/0.01M CaCl2 extract)**}{
#'     Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
#'     Attribute Maps - pH - Calcium Chloride (3" resolution) - Release 2.
#'     Version 2. Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/7320-hw30}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/258afc98-7407-4781-b241-cb0293b4b8aa>
#'   }
#'   \item{**PHW: SLGA Attribute - pH (of 1:5 soil water solution)**}{
#'     Malone, B. (2022). Soil and Landscape Grid National Soil Attribute
#'     Maps - pH (Water) (3" resolution) - Release 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/37z2-0q10}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/c37439a5-e622-44ab-9c24-bfd632d8203c>
#'   }
#'   \item{**NTO: SLGA Attribute - Total nitrogen**}{
#'     Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
#'     Attribute Maps - Total Nitrogen (3" resolution) - Release 2. Version 2.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/pm2n-ww12}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/e9484508-c705-4c23-9195-f26d64b9d4f1>
#'   }
#'   \item{**AVP: SLGA Attribute - Available phosphorus**}{
#'     Zund, P. (2022). Soil and Landscape Grid National Soil Attribute Maps
#'     - Available Phosphorus (3" resolution) - Release 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/6qzh-b979}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/c6ef289b-1ca8-4e53-b8b4-aa97e4706c63>
#'   }
#'   \item{**PTO: SLGA Attribute - Total phosphorus**}{
#'     Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
#'     Attribute Maps - Total Phosphorus (3" resolution) - Release 2.
#'     Version 2. Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/7j78-md43}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/be382e63-5ff6-40a9-930f-c84655a5bd87>
#'   }
#'   \item{**CEC: SLGA Attribute - Cation exchange capacity**}{
#'     Malone, B. (2024). Soil and Landscape Grid National Soil Attribute Maps
#'     - Cation Exchange Capacity (3" resolution) - Release 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/pkva-gf85}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/5b4b2991-bfa6-41df-be33-7009a5d0a5b0>
#'   }
#'   \item{**ECE: SLGA Attribute - Effective cation exchange capacity**}{
#'     Viscarra Rossel, R., Chen, C., Grundy, M., Searle, R., Clifford, D.,
#'     Odgers, N., Holmes, K., Griffin, T., Liddicoat, C. & Kidd, D. (2014).
#'     Soil and Landscape Grid National Soil Attribute Maps - Effective Cation
#'     Exchange Capacity (3" resolution) - Release 1. Version 1. Terrestrial
#'     Ecosystem Research Network. (Dataset).
#'     \doi{10.4225/08/546F091C11777}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/0d27cf8b-6627-4f33-8398-1b525bc1a210>
#'   }
#'   \item{**DUL: SLGA Attribute - Drained upper limit volumetric water content**}{
#'     Searle, R. & Nimalka Somarathna, P. (2022). Soil and Landscape Grid
#'     National Soil Attribute Maps - Drained Upper Limit Volumetric Water
#'     Content (Percent) (3 arc second resolution) Version 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/jnvd-3a26}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/de9ddc12-b8e4-4ff2-99c4-390227a848aa>
#'   }
#'   \item{**L15: SLGA Attribute - 15 bar lower limit volumetric water content**}{
#'     Searle, R. & Nimalka Somarathna, P. (2022). Soil and Landscape Grid
#'     National Soil Attribute Maps - 15 Bar Lower Limit Volumetric Water
#'     Content (Percent) (3 arc second resolution) Version 1. Version 1.0.
#'     Terrestrial Ecosystem Research Network. (Dataset).
#'     \doi{10.25919/awp8-nv68}.\cr\cr TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4443f5df-a0b2-4352-b44b-83f7feb1e27d>
#'   }
#'   \item{**SOILDIV: Soil Bacteria and Soil Fungi Beta Diversity**}{
#'     Dobarco, M., Wadoux, A. & Xue, P. (2024). Soil and Landscape Grid
#'     National
#'     Soil Attribute Maps - Soil Bacteria and Fungi Beta Diversity (3"
#'     resolution) - Release 1. Version 1.0. Terrestrial Ecosystem Research
#'     Network. (Dataset). \doi{10.25919/4x7n-y874}.\cr\cr
#'     TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4a428d52-dda6-4097-8dd9-d3ec63973029>
#'   }
#'   \item{**CANOPY: OzTreeMap Best-Pick Canopy Height Model**}{
#'     Pucino, N., McVicar, T., Levick, S. & Albert van Dijk (2025).
#'     Australia-Wide 30 m Machine Learning-Derived Canopy Height Models
#'     Composites: Best Pick and Median. Version 1. Terrestrial Ecosystem
#'     Research Network. (Dataset). \doi{10.25901/xqv7-jk46}.\cr\cr
#'     TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/36c98155-39c8-4eec-9070-a978933f3fa3>
#'   }
#'   \item{**PHENOLOGY: Australian Land Surface Phenology**}{
#'     Xie, Q. & Huete, A. (2024). Australian land surface phenology dataset at
#'     500m resolution. Version 1.0. Terrestrial Ecosystem Research Network.
#'     (Dataset). URL: <https://portal.tern.org.au/metadata/2bb0c81a-41a9-434c-b87a-db0301cb52fb>.\cr\cr
#'     TERN Point-of-truth metadata URL:
#'     <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/2bb0c81a-41a9-434c-b87a-db0301cb52fb>
#'   }
#' }
#'
#'
#' @export
read_tern <- function(
  dataset_id = NULL,
  ...,
  api_key = NULL,
  max_tries = NULL,
  initial_delay = NULL
) {
  if (is.null(dataset_id)) {
    cli::cli_abort("You must provide a {.arg dataset_id}.")
  }

  # Validate dataset ID and dataset-specific arguments *before* checking the
  # API key, so input-validation errors surface in CI/tests where
  # `TERN_API_KEY` is unset. The per-dataset validator (if any) lives in that
  # dataset's own `R/read_<name>.R` file and is wired in via `.tern_datasets`.
  dots <- list(...)
  did <- .tern_dispatch_id(dataset_id)
  entry <- .tern_datasets[[did]]
  if (is.null(entry)) {
    cli::cli_abort(c(
      "Dataset {.val {dataset_id}} is not implemented in {.fn read_tern}.",
      "i" = "Supported aliases: {.and {names(.tern_aliases)}}.",
      "i" = "Datasets with L2+ integration (OPeNDAP, GEE, REST API,
             site-specific) are outside {.pkg nert} scope."
    ))
  }
  if (!is.null(entry$validate)) {
    entry$validate(dots, dataset_id)
  }
  api_key <- .check_api_key(api_key %||% get_key())

  return(entry$read(did, dots, api_key, max_tries, initial_delay))
}


#' Dataset registry
#'
#' Single source of truth mapping each dataset's normalised 8-char dispatch ID
#' to its short alias, optional argument validator, and read handler. The
#' dispatch path in [read_tern()] and the [.tern_aliases] lookup are derived
#' from this list, so a dataset is defined in one place. The SLGA entries are
#' generated from [.slga_config].
#'
#' Each entry is a `list` with an `alias` (upper-case short name), a `read`
#' handler invoked as `read(did, dots, api_key, max_tries, initial_delay)`, and
#' an optional `validate` function invoked as `validate(dots, dataset_id)`
#' before the API key is checked. Both the validator (where present) and the
#' handler live in the dataset's own `R/read_<name>.R` file. Datasets with no
#' pre-key argument validation simply omit `validate`.
#'
#' @dev
.tern_datasets <- c(
  list(
    "d1995ee8" = list(
      alias = "SMIPS",
      validate = .validate_smips,
      read = .read_tern_smips
    ),
    "15728dba" = list(alias = "ASC", read = .read_tern_asc),
    "9fefa68b" = list(
      alias = "AET",
      validate = .validate_aet,
      read = .read_tern_aet
    ),
    "4a428d52" = list(alias = "SOILDIV", read = .read_tern_soil_diversity),
    "36c98155" = list(alias = "CANOPY", read = .read_tern_canopy_height),
    "2bb0c81a" = list(
      alias = "PHENOLOGY",
      validate = .validate_phenology,
      read = .read_tern_phenology
    )
  ),
  # SLGA from .slga_config.
  lapply(.slga_config, function(cfg) {
    list(alias = cfg$prefix, read = .read_tern_slga)
  })
)


#' Alias mapping for short dataset names
#'
#' Named `character` vector mapping user-friendly short names (e.g.
#' `"SMIPS"`, `"AWC"`) to dispatch IDs. Derived from [.tern_datasets].
#'
#' @dev
.tern_aliases <- stats::setNames(
  names(.tern_datasets),
  vapply(.tern_datasets, function(d) d$alias, character(1L))
)


#' Normalise a TERN dataset key for switch() dispatch
#'
#' Checks alias table first (case-insensitive), then strips any
#' `TERN/`, `CSIRO/`, `AEKOS/`, or `NCI/` prefix and extracts the first 8
#' lower-case characters of the UUID.  Non-UUID identifiers (e.g. `AusEFlux_v2`)
#' are returned as-is after prefix removal.
#'
#' @param id The raw `dataset_id` string supplied by the user.
#' @returns A normalised `character` string for use in `switch()`.
#'
#' @dev
.tern_dispatch_id <- function(id) {
  if (length(id) != 1L) {
    cli::cli_abort(
      "{.arg dataset_id} must be a single character string;
       got length {.val {length(id)}}.
       To collect multiple datasets in one call use {.fn collect_tern_data}."
    )
  }
  id <- trimws(as.character(id))

  # Check alias table first (case-insensitive)
  upper_id <- toupper(id)
  if (upper_id %in% names(.tern_aliases)) {
    return(.tern_aliases[[upper_id]])
  }

  # Strip TERN/ and other prefixes
  id <- sub("^(?:TERN|CSIRO|AEKOS|NCI)/", "", id, perl = TRUE)

  # UUID-like string: keep only the first 8 hex chars
  id <- sub(
    "^([0-9a-f]{8})[0-9a-f\\-]*$",
    "\\1",
    id,
    ignore.case = TRUE,
    perl = TRUE
  )
  return(tolower(id))
}
