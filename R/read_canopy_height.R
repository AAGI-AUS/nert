#' Read Canopy Height Data (OzTreeMap)
#'
#' @description
#' Wrapper around [read_tern()] for Canopy Height Models from OzTreeMap
#' (TERN/36c98155).  Provides an Australia-wide composite at 30 m resolution
#' (static product).
#'
#' **Important:** The coordinate reference system is \code{EPSG:3577}
#' (GDA94/Australian Albers, projected in metres).  If you are extracting
#' values at point locations from geographic coordinates (latitude/longitude),
#' you must first reproject your points to EPSG:3577 using [terra::project()]
#' or [sf::st_transform()].
#'
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}.  See [get_key()] for setup.
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries before an error is raised.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
#'
#' @returns
#' A [terra::rast()] object (single layer, EPSG:3577).
#'
#' @seealso
#' [read_tern()], [read_soil_diversity()]
#'
#' @examplesIf interactive()
#' # Read canopy height for all of Australia
#' r <- read_canopy_height()
#' plot(r)
#'
#' # Extract at a location (Murray Bridge, SA) -- note: must reproject first
#' pt <- terra::vect(
#'   matrix(c(138.6, -34.9), ncol = 2),
#'   type = "points",
#'   crs = "EPSG:4326"  # geographic (lat/lon)
#' )
#' pt_proj <- terra::project(pt, "EPSG:3577")  # project to raster CRS
#' val <- terra::extract(r, pt_proj)
#' print(val)
#'
#' @references
#'   TERN portal:
#'   <https://portal.tern.org.au/metadata/TERN/36c98155>
#'
#'   OzTreeMap:
#'   <https://www.tern.org.au/landscapes/>
#'
#' @autoglobal
#' @export
read_canopy_height <- function(
  api_key    = NULL,
  max_tries  = 3L,
  initial_delay = 1L
) {
  read_tern(
    "CANOPY",
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}
