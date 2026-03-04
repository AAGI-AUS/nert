#' Read AET COGs from TERN
#'
#' Read Actual Evapotranspiration (\acronym{AET}) Cloud Optimised Geotiff
#'  (\acronym{COG}) files from \acronym{TERN} in your \R session. The data are
#'  modelled estimates of actual evapotranspiration at a 90 m resolution across
#'  Australia from the TERN model-derived CMRSET Landsat dataset (version 2.2).
#'  Monthly data are available from 1987 onwards.
#'
#' @param day A date to query, _e.g._, `day = "2024-01-01"` or `day =
#'  as.Date("2024-01-01")`, both `Character` and `Date` classes are accepted.
#'  Alternatively, you can provide year and month separately using the
#'  `year` and `month` parameters (see details).
#' @param year An integer specifying the year of AET data to download,
#'   _e.g._, `year = 2024`. Data are available from 1987 onwards.
#'   Only used if `day` is not provided.
#' @param month An integer specifying the month (1-12) of AET data to download,
#'   _e.g._, `month = 1` for January. Defaults to 1 (January).
#'   Only used if `day` is not provided.
#' @param qa A `Boolean` value indicating whether to read the pixel quality
#'   assurance data (`TRUE`) or the AET estimates (`FALSE`). Defaults to
#'   `FALSE` to read the AET values.
#'
#' @param api_key A `character` string containing your \acronym{API} key,
#'   a random string provided to you by \acronym{TERN}, for the request.
#'   Defaults to automatically detecting your key from your local .Renviron,
#'   .Rprofile or similar.  Alternatively, you may directly provide your key as
#'   a string here or use functionality like that from \CRANpkg{keyring}.  If
#'   nothing is provided, you will be prompted on how to set up your \R session
#'   so that it is auto-detected and a browser window will open at the
#'   \acronym{TERN} website for you to request a key.
#' @param max_tries An integer with the number of times to retry a
#'   failed download before emitting an error message.  Defaults to 3.
#' @param initial_delay An integer with the number of seconds to delay before
#'   retrying the download.  This increases as the tries increment.  Defaults to
#'   1.
#'
#' @details
#' Actual Evapotranspiration (AET) represents the quantity of water transferred
#' from the land to the atmosphere through evaporation and plant transpiration.
#' The TERN AET dataset is derived from the CMRSET (Calibrated Remote Sensing
#' Evapotranspiration) Landsat algorithm and provides continuous monthly
#' estimates of AET across Australia at 90m resolution. This is valuable for
#' hydrological modelling, agricultural planning, and water resource management.
#'
#' The dataset is organised by year and month, with data available from 1987
#' onwards. Each month contains multiple COG tiles that are stitched together
#' using a Virtual Raster Table (VRT) file.
#'
#' You can provide the date to query in two ways:
#' \enumerate{
#'   \item Using `day` parameter with a date string (e.g., `"2024-01-01"`)
#'         or Date/POSIXct object - this is the recommended approach.
#'   \item Using separate `year` and `month` parameters (e.g., `year = 2024,
#'         month = 1`).
#' }
#' If both `day` and `year`/`month` are provided, `day` takes precedence.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#'
#' # Using day parameter with date string
#' r <- read_aet(day = "2024-01-01")
#' r
#'
#' # Using year and month parameters
#' r <- read_aet(year = 2024, month = 1)
#' r
#'
#' # Visualize the AET data
#' library(tidyterra)
#' autoplot(r)
#'
#' # Read quality assurance data instead
#' r_qa <- read_aet(day = "2024-01-01", qa = TRUE)
#'
#' @returns A [terra::rast()] object containing the AET data or QA data.
#'
#' @source
#' \describe{
#'  \item{AET Data Portal}{<https://data.tern.org.au/model-derived/aet/v2_2/>}
#'  \item{CMRSET Algorithm}{<https://cmrset.com.au/>}
#'  }
#'
#' @autoglobal
#' @references <https://portal.tern.org.au/search?query=evapotranspiration>
#' @export
read_aet <- function(
    day,
    year,
    month = 1L,
    qa = FALSE,
    api_key = get_key(),
    max_tries = 3L,
    initial_delay = 1L
) {
  api_key <- .check_api_key(api_key)
  
  # If day is provided, extract year and month from it
  if (!missing(day)) {
    # Validate and parse the date
    if (length(day) > 1L) {
      cli::cli_abort("Only one day is allowed per request.")
    }
    
    if (lubridate::is.POSIXct(day) || lubridate::is.Date(day)) {
      tz <- lubridate::tz(day)
    } else {
      tz <- Sys.timezone()
    }
    
    tryCatch(
      {
        day <- lubridate::parse_date_time(
          day,
          c("Ymd", "dmY", "BdY", "Bdy"),
          tz = tz
        )
      },
      warning = function(c) {
        cli::cli_abort(
          "{day} is not in a valid date format.
          Please enter a valid date format (e.g., '2024-01-01')."
        )
      }
    )
    
    year <- lubridate::year(day)
    month <- lubridate::month(day)
  } else if (!missing(year)) {
    # Validate year is reasonable
    if (!is.numeric(year) || year < 1987 || year > 2025) {
      cli::cli_abort(
        "Year must be a number between 1987 and 2025."
      )
    }
  } else {
    cli::cli_abort("You must provide either a day or a year for this request.")
  }
  
  # Validate month
  if (!is.numeric(month) || month < 1 || month > 12) {
    cli::cli_abort(
      "Month must be a number between 1 and 12."
    )
  }
  
  # Format date string (YYYY_MM_DD with day as 01)
  date_str <- sprintf("%04d_%02d_01", year, month)
  
  # Select which type of data to download
  if (isTRUE(qa)) {
    file_type <- "pixel_qa"
  } else {
    file_type <- "ETa"
  }
  
  # VRT filename for the CMRSET Landsat dataset
  dl_file <- sprintf("CMRSET_LANDSAT_V2_2_%s_%s.vrt", date_str, file_type)
  
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/aet/v2_2/%d/%s/%s",
    api_key,
    year,
    date_str,
    dl_file
  )
  
  return(.read_cog(full_url, max_tries, initial_delay))
}
