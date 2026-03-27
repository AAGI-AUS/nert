#' Read TERN COG Datasets
#'
#' A unified interface for reading Cloud Optimised GeoTIFF (\acronym{COG})
#' data from \acronym{TERN} and related repositories.  Dispatches to a
#' dataset-specific handler based on \code{dataset_id} and passes any
#' additional arguments through \code{...}.  The returned object is a
#' [terra::rast()] that can be plotted, cropped, or extracted with standard
#' \pkg{terra} or \pkg{tidyterra} workflows.
#'
#' @section Dataset aliases:
#' In addition to full \acronym{TERN} portal keys and 8-character prefixes,
#' \code{read_tern()} accepts short human-readable aliases (case-insensitive):
#' \tabular{lll}{
#'   \strong{Alias}        \tab \strong{Dataset ID}        \tab \strong{Description} \cr
#'   \code{"SMIPS"}         \tab \code{TERN/d1995ee8} \tab Daily soil moisture (~1 km) \cr
#'   \code{"ASC"}           \tab \code{TERN/15728dba} \tab Australian Soil Classification (90 m) \cr
#'   \code{"AET"}           \tab \code{TERN/9fefa68b} \tab Monthly evapotranspiration (CMRSET) \cr
#'   \code{"AWC"}           \tab \code{TERN/482301c2} \tab Available Water Capacity (90 m) \cr
#'   \code{"CLY"}           \tab SLGA                 \tab Clay content (90 m) \cr
#'   \code{"SND"}           \tab SLGA                 \tab Sand content (90 m) \cr
#'   \code{"SLT"}           \tab SLGA                 \tab Silt content (90 m) \cr
#'   \code{"BDW"}           \tab SLGA                 \tab Bulk density whole earth (90 m) \cr
#'   \code{"PHC"}           \tab SLGA                 \tab pH CaCl2 (90 m) \cr
#'   \code{"PHW"}           \tab SLGA                 \tab pH water (90 m) \cr
#'   \code{"NTO"}           \tab SLGA                 \tab Total Nitrogen (90 m) \cr
#'   \code{"SOILDIV"}       \tab \code{TERN/4a428d52} \tab Soil Beta Diversity (90 m) \cr
#'   \code{"CANOPY"}        \tab \code{TERN/36c98155} \tab Canopy Height (30 m) \cr
#'   \code{"PHENOLOGY"}     \tab \code{TERN/2bb0c81a} \tab Land Surface Phenology (500 m) \cr
#' }
#' Convenience wrappers [read_smips()], [read_asc()], [read_aet()],
#' [read_slga()], [read_soil_diversity()], [read_canopy_height()], and
#' [read_phenology()] are also provided for direct access to each dataset.
#'
#' @section SMIPS — daily soil moisture (\code{"TERN/d1995ee8"}):
#' \describe{
#'   \item{\code{date}}{Required.  A single day to query, _e.g._
#'     \code{"2024-01-15"} or \code{as.Date("2024-01-15")}.  Both
#'     \code{Character} and \code{Date} classes are accepted.}
#'   \item{\code{collection}}{One of \code{"totalbucket"} (default),
#'     \code{"SMindex"}, \code{"bucket1"}, \code{"bucket2"},
#'     \code{"deepD"}, or \code{"runoff"}.}
#' }
#' Data availability: 2015-11-20 to approximately 7 days before today.
#'
#' @section ASC — Australian Soil Classification (\code{"TERN/15728dba"}):
#' \describe{
#'   \item{\code{collection}}{One of \code{"EV"} (estimated soil order
#'     class, default) or \code{"CI"} (confusion index — a measure of
#'     mapping reliability).  No \code{date} argument required; this is a
#'     static product.}
#' }
#'
#' @section AET — Actual Evapotranspiration/CMRSET (\code{"TERN/9fefa68b"}):
#' \describe{
#'   \item{\code{date}}{Required.  A month to query, _e.g._
#'     \code{"2023-06-01"} or \code{as.Date("2023-06-01")}.  Both
#'     \code{Character} and \code{Date} classes are accepted.  The value is
#'     snapped to the first of the month internally.}
#'   \item{\code{collection}}{One of \code{"ETa"} (primary AET band in
#'     mm/month, default) or \code{"pixel_qa"} (quality assurance flags).}
#' }
#' Data availability: 2000-02-01 onwards.
#'
#' @section SLGA soil attributes (\code{"AWC"}, \code{"CLY"}, etc.):
#' Eight \acronym{SLGA} (Soil and Landscape Grid of Australia) soil
#' attributes are available as static 90 m products, each with six standard
#' depth layers and two statistics:
#' \describe{
#'   \item{\code{depth}}{One of \code{"000_005"} (default), \code{"005_015"},
#'     \code{"015_030"}, \code{"030_060"}, \code{"060_100"}, or
#'     \code{"100_200"} (cm).}
#'   \item{\code{collection}}{One of \code{"EV"} (estimated value, default)
#'     or \code{"CI"} (confidence interval).}
#' }
#' Supported attributes (use as the \code{dataset_id} alias):
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
#' Convenience wrapper: [read_slga()].
#'
#' @section Soil Beta Diversity (\code{"SOILDIV"}, \code{TERN/4a428d52}):
#' \describe{
#'   \item{\code{collection}}{One of \code{"Bacteria"} (default) or
#'     \code{"Fungi"}.}
#'   \item{\code{axis}}{NMDS axis number: \code{1} (default), \code{2}, or
#'     \code{3}.}
#' }
#' Static 90 m product.  Convenience wrapper: [read_soil_diversity()].
#'
#' @section Canopy Height (\code{"CANOPY"}, \code{TERN/36c98155}):
#' Single static 30 m composite from the OzTreeMap project.  No additional
#' arguments required.  Convenience wrapper: [read_canopy_height()].
#'
#' @section Land Surface Phenology (\code{"PHENOLOGY"}, \code{TERN/2bb0c81a}):
#' \describe{
#'   \item{\code{year}}{Required.  An integer year (2003--2018).}
#'   \item{\code{season}}{Season number: \code{1} (default) or \code{2}.}
#'   \item{\code{collection}}{Phenology metric — one of \code{"SGS"}
#'     (Start of Growing Season, default), \code{"PGS"} (Peak),
#'     \code{"EGS"} (End), \code{"LGS"} (Length), \code{"SOS"} (Start of
#'     Season), \code{"POS"} (Peak of Season), \code{"EOS"} (End of Season),
#'     \code{"LOS"} (Length of Season), \code{"ROG"} (Rate of Greening),
#'     \code{"ROS"} (Rate of Senescence).}
#' }
#' 500 m MODIS resolution.  Convenience wrapper: [read_phenology()].
#'
#' @section Datasets not accessible:
#' The following datasets are tracked in the \acronym{TERN} catalogue but
#' cannot be accessed via COG HTTP range requests:
#' \itemize{
#'   \item \code{TERN/0997cb3c} — Seasonal Fractional Cover (Landsat)
#'   \item \code{TERN/fe9d86e1} — Seasonal Ground Cover (Landsat)
#' }
#' Datasets with integration level L2 or higher (e.g.\ AusEFlux via
#' \acronym{THREDDS}/OPeNDAP, GEE-based products, site-level API streams)
#' cannot be read via simple COG HTTP range requests and are outside the
#' current scope of \pkg{nert}.
#'
#' @param dataset_id A \code{character} string identifying the dataset.
#'   Accepts a short alias, the full \acronym{TERN} portal key (e.g.\
#'   \code{"TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0"}), or the
#'   8-character key prefix (e.g.\ \code{"TERN/d1995ee8"}).  See the
#'   \strong{Dataset aliases} section for the complete table of supported
#'   aliases.
#' @param ... Dataset-specific arguments — \code{date}, \code{collection},
#'   etc.  See the relevant section above for each dataset.
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}.  See \code{\link{get_key}} for
#'   setup instructions.
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries before an error is raised.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#' # Using aliases (recommended) ──────────────────────────────────
#' r <- read_tern("SMIPS", date = "2024-01-15")
#' autoplot(r)
#'
#' r_asc <- read_tern("ASC")
#' r_aet <- read_tern("AET", date = "2023-06-01")
#'
#' # SLGA soil attributes — depth and collection
#' r_clay <- read_tern("CLY", depth = "000_005")
#' r_awc  <- read_tern("AWC", depth = "015_030", collection = "CI")
#'
#' # Soil Beta Diversity
#' r_bact <- read_tern("SOILDIV", collection = "Bacteria", axis = 1)
#'
#' # Canopy Height (single static product)
#' r_ch <- read_tern("CANOPY")
#'
#' # Land Surface Phenology
#' r_phen <- read_tern("PHENOLOGY", year = 2018, collection = "SGS")
#'
#' # Full TERN keys still work ────────────────────────────────────
#' r2 <- read_tern("TERN/d1995ee8", date = "2024-01-15")
#'
#' @returns A [terra::rast()] object of the national mosaic for the
#'   requested dataset (and, where applicable, date/collection).
#'
#' @references
#'   SMIPS: <https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#'
#'   ASC: <https://portal.tern.org.au/metadata/TERN/15728dba-b49c-4da5-9073-13d8abe67d7c>
#'
#'   AET: <https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
#'
#'   AWC: <https://portal.tern.org.au/metadata/TERN/482301c2-2837-4b0b-bf95-4883a04e5ff7>
#'
#'   Soil Beta Diversity: <https://portal.tern.org.au/metadata/TERN/4a428d52-d15c-4bfc-8a67-80697f8c0aa0>
#'
#'   Canopy Height: <https://portal.tern.org.au/metadata/TERN/36c98155-c137-44b8-b4e0-6a3e824bbfba>
#'
#'   Land Surface Phenology: <https://portal.tern.org.au/metadata/TERN/2bb0c81a-5a09-4a0e-bd86-5cd2be8def26>
#'
#' @autoglobal
#' @export
read_tern <- function(
  dataset_id,
  ...,
  api_key       = NULL,
  max_tries     = 3L,
  initial_delay = 1L
) {
  if (missing(dataset_id)) {
    cli::cli_abort("You must provide a {.arg dataset_id}.")
  }

  # Validate dataset ID and collect dots *before* checking the API key so that
  # input-validation errors surface even when the key is not configured (e.g.
  # in CI without TERN_API_KEY).
  did  <- .tern_dispatch_id(dataset_id)
  dots <- list(...)

  # Validate dataset-specific arguments before requiring the API key
  .tern_validate_args(did, dots, dataset_id)

  api_key <- .check_api_key(api_key %||% get_key())

  switch(
    did,
    "d1995ee8" = .read_tern_smips(dots, api_key, max_tries, initial_delay),
    "15728dba" = .read_tern_asc(dots, api_key, max_tries, initial_delay),
    "9fefa68b" = .read_tern_aet(dots, api_key, max_tries, initial_delay),
    "482301c2" = ,
    "slga_cly" = ,
    "slga_snd" = ,
    "slga_slt" = ,
    "slga_bdw" = ,
    "slga_phc" = ,
    "slga_phw" = ,
    "slga_nto" = .read_tern_slga(did, dots, api_key, max_tries, initial_delay),
    "4a428d52" = .read_tern_soil_diversity(dots, api_key, max_tries, initial_delay),
    "36c98155" = .read_tern_canopy_height(api_key, max_tries, initial_delay),
    "2bb0c81a" = .read_tern_phenology(dots, api_key, max_tries, initial_delay)
  )
}


# ── Dispatch helpers ──────────────────────────────────────────────────────────

#' Dataset alias registry
#'
#' Named list mapping short human-readable aliases (upper-case) to the
#' normalised 8-character dataset ID used for internal dispatch.
#'
#' @format A named \code{list} of \code{character} strings.
#' @autoglobal
#' @dev
.tern_aliases <- list(
  SMIPS    = "d1995ee8",
  ASC      = "15728dba",
  AET      = "9fefa68b",
  AWC      = "482301c2",
  CLY      = "slga_cly",
  SND      = "slga_snd",
  SLT      = "slga_slt",
  BDW      = "slga_bdw",
  PHC      = "slga_phc",
  PHW      = "slga_phw",
  NTO      = "slga_nto",
  SOILDIV  = "4a428d52",
  CANOPY   = "36c98155",
  PHENOLOGY = "2bb0c81a"
)


#' Normalise a TERN dataset key for switch() dispatch
#'
#' Resolves human-readable aliases (\code{"SMIPS"}, \code{"ASC"},
#' \code{"AET"}), strips any \code{TERN/}, \code{CSIRO/}, \code{AEKOS/}, or
#' \code{NCI/} prefix, then extracts the first 8 lower-case characters of
#' the UUID.  Non-UUID identifiers (e.g.\ \code{"AusEFlux_v2"}) are
#' returned as-is after prefix removal.
#'
#' @param id The raw \code{dataset_id} string supplied by the user.
#' @returns A normalised \code{character} string for use in \code{switch()}.
#' @autoglobal
#' @dev
.tern_dispatch_id <- function(id) {
  id <- trimws(as.character(id[[1L]]))
  # Check alias registry first (case-insensitive)
  alias_match <- .tern_aliases[[toupper(id)]]
  if (!is.null(alias_match)) return(alias_match)
  # Standard path: strip org prefix, extract 8-char UUID prefix
  id <- sub("^(?:TERN|CSIRO|AEKOS|NCI)/", "", id, perl = TRUE)
  id <- sub("^([0-9a-f]{8})[0-9a-f\\-]*$", "\\1", id,
            ignore.case = TRUE, perl = TRUE)
  tolower(id)
}


#' Emit an informative error for unsupported dataset IDs
#'
#' @param dataset_id The raw dataset ID supplied by the user.
#' @autoglobal
#' @dev
.tern_not_implemented <- function(dataset_id) {
  aliases <- paste0(names(.tern_aliases), collapse = ", ")
  cli::cli_abort(c(
    "Dataset {.val {dataset_id}} is not currently implemented in
     {.fn read_tern}.",
    "i" = "Supported aliases: {aliases}.",
    "i" = "Datasets with L2+ integration levels (OPeNDAP, GEE, REST API,
           site-specific) are outside the current {.pkg nert} scope."
  ))
}


#' Validate dataset-specific arguments before the API key is checked
#'
#' Runs the same guards as the individual handlers but without requiring an
#' API key, so that input-validation errors surface in CI and tests even when
#' `TERN_API_KEY` is not set.
#'
#' @param did Normalised 8-char dataset ID from [.tern_dispatch_id()].
#' @param dots Named list of `...` arguments from the caller.
#' @param dataset_id The raw `dataset_id` for error messages.
#' @returns `NULL` (invisibly); called for its side effects (errors).
#' @autoglobal
#' @dev
.tern_validate_args <- function(did, dots, dataset_id) {
  switch(
    did,
    "d1995ee8" = {
      date <- if (!is.null(dots[["date"]])) dots[["date"]] else dots[["day"]]
      if (is.null(date)) {
        cli::cli_abort(
          "SMIPS requires a {.arg date} argument (daily resolution),
           e.g.  {.code date = \"2024-01-15\"}."
        )
      }
    },
    "15728dba" = {
      # ASC — no required arguments beyond collection (has default)
    },
    "9fefa68b" = {
      date <- if (!is.null(dots[["date"]])) dots[["date"]] else dots[["month"]]
      if (is.null(date)) {
        cli::cli_abort(
          "AET requires a {.arg date} argument (monthly resolution),
           e.g.  {.code date = \"2023-06-01\"}."
        )
      }
      .check_aet_date(date)
    },
    "482301c2" = ,
    "slga_cly" = ,
    "slga_snd" = ,
    "slga_slt" = ,
    "slga_bdw" = ,
    "slga_phc" = ,
    "slga_phw" = ,
    "slga_nto" = {
      # SLGA — all static, optional depth/collection with defaults
    },
    "4a428d52" = {
      # Soil Beta Diversity — optional collection/axis with defaults
    },
    "36c98155" = {
      # Canopy Height — no arguments required
    },
    "2bb0c81a" = {
      year <- dots[["year"]]
      if (is.null(year)) {
        cli::cli_abort(
          "Phenology requires a {.arg year} argument (2003--2018),
           e.g.  {.code year = 2018}."
        )
      }
      year <- as.integer(year)
      if (year < 2003L || year > 2018L) {
        cli::cli_abort(
          "Phenology data are available for years 2003--2018.
           You requested {year}."
        )
      }
    },
    .tern_not_implemented(dataset_id)
  )
  invisible(NULL)
}


# ── SMIPS handler ─────────────────────────────────────────────────────────────

#' Internal handler for SMIPS (\code{TERN/d1995ee8})
#'
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_smips <- function(dots, api_key, max_tries, initial_delay) {
  # Accept both 'date' and the legacy 'day' parameter name
  date <- if (!is.null(dots[["date"]])) dots[["date"]] else dots[["day"]]
  if (is.null(date)) {
    cli::cli_abort(
      "SMIPS requires a {.arg date} argument (daily resolution),
       e.g.  {.code date = \"2024-01-15\"}."
    )
  }
  collection <- if (!is.null(dots[["collection"]])) dots[["collection"]] else "totalbucket"

  day      <- .check_date(date)
  dl_file  <- .make_smips_url(.collection = collection, .day = day)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/smips/v1_0/%s/%s/%s",
    api_key, collection, lubridate::year(day), dl_file
  )
  .read_cog(full_url, max_tries, initial_delay)
}


# ── ASC handler ───────────────────────────────────────────────────────────────

#' Internal handler for ASC (\code{TERN/15728dba})
#'
#' @inheritParams .read_tern_smips
#' @autoglobal
#' @dev
.read_tern_asc <- function(dots, api_key, max_tries, initial_delay) {
  collection <- if (!is.null(dots[["collection"]])) dots[["collection"]] else "EV"

  approved   <- c("EV", "CI")
  collection <- rlang::arg_match(collection, approved)

  dl_file <- data.table::fifelse(
    collection == "EV",
    "ASC_EV_C_P_AU_TRN_N.cog.tif",
    "ASC_CI_C_P_AU_TRN_N.cog.tif"
  )
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/%s",
    api_key, dl_file
  )
  .read_cog(full_url, max_tries, initial_delay)
}


# ── AET handler ───────────────────────────────────────────────────────────────

#' Internal handler for AET/CMRSET (\code{TERN/9fefa68b})
#'
#' @inheritParams .read_tern_smips
#' @autoglobal
#' @dev
.read_tern_aet <- function(dots, api_key, max_tries, initial_delay) {
  # Accept both 'date' and the legacy 'month' parameter name
  date <- if (!is.null(dots[["date"]])) dots[["date"]] else dots[["month"]]
  if (is.null(date)) {
    cli::cli_abort(
      "AET requires a {.arg date} argument (monthly resolution),
       e.g.  {.code date = \"2023-06-01\"}."
    )
  }
  collection <- if (!is.null(dots[["collection"]])) dots[["collection"]] else "ETa"

  month    <- .check_aet_date(date)
  full_url <- .make_aet_url(
    .collection = collection,
    .month      = month,
    .api_key    = api_key
  )
  .read_cog(full_url, max_tries, initial_delay)
}


# ── AET date/URL helpers (moved from aet.R) ───────────────────────────────────

#' Check User Input Months for AET Validity
#'
#' Validates and snaps a user-supplied date value to the first of the month,
#' then checks it against the \acronym{AET} data availability window
#' (from 2000-02-01 onwards).
#'
#' @param x User-entered date value (any format accepted by [.check_date()]).
#' @returns A \code{POSIXct} object snapped to the first of the requested
#'   month.
#' @autoglobal
#' @dev
.check_aet_date <- function(x) {
  x  <- .check_date(x)
  x  <- lubridate::floor_date(x, "month")
  yr <- lubridate::year(x)
  mo <- lubridate::month(x)
  if (yr < 2000L || (yr == 2000L && mo < 2L)) {
    cli::cli_abort(
      "AET data are not available before 2000-02-01.
       You requested {format(x, '%Y-%m-%d')}."
    )
  }
  return(x)
}


#' Build a GDAL vsicurl URL for an AET Collection
#'
#' @param .collection The user-supplied \acronym{AET} collection
#'   (\code{"ETa"} or \code{"pixel_qa"}).
#' @param .month The validated \code{POSIXct} date snapped to the first of
#'   the month.
#' @param .api_key The \acronym{URL}-encoded \acronym{API} key.
#' @returns A \code{character} GDAL vsicurl URL string.
#' @autoglobal
#' @dev
.make_aet_url <- function(.collection, .month, .api_key) {
  approved_collections <- c("ETa", "pixel_qa")
  collection <- rlang::arg_match(.collection, approved_collections)

  year     <- lubridate::year(.month)
  date_str <- format(.month, "%Y_%m_%d")

  sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/landscapes/aet/v2_2/%s/%s/CMRSET_LANDSAT_V2_2_%s_%s.vrt",
    .api_key, year, date_str, date_str, collection
  )
}


# ── SLGA handler ──────────────────────────────────────────────────────────────

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


# ── Soil Beta Diversity handler ───────────────────────────────────────────────

#' Internal handler for Soil Beta Diversity (\code{TERN/4a428d52})
#'
#' @inheritParams .read_tern_smips
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


# ── Canopy Height handler ────────────────────────────────────────────────────

#' Internal handler for Canopy Height (\code{TERN/36c98155})
#'
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_canopy_height <- function(api_key, max_tries, initial_delay) {
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/OzTreeMap/CanopyHeightComposite/best_pick_files_bhLNnun.tif",
    api_key
  )
  .read_cog(full_url, max_tries, initial_delay)
}


# ── Phenology handler ────────────────────────────────────────────────────────

#' Phenology metric registry
#'
#' Named list mapping metric abbreviations to their subdirectory names on
#' the TERN data server.
#'
#' @format A named \code{list} of \code{character} strings.
#' @autoglobal
#' @dev
.phenology_metrics <- list(
  SGS = "1_Start_of_the_growing_season",
  PGS = "2_Peak_of_the_growing_season",
  EGS = "3_End_of_the_growing_season",
  LGS = "4_Length_of_the_growing_season",
  SOS = "5_Start_of_season",
  POS = "6_Peak_of_season",
  EOS = "7_End_of_season",
  LOS = "8_Length_of_season",
  ROG = "9_Rate_of_greening",
  ROS = "10_Rate_of_senescence"
)


#' Internal handler for Land Surface Phenology (\code{TERN/2bb0c81a})
#'
#' @inheritParams .read_tern_smips
#' @autoglobal
#' @dev
.read_tern_phenology <- function(dots, api_key, max_tries, initial_delay) {
  year       <- as.integer(dots[["year"]])
  season     <- if (!is.null(dots[["season"]])) as.integer(dots[["season"]]) else 1L
  collection <- if (!is.null(dots[["collection"]])) dots[["collection"]] else "SGS"

  approved_metrics <- names(.phenology_metrics)
  collection <- rlang::arg_match(collection, approved_metrics)

  if (!season %in% 1L:2L) {
    cli::cli_abort("Phenology {.arg season} must be 1 or 2.")
  }

  metric_dir <- .phenology_metrics[[collection]]
  fname <- sprintf("%s_%d_Season%d.tif", collection, year, season)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/%s/%s",
    api_key, metric_dir, fname
  )
  .read_cog(full_url, max_tries, initial_delay)
}
