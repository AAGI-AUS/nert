#' Read Land Surface Phenology from TERN
#'
#' Read Australian Land Surface Phenology Cloud Optimised GeoTIFF
#' (\acronym{COG}) files from \acronym{TERN}.  This product provides
#' phenological metrics derived from MODIS MYD13A1 imagery at 500 m
#' resolution.  Data are available for years 2003--2018, with up to two
#' growing seasons per year.
#'
#' @section Phenology metrics:
#' Ten phenological metrics are available (use as the \code{collection}
#' argument):
#' \describe{
#'   \item{\code{"SGS"}}{Start of Growing Season (default).}
#'   \item{\code{"PGS"}}{Peak of Growing Season.}
#'   \item{\code{"EGS"}}{End of Growing Season.}
#'   \item{\code{"LGS"}}{Length of Growing Season.}
#'   \item{\code{"SOS"}}{Start of Season.}
#'   \item{\code{"POS"}}{Peak of Season.}
#'   \item{\code{"EOS"}}{End of Season.}
#'   \item{\code{"LOS"}}{Length of Season.}
#'   \item{\code{"ROG"}}{Rate of Greening.}
#'   \item{\code{"ROS"}}{Rate of Senescence.}
#' }
#'
#' This is a convenience wrapper around
#' \code{read_tern("PHENOLOGY", ...)}; see [read_tern()] for full
#' details and additional datasets.
#'
#' @param year An integer year (2003--2018).
#' @param season Season number: \code{1} (default) or \code{2}.
#' @param collection Phenology metric abbreviation.  One of \code{"SGS"}
#'   (default), \code{"PGS"}, \code{"EGS"}, \code{"LGS"}, \code{"SOS"},
#'   \code{"POS"}, \code{"EOS"}, \code{"LOS"}, \code{"ROG"}, or
#'   \code{"ROS"}.
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection via [get_key()].
#' @param max_tries Maximum number of download retries before an error is
#'   raised.  When \code{NULL} (default), resolved from
#'   \code{getOption("nert.max_tries", 3L)}.  Pass an integer to override
#'   for a single call.
#' @param initial_delay Initial retry delay in seconds (doubles with each
#'   attempt).  When \code{NULL} (default), resolved from
#'   \code{getOption("nert.initial_delay", 1L)}.  Pass an integer to
#'   override for a single call.
#'
#' @family COGs
#'
#' @examplesIf interactive()
#' # Read Start of Growing Season for 2018, Season 1
#' r <- read_phenology(year = 2018)
#' autoplot(r)
#'
#' # Read End of Growing Season for 2015, Season 2
#' r_egs <- read_phenology(year = 2015, season = 2, collection = "EGS")
#' autoplot(r_egs)
#'
#' # Rate of Greening
#' r_rog <- read_phenology(year = 2010, collection = "ROG")
#'
#' @returns A [terra::rast()] object of the national phenology mosaic for
#'   the requested year, season, and metric.
#'
#' @references
#'   <https://portal.tern.org.au/metadata/TERN/2bb0c81a-5a09-4a0e-bd86-5cd2be8def26>
#'
#' @autoglobal
#' @export
read_phenology <- function(
  year,
  season        = 1L,
  collection    = "SGS",
  api_key       = get_key(),
  max_tries     = NULL,
  initial_delay = NULL
) {
  read_tern(
    "PHENOLOGY",
    year          = year,
    season        = season,
    collection    = collection,
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}
