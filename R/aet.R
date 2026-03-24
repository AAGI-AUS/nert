#' Read AET COGs from TERN
#'
#' Read Actual Evapotranspiration (\acronym{AET}) using the \acronym{CMRSET}
#' algorithm Cloud Optimised Geotiff (\acronym{COG}) files from \acronym{TERN}
#' in your \R session.
#'
#' @param month A month to query, _e.g.,_ `month = "2023-01-01"` or
#'   `month = as.Date("2023-01-01")`.  Both `Character` and `Date` classes are
#'   accepted.  The value is snapped to the first of the month internally.
#' @param collection A `character` string of the \acronym{AET} data collection
#'   to be queried:
#'   * `"ETa"`: the primary \acronym{AET} band (mm/month),
#'   * `"pixel_qa"`: the quality assurance flag band.
#'   Defaults to `"ETa"`.
#' @param api_key A `character` string containing your \acronym{API} key,
#'   a random string provided to you by \acronym{TERN}, for the request.
#'   Defaults to automatically detecting your key from your local .Renviron,
#'   .Rprofile or similar.  Alternatively, you may directly provide your key as
#'   a string here or use functionality like that from \CRANpkg{keyring}.  If
#'   nothing is provided, you will be prompted on how to set up your \R session
#'   so that it is auto-detected and a browser window will open at the
#'   \acronym{TERN} website for you to request a key.
#' @param max_tries An `Integer` with the number of times to retry a failed
#'   download before emitting an error message.  Defaults to 3.
#' @param initial_delay An `Integer` with the number of seconds to delay before
#'   retrying the download.  This increases as the tries increment.  Defaults
#'   to 1.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#'
#' r <- read_aet(month = "2023-01-01")
#'
#' # `tidyterra::autoplot` is re-exported for convenience
#' autoplot(r)
#'
#' @returns A [terra::rast()] object of the national mosaic for the requested
#'   month.
#'
#' @autoglobal
#' @references
#'   \acronym{TERN} portal:
#'   <https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
#'
#'   \acronym{DOI}: <https://dx.doi.org/10.25901/gg27-ck96>
#' @export
read_aet <- function(
  month,
  collection = "ETa",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
) {
  api_key <- .check_api_key(api_key)
  if (missing(month)) {
    cli::cli_abort("You must provide a month for this request.")
  }
  month <- .check_aet_date(month)
  full_url <- .make_aet_url(
    .collection = collection,
    .month = month,
    .api_key = api_key
  )
  return(.read_cog(full_url, max_tries, initial_delay))
}


#' Extract AET Values at Point Locations
#'
#' Extract Actual Evapotranspiration (\acronym{AET}) values from the
#' \acronym{CMRSET} algorithm data at point locations and return a
#' [data.table::data.table].
#'
#' @param xy Point locations in one of three formats:
#'   * A named list, _e.g.,_
#'     `list("Corrigin" = c(x = 117.87, y = -32.33))`
#'   * A `data.frame` with columns `location`, `x` (longitude), and `y`
#'     (latitude)
#'   * An [sf::sf] POINT object with a `location` column
#' @inheritParams read_aet
#'
#' @family COGs
#'
#' @examplesIf interactive()
#'
#' locs <- list(
#'   "Corrigin" = c(x = 117.87, y = -32.33),
#'   "Merredin" = c(x = 118.28, y = -31.48),
#'   "Tamworth" = c(x = 150.84, y = -31.07)
#' )
#' tab <- extract_aet(xy = locs, month = "2023-01-01")
#' tab
#'
#' @returns A [data.table::data.table] with columns `location`, `x`, `y`, and
#'   `aet_{collection}_{YYYYMM}` (_e.g.,_ `aet_ETa_202301`).
#'
#' @autoglobal
#' @references
#'   \acronym{TERN} portal:
#'   <https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
#'
#'   \acronym{DOI}: <https://dx.doi.org/10.25901/gg27-ck96>
#' @export
extract_aet <- function(
  xy,
  month,
  collection = "ETa",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
) {
  if (missing(month)) {
    cli::cli_abort("You must provide a month for this request.")
  }
  month <- .check_aet_date(month)
  r <- read_aet(
    month = month,
    collection = collection,
    api_key = api_key,
    max_tries = max_tries,
    initial_delay = initial_delay
  )
  pts <- .create_sf(xy)
  col_name <- sprintf("aet_%s_%s", collection, format(month, "%Y%m"))
  coords <- sf::st_coordinates(pts)
  extracted <- terra::extract(
    r,
    data.frame(x = coords[, "X"], y = coords[, "Y"])
  )
  dt <- data.table::data.table(
    location = pts$location,
    x = coords[, "X"],
    y = coords[, "Y"]
  )
  data.table::set(dt, j = col_name, value = extracted[[2L]])
  return(dt)
}


#' Check User Input Months for AET Validity
#'
#' Validates and snaps a user-supplied date value to the first of the month,
#' then checks it against the \acronym{AET} data availability window
#' (from 2000-02-01 onwards).
#'
#' @param x User-entered date value (any format accepted by [.check_date()]).
#' @returns A `POSIXct` object snapped to the first of the requested month.
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
       You requested { format(x, '%Y-%m-%d') }."
    )
  }
  return(x)
}


#' Create an AET URL
#'
#' Builds the full \acronym{GDAL} vsicurl URL for a given \acronym{AET}
#' collection and month.
#'
#' @param .collection The user-supplied \acronym{AET} collection being asked
#'   for (`"ETa"` or `"pixel_qa"`).
#' @param .month The validated `POSIXct` date snapped to the first of the
#'   month.
#' @param .api_key The \acronym{URL}-encoded \acronym{API} key.
#'
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
