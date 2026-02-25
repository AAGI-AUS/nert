#' Read AET COGs from TERN
#'
#' Read Actual Evapotranspiration (\acronym{AET}) Cloud Optimised Geotiff
#'  (\acronym{COG}) files from \acronym{TERN} in your \R session. The data are
#'  modelled estimates of actual evapotranspiration from the TERN model-derived
#'  dataset.
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
#' @param initial_delay An `Integer` with the number of seconds to delay before
#'   retrying the download.  This increases as the tries increment.  Defaults to
#'   1.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#'
#' r <- read_aet()
#' r
#'
#' @returns A [terra::rast()] object.
#' @source
#' \describe{
#'  \item{AET Data}{<https://data.tern.org.au/model-derived/aet/v2_2/>}
#'  }
#' @autoglobal
#' @references <https://portal.tern.org.au/search?query=evapotranspiration>
#' @export
read_aet <- function(
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
) {
  api_key <- .check_api_key(api_key)
  
  # Construct the URL to the AET COG file
  # You'll need to determine the actual filename from the TERN data portal
  # This is a placeholder - adjust based on actual file naming
  dl_file <- "aet_v2_2_AU.cog.tif"
  
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/aet/v2_2/%s",
    api_key,
    dl_file
  )
  
  return(.read_cog(full_url, max_tries, initial_delay))
}
