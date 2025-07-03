#' Read ASC COGs from TERN
#'
#' Read Australian Soil Classification (\acronym{ASC}) Cloud Optimised Geotiff
#'  (\acronym{COG}) files from \acronym{TERN} in your \R session.  The data are
#'  Australian Soil Classification Soil Order classes with quantified estimates
#'  of mapping reliability at a 90 m resolution.  You can access the reliability
#'  map using the `confusion_index` argument.
#'
#' @param confusion_index A `Boolean` value indicating whether to read the
#'   Confusion Index (`TRUE`) or the estimated \acronym{ASC} value (`FALSE`).
#'   Defaults to `FALSE` reading the \acronym{ASC} values.
#' @param api_key A `character` string containing your \acronym{API} key,
#'   a random string provided to you by \acronym{TERN}, for the request.
#'   Defaults to automatically detecting your key from your local .Renviron,
#'   .Rprofile or similar.  Alternatively, you may directly provide your key as
#'   a string here or use functionality like that from \CRANpkg{keyring}.  If
#'   nothing is provided, you will be prompted on how to set up your \R session
#'   so that it is auto-detected and a browser window will open at the
#'   \acronym{TERN} website for you to request a key.
#' @param max_tries An integer `Integer` with the number of times to retry a
#'   failed download before emitting an error message.  Defaults to 3.
#' @param initial_delay An `Integer` with the number of seconds to delay before
#'   retrying the download.  This increases as the tries increment.  Defaults to
#'   1.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#'
#' r <- read_asc()
#' r
#'
#' @returns A  [terra::rast()] object.
#' @source
#' \describe{
#'  \item{ASC Data}{<https://data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/ASC_EV_C_P_AU_TRN_N.cog.tif>}
#'  \item{Confusion Index}{<https://data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/ASC_CI_C_P_AU_TRN_N.cog.tif>}
#'  }
#' @autoglobal
#' @references <https://portal.tern.org.au/metadata/TERN/15728dba-b49c-4da5-9073-13d8abe67d7c>
#' @export
read_asc <- function(
  confusion_index = FALSE,
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
) {
  api_key <- .check_api_key(api_key)
  dl_file <- data.table::fifelse(
    isFALSE(confusion_index),
    "ASC_EV_C_P_AU_TRN_N.cog.tif",
    "ASC_CI_C_P_AU_TRN_N.cog.tif"
  )

  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/%s",
    api_key,
    dl_file
  )
  return(.read_cog(full_url, max_tries, initial_delay))
}
