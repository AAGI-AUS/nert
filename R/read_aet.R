#' Read AET (evapotranspiration) COGs from TERN
#'
#' Read model-derived Actual Evapotranspiration (AET) Cloud Optimised GeoTIFF
#' (COG) files from TERN into R. Uses the package API helpers and internal
#' `.read_cog()` to perform downloads with retry/backoff.
#'
#' @param file Optional character: exact filename in the TERN AET directory
#'   (e.g. "AET_CMRSET_MONTH_2023-01.tif"). If provided, used directly.
#' @param day Optional Date or character coercible to Date. If `file` is NULL,
#'   a filename will be constructed from `day` using a year-month convention.
#' @param api_key Character: TERN API key. Defaults to `get_key()`.
#' @param max_tries Integer: number of download attempts. Default 3.
#' @param initial_delay Numeric: initial backoff delay (seconds). Default 1.
#' @details
#' Confirm the naming convention used at:
#' https://data.tern.org.au/model-derived/aet/v2_2/
#' The implementation below assumes `AET_CMRSET_MONTH_YYYY-MM.tif` filenames.
#' Adjust the sprintf() line if filenames differ.
#' @family COGs
#' @returns A [terra::rast()] object (or single layer of that raster).
#' @source <https://data.tern.org.au/model-derived/aet/v2_2/>
#' @examplesIf interactive()
#' \dontrun{
#' r <- read_aet(file = "AET_CMRSET_MONTH_2023-01.tif")
#' plot(r)
#' r2 <- read_aet(day = "2023-01-01")
#' autoplot(r2)
#' }
#' @export
read_aet <- function(
  file = NULL,
  day = NULL,
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
) {
  api_key <- .check_api_key(api_key)

  if (is.null(file)) {
    if (is.null(day)) {
      cli::cli_abort("You must provide either `file` or `day` to identify the AET file to download.")
    }
    day_date <- as.Date(day)
    # Default naming assumption (adjust if TERN uses another scheme):
    # AET_CMRSET_MONTH_YYYY-MM.tif
    file <- sprintf("AET_CMRSET_MONTH_%s-%s.tif", format(day_date, "%Y"), format(day_date, "%m"))
  }

  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/aet/v2_2/%s",
    api_key,
    file
  )

  return(.read_cog(full_url, max_tries = max_tries, initial_delay = initial_delay))
}
