#' Read TERN COG Datasets
#'
#' A unified interface for reading Cloud Optimised GeoTIFF (\acronym{COG})
#' data from \acronym{TERN} and related repositories.  Dispatches to a
#' dataset-specific handler based on \code{dataset_id} and passes any
#' additional arguments through \code{...}.  The returned object is a
#' [terra::SpatRaster] that can be plotted, cropped, or extracted with
#' standard \pkg{terra} or \pkg{tidyterra} workflows.
#'
#' @section Dataset aliases:
#' In addition to full \acronym{TERN} portal keys and 8-character prefixes,
#' \code{read_tern()} accepts short human-readable aliases (case-insensitive):
#' \tabular{lll}{
#'   \strong{Alias} \tab \strong{Dataset ID} \tab \strong{Description} \cr
#'   \code{"SMIPS"} \tab \code{TERN/d1995ee8} \tab Daily soil moisture (~1 km) \cr
#'   \code{"ASC"} \tab \code{TERN/15728dba} \tab Australian Soil Classification (90 m) \cr
#'   \code{"AET"} \tab \code{TERN/9fefa68b} \tab Monthly evapotranspiration (CMRSET) \cr
#'   \code{"AWC"} \tab \code{TERN/482301c2} \tab Available Water Capacity (90 m) \cr
#'   \code{"CLY"} \tab SLGA \tab Clay content (90 m) \cr
#'   \code{"SND"} \tab SLGA \tab Sand content (90 m) \cr
#'   \code{"SLT"} \tab SLGA \tab Silt content (90 m) \cr
#'   \code{"BDW"} \tab SLGA \tab Bulk density whole earth (90 m) \cr
#'   \code{"PHC"} \tab SLGA \tab pH CaCl2 (90 m) \cr
#'   \code{"PHW"} \tab SLGA \tab pH water (90 m) \cr
#'   \code{"NTO"} \tab SLGA \tab Total Nitrogen (90 m) \cr
#'   \code{"AVP"} \tab SLGA \tab Available Phosphorus (90 m) \cr
#'   \code{"PTO"} \tab SLGA \tab Total Phosphorus (90 m) \cr
#'   \code{"CEC"} \tab SLGA \tab Cation Exchange Capacity (90 m) \cr
#'   \code{"ECE"} \tab SLGA \tab Effective Cation Exchange Capacity (90 m) \cr
#'   \code{"DUL"} \tab SLGA \tab Drained Upper Limit water content (90 m) \cr
#'   \code{"L15"} \tab SLGA \tab 15 Bar Lower Limit water content (90 m) \cr
#'   \code{"SOILDIV"} \tab \code{TERN/4a428d52} \tab Soil Beta Diversity (90 m) \cr
#'   \code{"CANOPY"} \tab \code{TERN/36c98155} \tab Canopy Height (30 m) \cr
#'   \code{"PHENOLOGY"} \tab \code{TERN/2bb0c81a} \tab Land Surface Phenology (500 m) \cr
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
#' Data availability: 2015-01-01 to approximately 7 days before today.
#'
#' @section ASC -- Australian Soil Classification (\code{"TERN/15728dba"}):
#' \describe{
#'   \item{\code{collection}}{One of \code{"EV"} (estimated soil order
#'     class, default) or \code{"CI"} (confusion index -- a measure of
#'     mapping uncertainty).  No \code{date} argument required; this is a
#'     static product.}
#' }
#'
#' @section AET -- Actual Evapotranspiration/CMRSET (\code{"TERN/9fefa68b"}):
#' \describe{
#'   \item{\code{date}}{Required.  A month to query, _e.g._
#'     \code{"2023-06-01"} or \code{as.Date("2023-06-01")}.  Both
#'     \code{Character} and \code{Date} classes are accepted.  The value is
#'     snapped to the first of the month internally.}
#'   \item{\code{collection}}{One of \code{"ETa"} (primary AET band in
#'     mm/month, default) or \code{"pixel_qa"} (quality assurance flags).}
#' }
#' Data availability: 1987-05-01 onwards.
#'
#' @section SLGA soil attributes (\code{"AWC"}, \code{"CLY"}, etc.):
#' 14 \acronym{SLGA} (Soil and Landscape Grid of Australia) soil
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
#'   \item{\code{"AWC"}}{Available Water Capacity (percent)}
#'   \item{\code{"CLY"}}{Clay content (percent)}
#'   \item{\code{"SND"}}{Sand content (percent)}
#'   \item{\code{"SLT"}}{Silt content (percent)}
#'   \item{\code{"BDW"}}{Bulk Density whole earth (g/cm3)}
#'   \item{\code{"PHC"}}{pH (CaCl2)}
#'   \item{\code{"PHW"}}{pH (water)}
#'   \item{\code{"NTO"}}{Total Nitrogen (percent)}
#'   \item{\code{"AVP"}}{Available Phosphorus (mg/kg)}
#'   \item{\code{"PTO"}}{Total Phosphorus (percent)}
#'   \item{\code{"CEC"}}{Cation Exchange Capacity (meq/100g)}
#'   \item{\code{"ECE"}}{Effective Cation Exchange Capacity (meq/100g)}
#'   \item{\code{"DUL"}}{Drained Upper Limit volumetric water content (percent)}
#'   \item{\code{"L15"}}{15 Bar Lower Limit volumetric water content (percent)}
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
#' Single static 30 m best-pick composite from the OzTreeMap project.
#' No additional arguments required.
#' Convenience wrapper: [read_canopy_height()].
#'
#' @section Land Surface Phenology (\code{"PHENOLOGY"}, \code{TERN/2bb0c81a}):
#' \describe{
#'   \item{\code{year}}{Required.  An integer year (2003--2018).}
#'   \item{\code{season}}{Season number: \code{1} (default) or \code{2}.}
#'   \item{\code{collection}}{Phenology metric — one of \code{"SGS"}
#'     (Start of Growing Season, default), \code{"PGS"} (Peak of Growing Season),
#'     \code{"EGS"} (End of Growing Season), \code{"LGS"} (Length of Growing Season),
#'     \code{"EVI1"} (Minimum EVI before peak), \code{"EVI2"} (Minimum EVI after peak),
#'     \code{"EVIP"} (EVI at Peak of Growing Season),
#'     \code{"EVII"} (Integral of EVI under growing season curve).}
#' }
#' 500 m resolution.  Convenience wrapper: [read_phenology()].
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
#' @param max_tries Maximum number of download retries before an error is
#'   raised.  When \code{NULL} (default), resolved from
#'   \code{getOption("nert.max_tries", 3L)}.  Pass an integer to override
#'   for a single call.
#' @param initial_delay Initial retry delay in seconds (doubles with each
#'   attempt).  When \code{NULL} (default), resolved from
#'   \code{getOption("nert.initial_delay", 1L)}.  Pass an integer to
#'   override for a single call.
#'
#' @section Package options:
#' \pkg{nert} reads two package-level options on every call.  Both are
#' set to package defaults at load time and may be overridden globally
#' (e.g.\ in \code{.Rprofile}) without changing any individual call:
#' \describe{
#'   \item{\code{nert.max_tries}}{Default maximum number of download
#'     retries.  Default \code{3L}.}
#'   \item{\code{nert.initial_delay}}{Default initial retry delay in
#'     seconds (doubles each attempt).  Default \code{1L}.}
#' }
#' Per-call values supplied via the \code{max_tries} or
#' \code{initial_delay} arguments always override the option.  Example:
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
#' # Full TERN keys still work
#' r2 <- read_tern("TERN/d1995ee8", date = "2024-01-15")
#'
#' @returns A [terra::SpatRaster] object of the national mosaic for the
#'   requested dataset (and, where applicable, date/collection).
#'
#' @references
#'   SMIPS: <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#'   ASC: <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/15728dba-b49c-4da5-9073-13d8abe67d7c>
#'   AET: <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
#'   AWC: <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/482301c2-2837-4b0b-bf95-4883a04e5ff7>
#'   Soil Beta Diversity: <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4a428d52-d15c-4bfc-8a67-80697f8c0aa0>
#'   Canopy Height: <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/36c98155-c137-44b8-b4e0-6a3e824bbfba>
#'   Land Surface Phenology: <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/2bb0c81a-5a09-4a0e-bd86-5cd2be8def26>
#'
#' @autoglobal
#' @export
read_tern <- function(
  dataset_id,
  ...,
  api_key = NULL,
  max_tries = NULL,
  initial_delay = NULL
) {
  if (missing(dataset_id)) {
    cli::cli_abort("You must provide a {.arg dataset_id}.")
  }

  # Validate dataset ID and specific arguments *before* checking API key
  dots <- list(...)
  did <- .tern_dispatch_id(dataset_id)
  .tern_validate_args(did, dots, dataset_id)
  api_key <- .check_api_key(api_key %||% get_key())

  # Dispatch to specific dataset helpers
  switch(
    did,
    "d1995ee8" = .read_tern_smips(dots, api_key, max_tries, initial_delay),
    "15728dba" = .read_tern_asc(dots, api_key, max_tries, initial_delay),
    "9fefa68b" = .read_tern_aet(dots, api_key, max_tries, initial_delay),
    "482301c2" = ,  # Switch fall-through for SLGA datasets
    "slga_cly" = ,
    "slga_snd" = ,
    "slga_slt" = ,
    "slga_bdw" = ,
    "slga_phc" = ,
    "slga_phw" = ,
    "slga_nto" = ,
    "slga_avp" = ,
    "slga_pto" = ,
    "slga_cec" = ,
    "slga_ece" = ,
    "slga_dul" = ,
    "slga_l15" = .read_tern_slga(did, dots, api_key, max_tries, initial_delay),
    "4a428d52" = .read_tern_soil_diversity(dots, api_key, max_tries, initial_delay),
    "36c98155" = .read_tern_canopy_height(api_key, max_tries, initial_delay),
    "2bb0c81a" = .read_tern_phenology(dots, api_key, max_tries, initial_delay)
  )
}


#' Alias mapping for short dataset names
#' Maps user-friendly short names (e.g. "SMIPS", "AWC") to dispatch IDs
#' @autoglobal
#' @dev
.tern_aliases <- list(
  SMIPS = "d1995ee8",
  ASC = "15728dba",
  AET = "9fefa68b",
  AWC = "482301c2",
  CLY = "slga_cly",
  SND = "slga_snd",
  SLT = "slga_slt",
  BDW = "slga_bdw",
  PHC = "slga_phc",
  PHW = "slga_phw",
  NTO = "slga_nto",
  AVP = "slga_avp",
  PTO = "slga_pto",
  CEC = "slga_cec",
  ECE = "slga_ece",
  DUL = "slga_dul",
  L15 = "slga_l15",
  SOILDIV = "4a428d52",
  CANOPY = "36c98155",
  PHENOLOGY = "2bb0c81a"
)


#' Normalise a TERN dataset key for switch() dispatch
#'
#' Checks alias table first (case-insensitive), then strips any
#' \code{TERN/}, \code{CSIRO/}, \code{AEKOS/}, or \code{NCI/} prefix
#' and extracts the first 8 lower-case characters of the UUID.
#' Non-UUID identifiers (e.g.\ \code{"AusEFlux_v2"}) are returned as-is
#' after prefix removal.
#'
#' @param id The raw \code{dataset_id} string supplied by the user.
#' @returns A normalised \code{character} string for use in \code{switch()}.
#' @autoglobal
#' @dev
.tern_dispatch_id <- function(id) {
  if (length(id) != 1L) {
    cli::cli_abort(
      "{.arg dataset_id} must be a single character string; \\
       got length {.val {length(id)}}. To collect multiple datasets in one \\
       call use {.fn collect_tern_data}."
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
  tolower(id)
}


#' Emit an informative error for unsupported dataset IDs
#'
#' @param dataset_id The raw dataset ID supplied by the user.
#' @autoglobal
#' @dev
.tern_not_implemented <- function(dataset_id) {
  aliases <- paste0(names(.tern_aliases), collapse = ", ") # nolint: object_usage_linter.
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
  #FIXME: Russell (05/06) as mentioned in Issue #36 discussion, surely
  #  at some point we move these argument validation bits to their own
  #  specific dataset file (e.g., SMIPS validation in read_smips.R) to
  #  improve the SoC.
  switch(
    did,
    # SMIPS (d1995ee8) -- requires date
    "d1995ee8" = {
      date <- if (!is.null(dots[["date"]])) dots[["date"]] else dots[["day"]]
      if (is.null(date)) {
        cli::cli_abort(
          "SMIPS requires a {.arg date} argument (daily resolution),
           e.g.  {.code date = \"2024-01-15\"}."
        )
      }
    },
    # ASC (15728dba) -- no required arguments
    "15728dba" = {
      # Collection defaults to "EV"; no validation needed
    },
    # AET (9fefa68b) -- requires date, must be >= 2000-02-01
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
    "slga_nto" = ,
    "slga_avp" = ,
    "slga_pto" = ,
    "slga_cec" = ,
    "slga_ece" = ,
    "slga_dul" = ,
    "slga_l15" = {
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
      if (length(year) != 1L) {
        cli::cli_abort(
          "Phenology {.arg year} must be a single value; got length \\
           {.val {length(year)}}."
        )
      }
      year_int <- suppressWarnings(as.integer(year))
      if (is.na(year_int) || year_int != year) {
        cli::cli_abort(
          "Phenology {.arg year} must be an integer; got {.val {year}}."
        )
      }
      if (year_int < 2003L || year_int > 2018L) {
        cli::cli_abort(
          "Phenology data are available for years 2003--2018.
           You requested {year_int}."
        )
      }
    },
    .tern_not_implemented(dataset_id)
  )
  invisible(NULL)
}
