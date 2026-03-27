#' Read TERN COG Datasets
#'
#' A unified interface for reading Cloud Optimised GeoTIFF (\acronym{COG})
#' data from \acronym{TERN} and related repositories.  Dispatches to a
#' dataset-specific handler based on `dataset_id` and passes any additional
#' arguments through `...`.  The returned object is a [terra::rast()] that can
#' be plotted, cropped, or extracted with standard \pkg{terra} or
#' \pkg{tidyterra} workflows.
#'
#' @section SMIPS — daily soil moisture (`"TERN/d1995ee8"`):
#' \describe{
#'   \item{`date`}{Required.  A single day to query, _e.g._ `"2024-01-15"` or
#'     `as.Date("2024-01-15")`.  Both `Character` and `Date` classes are
#'     accepted.}
#'   \item{`collection`}{One of `"totalbucket"` (default), `"SMindex"`,
#'     `"bucket1"`, `"bucket2"`, `"deepD"`, or `"runoff"`.}
#' }
#' Data availability: 2015-11-20 to approximately 7 days before today.
#'
#' @section ASC — Australian Soil Classification (`"TERN/15728dba"`):
#' \describe{
#'   \item{`collection`}{One of `"EV"` (estimated soil order class,
#'     default) or `"CI"` (confusion index — a measure of mapping reliability).
#'     No `date` argument required; this is a static product.}
#' }
#'
#' @section AET — Actual Evapotranspiration/CMRSET (`"TERN/9fefa68b"`):
#' \describe{
#'   \item{`date`}{Required.  A month to query, _e.g._
#'     `"2023-06-01"90` or `as.Date("2023-06-01")`.  Both
#'     `Character` and `Date` classes are accepted.  The value is
#'     snapped to the first of the month internally.}
#'   \item{`collection`}{One of `"ETa"` (primary AET band in
#'     mm/month, default) or `"pixel_qa"` (quality assurance flags).}
#' }
#' Data availability: 2000-02-01 onwards.
#'
#' @section Datasets not yet implemented:
#' The following priority datasets are tracked in the \acronym{TERN}
#' catalogue and are planned for a future release.  They require
#' verification of COG file-naming patterns against the live \acronym{TERN}
#' data server before they can be safely included:
#' \itemize{
#'   \item `TERN/482301c2` — SLGA Available Volumetric Water Capacity
#'   \item `TERN/4a428d52` — SLGA Soil Bacteria and Fungi Beta Diversity
#'   \item `TERN/0997cb3c` — Seasonal Fractional Cover (Landsat)
#'   \item `TERN/fe9d86e1` — Seasonal Ground Cover (Landsat)
#'   \item `TERN/36c98155` — Canopy Height Models 30 m
#'   \item `TERN/2bb0c81a` — Australian Land Surface Phenology
#'   \item `TERN/PAV_slga` — SLGA Available Phosphorus
#' }
#' Datasets with integration level L2 or higher (*e.g.* AusEFlux via
#' \acronym{THREDDS}/OPeNDAP, GEE-based products, site-level API streams)
#' cannot be read via simple COG HTTP range requests and are outside the
#' current scope of \pkg{nert}.
#'
#' @param dataset_id A `character` string identifying the dataset.
#'   Accepts the full \acronym{TERN} portal key (*e.g.*
#'   `"TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0"`) or the
#'   8-character key prefix (*e.g.* `"TERN/d1995ee8"`).  Currently
#'   supported keys:
#'   \tabular{ll}{
#'     `"TERN/d1995ee8"` \tab SMIPS daily soil moisture \cr
#'     `"TERN/15728dba"` \tab Australian Soil Classification (ASC) \cr
#'     `"TERN/9fefa68b"` \tab AET/CMRSET evapotranspiration \cr
#'   }
#' @param ... Dataset-specific arguments — `date`, `collection`,
#'   etc.  See the relevant section above for each dataset.
#' @param api_key A `character` string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection from your
#'   `.Renviron` or `.Rprofile`.  See `get_key` for setup instructions.
#' @param max_tries An `integer` giving the maximum number of download
#'   retries before an error is raised.  Defaults to `3`.
#' @param initial_delay An `integer` giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to `1`.
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
#' # SMIPS — soil moisture index collection
#' r_smi <- read_tern("SMIPS", date = "2024-01-15",
#'                    collection = "SMindex")
#'
#' # ASC — confusion index
#' r_ci <- read_tern("ASC", collection = "CI")
#'
#' # Full TERN keys still work ────────────────────────────────────
#' r2 <- read_tern("TERN/d1995ee8", date = "2024-01-15")
#'
#' # Full UUID keys are also accepted
#' r3 <- read_tern(
#'   "TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0",
#'   date = "2024-01-15"
#' )
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
  api_key = NULL,
  max_tries = 3L,
  initial_delay = 1L
) {
  if (missing(dataset_id)) {
    cli::cli_abort("You must provide a {.arg dataset_id}.")
  }

  # Validate dataset ID and collect dots *before* checking the API key so that
  # input-validation errors surface even when the key is not configured (e.g.
  # in CI without TERN_API_KEY).
  did <- .tern_dispatch_id(dataset_id)
  dots <- list(...)

  # Validate dataset-specific arguments before requiring the API key
  .tern_validate_args(did, dots, dataset_id)

  api_key <- .check_api_key(api_key %||% get_key())

  switch(
    did,
    "d1995ee8" = .read_tern_smips(dots, api_key, max_tries, initial_delay),
    "15728dba" = .read_tern_asc(dots, api_key, max_tries, initial_delay),
    "9fefa68b" = .read_tern_aet(dots, api_key, max_tries, initial_delay)
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
  SMIPS = "d1995ee8",
  ASC   = "15728dba",
  AET   = "9fefa68b"
)


#' Normalise a TERN dataset key for switch() dispatch
#'
#' Strips any \code{TERN/}, \code{CSIRO/}, \code{AEKOS/}, or \code{NCI/}
#' prefix, then extracts the first 8 lower-case characters of the UUID.
#' Non-UUID identifiers (_e.g._ \code{"AusEFlux_v2"}) are returned as-is
#' after prefix removal.
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
  cli::cli_abort(c(
    "Dataset {.val {dataset_id}} is not currently implemented in
     {.fn read_tern}.",
    "i" = "Supported datasets: {.code \"SMIPS\"} ({.code TERN/d1995ee8}),
           {.code \"ASC\"} ({.code TERN/15728dba}),
           {.code \"AET\"} ({.code TERN/9fefa68b}).",
    "i" = "Priority COG datasets planned for a future release:
           SLGA soil attributes (AWC, bacteria/fungi, phosphorus),
           Seasonal Fractional Cover, Seasonal Ground Cover,
           Canopy Height, Land Surface Phenology.
           These require URL file-naming verification before inclusion.",
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
  collection <- if (!is.null(dots[["collection"]])) {
    dots[["collection"]]
  } else {
    "totalbucket"
  }

  day <- .check_date(date)
  dl_file <- .make_smips_url(.collection = collection, .day = day)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/smips/v1_0/%s/%s/%s",
    api_key,
    collection,
    lubridate::year(day),
    dl_file
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
  collection <- if (!is.null(dots[["collection"]])) {
    dots[["collection"]]
  } else {
    "EV"
  }

  approved <- c("EV", "CI")
  collection <- rlang::arg_match(collection, approved)

  dl_file <- data.table::fifelse(
    collection == "EV",
    "ASC_EV_C_P_AU_TRN_N.cog.tif",
    "ASC_CI_C_P_AU_TRN_N.cog.tif"
  )
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/%s",
    api_key,
    dl_file
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
  collection <- if (!is.null(dots[["collection"]])) {
    dots[["collection"]]
  } else {
    "ETa"
  }

  month <- .check_aet_date(date)
  full_url <- .make_aet_url(
    .collection = collection,
    .month = month,
    .api_key = api_key
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
  x <- .check_date(x)
  x <- lubridate::floor_date(x, "month")
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

  year <- lubridate::year(.month)
  date_str <- format(.month, "%Y_%m_%d")

  sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/landscapes/aet/v2_2/%s/%s/CMRSET_LANDSAT_V2_2_%s_%s.vrt",
    .api_key,
    year,
    date_str,
    date_str,
    collection
  )
}
