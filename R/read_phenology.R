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
#'   <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/2bb0c81a-5a09-4a0e-bd86-5cd2be8def26>
#'
#' @autoglobal
#' @export
read_phenology <- function(
  year          = NULL,
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


# -- Phenology metric registry ----------------------------------------------

#' Phenology metric registry
#'
#' Named list mapping metric abbreviations to their subdirectory names on
#' the TERN data server.
#'
#' @format A named \code{list} of \code{character} strings.
#' @autoglobal
#' @dev
.phenology_metrics <- list(
  SGS = "1_Start_of_the_growing_season",
  PGS = "2_Peak_of_the_growing_season",
  EGS = "3_End_of_the_growing_season",
  LGS = "4_Length_of_the_growing_season",
  SOS = "5_Start_of_season",
  POS = "6_Peak_of_season",
  EOS = "7_End_of_season",
  LOS = "8_Length_of_season",
  ROG = "9_Rate_of_greening",
  ROS = "10_Rate_of_senescence"
)


# -- Internal Phenology handler ---------------------------------------------

#' Internal handler for Land Surface Phenology (\code{TERN/2bb0c81a})
#'
#' @param dots Named list of \code{...} args from [read_tern()].
#' @param api_key URL-encoded API key.
#' @param max_tries,initial_delay Passed to [.read_cog()].
#' @autoglobal
#' @dev
.read_tern_phenology <- function(dots, api_key, max_tries, initial_delay) {
  year       <- as.integer(dots[["year"]])
  season     <- if (!is.null(dots[["season"]])) as.integer(dots[["season"]]) else 1L
  collection <- if (!is.null(dots[["collection"]])) dots[["collection"]] else "SGS"

  approved_metrics <- names(.phenology_metrics)
  collection <- rlang::arg_match(collection, approved_metrics)

  if (!season %in% 1L:2L) {
    cli::cli_abort("Phenology {.arg season} must be 1 or 2.")
  }

  metric_dir <- .phenology_metrics[[collection]]
  fname <- sprintf("%s_%d_Season%d.tif", collection, year, season)
  full_url <- sprintf(
    "/vsicurl/https://apikey:%s@data.tern.org.au/remote-sensing/modis/phenology_myd13a1/%s/%s",
    api_key, metric_dir, fname
  )
  .read_cog(full_url, max_tries, initial_delay)
}
