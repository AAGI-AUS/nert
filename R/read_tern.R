#' Read TERN COG Datasets
#'
#' A unified interface for reading Cloud Optimised GeoTIFF (\acronym{COG})
#' data from \acronym{TERN} and related repositories.  Dispatches to a
#' dataset-specific handler based on \code{dataset_id} and passes any
#' additional arguments through \code{...}.  The returned object is a
#' [terra::rast()] that can be plotted, cropped, or extracted with standard
#' \pkg{terra} or \pkg{tidyterra} workflows.
#'
#' @section SMIPS -- daily soil moisture (\code{"TERN/d1995ee8"}):
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
#' @section ASC -- Australian Soil Classification (\code{"TERN/15728dba"}):
#' \describe{
#'   \item{\code{collection}}{One of \code{"EV"} (estimated soil order
#'     class, default) or \code{"CI"} (confusion index -- a measure of
#'     mapping reliability).  No \code{date} argument required; this is a
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
#' Data availability: 2000-02-01 onwards.
#'
#' @section SLGA soil attributes -- AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO:
#' A family of 8 static soil properties from the Soil and Landscape Grid of
#' Australia (\acronym{SLGA}), each available at 6 standard depth intervals
#' (0-5, 5-15, 15-30, 30-60, 60-100, 100-200 cm).  90 m resolution.
#' \describe{
#'   \item{\code{collection}}{One of \code{"AWC"} (Available Water Capacity),
#'     \code{"CLY"} (Clay), \code{"SND"} (Sand), \code{"SLT"} (Silt),
#'     \code{"BDW"} (Bulk Density), \code{"PHC"} (pH CaCl2), \code{"PHW"} (pH
#'     water), or \code{"NTO"} (Total Nitrogen).  Required.}
#'   \item{\code{depth}}{Depth interval: \code{"000_005"} (0-5 cm, default),
#'     \code{"005_015"}, \code{"015_030"}, \code{"030_060"}, \code{"060_100"},
#'     or \code{"100_200"}.  Use \code{"all"} to return all 6 depths stacked.}
#'   \item{\code{stat}}{One of \code{"EV"} (estimate, default) or \code{"CI"}
#'     (confidence interval).}
#' }
#' Best accessed via \code{\link{read_slga}()}.
#'
#' @section SOILDIV -- Soil Beta Diversity:
#' Bacteria and Fungi NMDS ordination axes (1-3) from soil surveys.  90 m
#' resolution, static.
#' \describe{
#'   \item{\code{kingdom}}{One of \code{"Bacteria"} (default) or
#'     \code{"Fungi"}.}
#'   \item{\code{axis}}{Axis 1, 2, or 3 (default 1).  Use \code{"all"} for all
#'     6 axes stacked.}
#' }
#' Best accessed via \code{\link{read_soil_diversity}()}.
#'
#' @section CANOPY -- Canopy Height 30 m (OzTreeMap):
#' Composite canopy height model from remote sensing validation.  30 m
#' resolution; \acronym{CRS} is \code{EPSG:3577} (projected).
#' Note: extraction at point locations (in geographic coordinates) requires
#' prior CRS transformation.  No arguments needed beyond \code{api_key}.
#' Best accessed via \code{\link{read_canopy_height}()}.
#'
#' @section PHENOLOGY -- Land Surface Phenology (MODIS):
#' Start or End of Growing Season derived from MODIS \acronym{NDVI}.  500 m
#' resolution; years 2003-2018.
#' \describe{
#'   \item{\code{metric}}{One of \code{"SGS"} (Start of Growing Season, default)
#'     or \code{"EGS"} (End of Growing Season).}
#'   \item{\code{year}}{Year from 2003 to 2018 (default 2018).}
#'   \item{\code{season}}{Season number (default 1).}
#' }
#' Best accessed via \code{\link{read_phenology}()}.
#'
#' @section Datasets not implemented:
#' The following datasets are inaccessible or require further development:
#' \itemize{
#'   \item \code{TERN/0997cb3c} -- Seasonal Fractional Cover (legacy redirect;
#'     COGs not accessible via HTTP range request)
#'   \item \code{TERN/fe9d86e1} -- Seasonal Ground Cover (same issue)
#' }
#' Datasets with integration level L2 or higher (e.g.\ AusEFlux via
#' \acronym{THREDDS}/OPeNDAP, GEE-based products, site-level API streams)
#' cannot be read via simple COG HTTP range requests and are outside the
#' current scope of \pkg{nert}.
#'
#' @param dataset_id A \code{character} string identifying the dataset.
#'   Accepts the full \acronym{TERN} portal key (e.g.\
#'   \code{"TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0"}), the
#'   8-character key prefix (e.g.\ \code{"TERN/d1995ee8"}), or a short
#'   alias (e.g.\ \code{"SMIPS"}, \code{"AWC"}).  Currently supported datasets:
#'   \tabular{ll}{
#'     \strong{Alias} \tab \strong{Dataset} \cr
#'     \code{"SMIPS"} \tab Daily soil moisture (1 km, 2015-present) \cr
#'     \code{"ASC"} \tab Australian Soil Classification (90 m, static) \cr
#'     \code{"AET"} \tab Evapotranspiration/CMRSET (30 m, 2000-present) \cr
#'     \code{"AWC"} \tab SLGA Available Water Capacity (90 m, 6 depths) \cr
#'     \code{"CLY"} \tab SLGA Clay content (90 m, 6 depths) \cr
#'     \code{"SND"} \tab SLGA Sand content (90 m, 6 depths) \cr
#'     \code{"SLT"} \tab SLGA Silt content (90 m, 6 depths) \cr
#'     \code{"BDW"} \tab SLGA Bulk Density (90 m, 6 depths) \cr
#'     \code{"PHC"} \tab SLGA pH (CaCl2) (90 m, 6 depths) \cr
#'     \code{"PHW"} \tab SLGA pH (water) (90 m, 6 depths) \cr
#'     \code{"NTO"} \tab SLGA Total Nitrogen (90 m, 6 depths) \cr
#'     \code{"SOILDIV"} \tab Soil Beta Diversity (90 m, static) \cr
#'     \code{"CANOPY"} \tab Canopy Height (30 m, static) \cr
#'     \code{"PHENOLOGY"} \tab Land Surface Phenology (500 m, 2003-2018) \cr
#'   }
#' @param ... Dataset-specific arguments -- \code{date}, \code{collection},
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
#' # Using aliases (short form)
#' r <- read_tern("SMIPS", date = "2024-01-15")
#' r_asc <- read_tern("ASC")
#' autoplot(r_asc)
#'
#' # Or using full TERN keys (old form still works)
#' r2 <- read_tern("TERN/d1995ee8", date = "2024-01-15")
#'
#' # SMIPS -- multiple collections
#' r_smi <- read_tern("SMIPS", date = "2024-01-15", collection = "SMindex")
#'
#' # ASC -- confusion index
#' r_ci <- read_tern("ASC", collection = "CI")
#'
#' # AET -- monthly evapotranspiration
#' r_aet <- read_tern("AET", date = "2023-06-01")
#'
#' # SLGA -- available water capacity, depth 5-15 cm
#' r_awc <- read_tern("AWC", depth = "005_015")
#'
#' # SLGA -- all depths stacked
#' r_awc_all <- read_tern("AWC", depth = "all")
#'
#' # Soil diversity -- Fungi NMDS axis 2
#' r_fungi <- read_tern("SOILDIV", kingdom = "Fungi", axis = 2)
#'
#' # Canopy height
#' r_canopy <- read_tern("CANOPY")
#'
#' # Phenology -- End of Growing Season, 2018
#' r_egs <- read_tern("PHENOLOGY", metric = "EGS", year = 2018)
#'
#' @returns A [terra::rast()] object of the national mosaic for the
#'   requested dataset (and, where applicable, date/collection).
#'
#' @references
#'   SMIPS portal:
#'   <https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#'
#'   ASC portal:
#'   <https://portal.tern.org.au/metadata/TERN/15728dba-b49c-4da5-9073-13d8abe67d7c>
#'
#'   AET portal:
#'   <https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
#'
#'   AET DOI: <https://dx.doi.org/10.25901/gg27-ck96>
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
    "482301c2" = .read_tern_slga("AWC", dots, api_key, max_tries, initial_delay),
    "slga_cly" = .read_tern_slga("CLY", dots, api_key, max_tries, initial_delay),
    "slga_snd" = .read_tern_slga("SND", dots, api_key, max_tries, initial_delay),
    "slga_slt" = .read_tern_slga("SLT", dots, api_key, max_tries, initial_delay),
    "slga_bdw" = .read_tern_slga("BDW", dots, api_key, max_tries, initial_delay),
    "slga_phc" = .read_tern_slga("PHC", dots, api_key, max_tries, initial_delay),
    "slga_phw" = .read_tern_slga("PHW", dots, api_key, max_tries, initial_delay),
    "slga_nto" = .read_tern_slga("NTO", dots, api_key, max_tries, initial_delay),
    "4a428d52" = .read_tern_soildiv(dots, api_key, max_tries, initial_delay),
    "36c98155" = .read_tern_canopy(dots, api_key, max_tries, initial_delay),
    "2bb0c81a" = .read_tern_phenology(dots, api_key, max_tries, initial_delay),
    .tern_not_implemented(dataset_id)
  )
}


# -- Aliases and metadata tables -----------------------------------------------

#' Alias mapping for short dataset names
#' Maps user-friendly short names (e.g. "SMIPS", "AWC") to dispatch IDs
#' @autoglobal
#' @dev
.TERN_ALIASES <- c(
  SMIPS     = "d1995ee8",
  ASC       = "15728dba",
  AET       = "9fefa68b",
  AWC       = "482301c2",
  CLY       = "slga_cly",
  SND       = "slga_snd",
  SLT       = "slga_slt",
  BDW       = "slga_bdw",
  PHC       = "slga_phc",
  PHW       = "slga_phw",
  NTO       = "slga_nto",
  SOILDIV   = "4a428d52",
  CANOPY    = "36c98155",
  PHENOLOGY = "2bb0c81a"
)

#' SLGA metadata: version, suffix, date for each soil attribute
#' @autoglobal
#' @dev
.SLGA_META <- list(
  AWC = list(subdir = "AWC",  ver = "v2", date = "20210614", suffix = "AU_TRN_N"),
  CLY = list(subdir = "CLY",  ver = "v2", date = "20210902", suffix = "AU_TRN_N"),
  SND = list(subdir = "SND",  ver = "v2", date = "20210902", suffix = "AU_TRN_N"),
  SLT = list(subdir = "SLT",  ver = "v2", date = "20210902", suffix = "AU_TRN_N"),
  BDW = list(subdir = "BDW",  ver = "v2", date = "20230607", suffix = "AU_TRN_N"),
  PHC = list(subdir = "pHc",  ver = "v2", date = "20210913", suffix = "AU_NAT_C"),
  PHW = list(subdir = "PHW",  ver = "v1", date = "20220520", suffix = "AU_TRN_N"),
  NTO = list(subdir = "NTO",  ver = "v2", date = "20231101", suffix = "AU_NAT_C")
)

#' Phenology metric metadata: index and directory name
#' @autoglobal
#' @dev
.PHENOLOGY_METRICS <- list(
  SGS = list(idx = 1, dir = "Start_of_the_growing_season", abbr = "SGS"),
  EGS = list(idx = 3, dir = "End_of_the_growing_season",   abbr = "EGS")
)


# -- Dispatch helpers ----------------------------------------------------------

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
  id <- trimws(as.character(id[[1L]]))

  # Check alias table first (case-insensitive)
  upper_id <- toupper(id)
  if (upper_id %in% names(.TERN_ALIASES)) {
    return(.TERN_ALIASES[[upper_id]])
  }

  # Strip TERN/ and other prefixes
  id <- sub("^(?:TERN|CSIRO|AEKOS|NCI)/", "", id, perl = TRUE)

  # UUID-like string: keep only the first 8 hex chars
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
  cli::cli_abort(c(
    "Dataset {.val {dataset_id}} is not currently implemented in
     {.fn read_tern}.",
    "i" = "14 datasets supported: SMIPS, ASC, AET, AWC, CLY, SND, SLT, BDW,
           PHC, PHW, NTO, SOILDIV, CANOPY, PHENOLOGY.
           Use short aliases ({.code \"SMIPS\"}, {.code \"AWC\"}, etc.)
           or full TERN keys.",
    "i" = "Inaccessible datasets (legacy COG redirects):
           {.code TERN/0997cb3c} (Seasonal Fractional Cover),
           {.code TERN/fe9d86e1} (Seasonal Ground Cover).",
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
    # SLGA group (AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO)
    "482301c2" = , "slga_cly" = , "slga_snd" = , "slga_slt" = ,
    "slga_bdw" = , "slga_phc" = , "slga_phw" = , "slga_nto" = {
      # Validate depth and stat if provided
      if (!is.null(dots[["depth"]]) && !(dots[["depth"]] %in% c("000_005", "005_015", "015_030", "030_060", "060_100", "100_200", "all"))) {
        cli::cli_abort(
          "SLGA {.arg depth} must be one of: {.code \"000_005\"}, {.code \"005_015\"}, {.code \"015_030\"}, {.code \"030_060\"}, {.code \"060_100\"}, {.code \"100_200\"}, or {.code \"all\"}."
        )
      }
      if (!is.null(dots[["stat"]]) && !(dots[["stat"]] %in% c("EV", "CI"))) {
        cli::cli_abort("SLGA {.arg stat} must be either {.code \"EV\"} or {.code \"CI\"}.")
      }
    },
    # Soil Diversity (4a428d52)
    "4a428d52" = {
      if (!is.null(dots[["kingdom"]]) && !(dots[["kingdom"]] %in% c("Bacteria", "Fungi", "all"))) {
        cli::cli_abort("Soil Diversity {.arg kingdom} must be {.code \"Bacteria\"}, {.code \"Fungi\"}, or {.code \"all\"}.")
      }
      if (!is.null(dots[["axis"]]) && !(dots[["axis"]] %in% c(1, 2, 3, "all"))) {
        cli::cli_abort("Soil Diversity {.arg axis} must be 1, 2, 3, or {.code \"all\"}.")
      }
    },
    # Canopy Height (36c98155) -- no required arguments
    "36c98155" = {
      # No validation needed
    },
    # Phenology (2bb0c81a)
    "2bb0c81a" = {
      if (!is.null(dots[["metric"]]) && !(dots[["metric"]] %in% c("SGS", "EGS"))) {
        cli::cli_abort("Phenology {.arg metric} must be {.code \"SGS\"} or {.code \"EGS\"}.")
      }
      if (!is.null(dots[["year"]]) && (dots[["year"]] < 2003 || dots[["year"]] > 2018)) {
        cli::cli_abort("Phenology {.arg year} must be between 2003 and 2018 (inclusive).")
      }
    },
    # Unknown dataset
    .tern_not_implemented(dataset_id)
  )
  invisible(NULL)
}


# -- SMIPS handler -------------------------------------------------------------

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


# -- ASC handler ---------------------------------------------------------------

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


# -- AET handler ---------------------------------------------------------------

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


# -- AET date/URL helpers (moved from aet.R) -----------------------------------

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


# -- SLGA handler ---------------------------------------------------------------

#' Internal handler for SLGA soil attributes
#'
#' Reads any of 8 SLGA attributes (AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO)
#' at one or more depth intervals (or all 6).
#'
#' @param collection SLGA attribute code (e.g. "AWC", "CLY").
#' @param dots Named list including `depth` and `stat` if provided.
#' @param api_key,max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_slga <- function(collection, dots, api_key, max_tries, initial_delay) {
  depth <- if (!is.null(dots[["depth"]])) dots[["depth"]] else "000_005"
  stat  <- if (!is.null(dots[["stat"]]))  dots[["stat"]]  else "EV"

  # Get metadata for this attribute
  meta <- .SLGA_META[[collection]]
  if (is.null(meta)) {
    cli::cli_abort("Unknown SLGA collection {.val {collection}}.")
  }

  # Handle "all" depths: return stacked raster
  if (tolower(depth) == "all") {
    all_depths <- c("000_005", "005_015", "015_030", "030_060", "060_100", "100_200")
    rasters <- lapply(all_depths, function(d) {
      .read_tern_slga(collection, list(depth = d, stat = stat), api_key, max_tries, initial_delay)
    })
    # Stack and assign names
    r <- do.call(c, rasters)
    names(r) <- paste0(collection, "_", all_depths)
    return(r)
  }

  # Single depth: construct URL and fetch
  fname <- sprintf(
    "%s_%s_%s_N_P_%s_%s.tif",
    collection, depth, stat, meta$suffix, meta$date
  )
  path <- sprintf(
    "model-derived/slga/NationalMaps/SoilAndLandscapeGrid/%s/%s/%s",
    meta$subdir, meta$ver, fname
  )
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/%s",
    api_key, path
  )
  .read_cog(full_url, max_tries, initial_delay)
}


# -- Soil Diversity handler -----------------------------------------------------

#' Internal handler for Soil Beta Diversity (TERN/4a428d52)
#'
#' Reads NMDS ordination axes for Bacteria or Fungi.
#'
#' @param dots Named list including `kingdom` and `axis` if provided.
#' @param api_key,max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_soildiv <- function(dots, api_key, max_tries, initial_delay) {
  kingdom <- if (!is.null(dots[["kingdom"]])) dots[["kingdom"]] else "Bacteria"
  axis    <- if (!is.null(dots[["axis"]]))    dots[["axis"]]    else 1

  # Handle "all" kingdoms: return all 6 axes (Bacteria 1-3, Fungi 1-3)
  if (tolower(kingdom) == "all") {
    axes_list <- list()
    for (k in c("Bacteria", "Fungi")) {
      for (a in 1:3) {
        r <- .read_tern_soildiv(
          list(kingdom = k, axis = a),
          api_key, max_tries, initial_delay
        )
        axes_list[[length(axes_list) + 1]] <- r
      }
    }
    r <- do.call(c, axes_list)
    names(r) <- c(
      "NMDS_Bacteria_1", "NMDS_Bacteria_2", "NMDS_Bacteria_3",
      "NMDS_Fungi_1", "NMDS_Fungi_2", "NMDS_Fungi_3"
    )
    return(r)
  }

  fname <- sprintf("NMDS_%s_%d_%s_pred.tif", kingdom, axis, kingdom)
  path <- sprintf("model-derived/slga/NationalMaps/Other/SoilBetaDiversity/%s", fname)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/%s",
    api_key, path
  )
  .read_cog(full_url, max_tries, initial_delay)
}


# -- Canopy Height handler ------------------------------------------------------

#' Internal handler for Canopy Height (TERN/36c98155)
#'
#' Reads OzTreeMap canopy height composite at 30 m resolution.
#' Note: CRS is EPSG:3577 (projected).
#'
#' @param dots Named list (unused; provided for consistency).
#' @param api_key,max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_canopy <- function(dots, api_key, max_tries, initial_delay) {
  path <- "model-derived/OzTreeMap/CanopyHeightComposite/best_pick_files_bhLNnun.tif"
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/%s",
    api_key, path
  )
  .read_cog(full_url, max_tries, initial_delay)
}


# -- Phenology handler ----------------------------------------------------------

#' Internal handler for Land Surface Phenology (TERN/2bb0c81a)
#'
#' Reads MODIS-derived Start or End of Growing Season for 2003-2018.
#'
#' @param dots Named list including `metric`, `year`, `season` if provided.
#' @param api_key,max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_phenology <- function(dots, api_key, max_tries, initial_delay) {
  metric <- if (!is.null(dots[["metric"]])) dots[["metric"]] else "SGS"
  year   <- if (!is.null(dots[["year"]]))   dots[["year"]]   else 2018
  season <- if (!is.null(dots[["season"]])) dots[["season"]] else 1

  # Get metric metadata
  m <- .PHENOLOGY_METRICS[[metric]]
  if (is.null(m)) {
    cli::cli_abort("Unknown phenology metric {.val {metric}}. Must be {.code \"SGS\"} or {.code \"EGS\"}.")
  }

  fname <- sprintf("%s_%d_Season%d.tif", m$abbr, year, season)
  path <- sprintf(
    "remote-sensing/modis/phenology_myd13a1/%d_%s/%s",
    m$idx, m$dir, fname
  )
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/%s",
    api_key, path
  )
  .read_cog(full_url, max_tries, initial_delay)
}
