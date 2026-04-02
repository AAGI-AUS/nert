#' Read SLGA Soil and Landscape Grid of Australia Attributes
#'
#' @description
#' Wrapper around [read_tern()] for Soil and Landscape Grid of Australia
#' (\acronym{SLGA}) soil attribute products at 90 m resolution.  Access any of
#' 8 soil properties (Available Water Capacity, Clay, Sand, Silt, Bulk Density,
#' pH CaCl\ifelse{html}{\out{<sub>2</sub>}}{2}, pH water, Total Nitrogen) at 6 standard depth intervals
#' (0–5, 5–15, 15–30, 30–60, 60–100, 100–200 cm), with optional confidence
#' intervals.
#'
#' @param collection Soil attribute code.  One of: \code{"AWC"} (Available
#'   Volumetric Water Capacity), \code{"CLY"} (Clay), \code{"SND"} (Sand),
#'   \code{"SLT"} (Silt), \code{"BDW"} (Bulk Density), \code{"PHC"} (pH CaCl\ifelse{html}{\out{<sub>2</sub>}}{2}),
#'   \code{"PHW"} (pH water), or \code{"NTO"} (Total Nitrogen).  Required.
#' @param depth Depth interval (default \code{"000_005"} = 0–5 cm).  Options:
#'   \code{"000_005"}, \code{"005_015"}, \code{"015_030"}, \code{"030_060"},
#'   \code{"060_100"}, \code{"100_200"}.  Use \code{"all"} to return all
#'   6 depths stacked as a multi-layer SpatRaster.
#' @param stat Statistic.  One of \code{"EV"} (estimate, default) or
#'   \code{"CI"} (confidence interval).
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}.  See [get_key()] for setup.
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries before an error is raised.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
#'
#' @returns
#' A [terra::rast()] object.  Single depth: one layer.
#' When \code{depth = "all"}: a 6-layer raster with names
#' (\code{"{collection}_000_005"}, etc.).
#'
#' @seealso
#' [read_tern()], [read_smips()], [read_asc()]
#'
#' @examplesIf interactive()
#' # Available Water Capacity at 0–5 cm (default depth)
#' r_awc <- read_slga("AWC")
#' autoplot(r_awc)
#'
#' # Clay at specific depth (15–30 cm)
#' r_clay_30 <- read_slga("CLY", depth = "015_030")
#'
#' # Clay at deep layer (100–200 cm)
#' r_clay_deep <- read_slga("CLY", depth = "100_200")
#'
#' # Available Water Capacity, all 6 depths stacked
#' r_awc_all <- read_slga("AWC", depth = "all")
#' names(r_awc_all)
#' # [1] "AWC_000_005" "AWC_005_015" "AWC_015_030" "AWC_030_060" "AWC_060_100" "AWC_100_200"
#'
#' # Sand content with confidence intervals
#' r_sand_ci <- read_slga("SND", depth = "005_015", stat = "CI")
#'
#' # pH (water) estimate
#' r_phw <- read_slga("PHW", stat = "EV")
#'
#' # Bulk Density at all depths
#' r_bdw_all <- read_slga("BDW", depth = "all", stat = "EV")
#'
#' @references
#'   SLGA portal:
#'   <https://www.tern.org.au/landscapes/slga/>
#'
#'   Viscarra Rossel, R. A., et al. (2015). Soil and Landscape Grid of
#'   Australia. _Soil Research_, 53(8), 835–844.
#'
#' @autoglobal
#' @export
read_slga <- function(
  collection,
  depth      = "000_005",
  stat       = "EV",
  api_key    = NULL,
  max_tries  = 3L,
  initial_delay = 1L
) {
  read_tern(
    collection,
    depth         = depth,
    stat          = stat,
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}
