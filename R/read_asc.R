#' Read ASC Soil Classification from TERN
#'
#' Read Australian Soil Classification (\acronym{ASC}) Cloud Optimised GeoTIFF
#' (\acronym{COG}) files from \acronym{TERN} in your \R session.  The data are
#' Australian Soil Classification Soil Order classes with quantified estimates
#' of mapping reliability at a 90 m resolution.
#'
#' Two collection layers are available:
#' \describe{
#'   \item{\code{"EV"}}{Estimated soil order class (default).}
#'   \item{\code{"CI"}}{Confusion index — a measure of mapping reliability.}
#' }
#'
#' This is a static product (no date argument required).
#'
#' This is a convenience wrapper; you can also call
#' \code{read_tern("ASC")} — see [read_tern()] for the unified interface
#' and additional datasets.
#'
#' @param confusion_index A \code{logical} value indicating whether to read
#'   the Confusion Index (\code{TRUE}) or the estimated \acronym{ASC} value
#'   (\code{FALSE}).  Defaults to \code{FALSE}.
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection via [get_key()].
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#' # Read estimated ASC soil order class
#' r <- read_asc()
#' autoplot(r)
#'
#' # Read confusion index (mapping reliability)
#' r_ci <- read_asc(confusion_index = TRUE)
#' autoplot(r_ci)
#'
#' @returns A [terra::rast()] object of the national ASC mosaic.
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
