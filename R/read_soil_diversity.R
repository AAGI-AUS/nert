#' Read Soil Beta Diversity (Bacteria and Fungi)
#'
#' @description
#' Wrapper around [read_tern()] for Soil Beta Diversity (TERN/4a428d52).
#' Provides NMDS ordination axes (1-3) derived from soil surveys for
#' Bacteria and Fungi at 90 m resolution (static product).
#'
#' @param kingdom Organism kingdom.  One of \code{"Bacteria"} (default) or
#'   \code{"Fungi"}.  Use \code{"all"} to return all 6 axes stacked
#'   (Bacteria 1-3, then Fungi 1-3).
#' @param axis Ordination axis (default 1).  Options: 1, 2, or 3.
#'   Use \code{"all"} to return all 3 axes for the specified kingdom stacked.
#' @param api_key A \code{character} string containing your \acronym{TERN}
#'   \acronym{API} key.  Defaults to automatic detection from your
#'   \code{.Renviron} or \code{.Rprofile}.  See [get_key()] for setup.
#' @param max_tries An \code{integer} giving the maximum number of download
#'   retries before an error is raised.  Defaults to \code{3}.
#' @param initial_delay An \code{integer} giving the initial retry delay in
#'   seconds (doubles with each attempt).  Defaults to \code{1}.
#'
#' @returns
#' A [terra::rast()] object.  Single axis: one layer.
#' When \code{kingdom = "all"}: 6-layer raster with layers named
#' \code{NMDS_Bacteria_1}, \code{NMDS_Bacteria_2}, \code{NMDS_Bacteria_3},
#' \code{NMDS_Fungi_1}, \code{NMDS_Fungi_2}, \code{NMDS_Fungi_3}.
#'
#' @seealso
#' [read_tern()], [read_slga()]
#'
#' @examplesIf interactive()
#' # Bacteria NMDS axis 1 (default)
#' r_bacteria_1 <- read_soil_diversity()
#' autoplot(r_bacteria_1)
#'
#' # Bacteria axis 3
#' r_bacteria_3 <- read_soil_diversity("Bacteria", axis = 3)
#'
#' # Fungi axis 2
#' r_fungi_2 <- read_soil_diversity("Fungi", axis = 2)
#'
#' # Bacteria all 3 axes stacked
#' r_bacteria_all <- read_soil_diversity("Bacteria", axis = "all")
#' names(r_bacteria_all)  # NMDS_Bacteria_1, NMDS_Bacteria_2, NMDS_Bacteria_3
#'
#' # Fungi all axes
#' r_fungi_all <- read_soil_diversity("Fungi", axis = "all")
#'
#' # All kingdoms (Bacteria 1-3 + Fungi 1-3) - 6 layers
#' r_all <- read_soil_diversity(kingdom = "all")
#' names(r_all)
#'
#' @references
#'   TERN portal:
#'   <https://portal.tern.org.au/metadata/TERN/4a428d52>
#'
#' @autoglobal
#' @export
read_soil_diversity <- function(
  kingdom = "Bacteria",
  axis    = 1,
  api_key = NULL,
  max_tries  = 3L,
  initial_delay = 1L
) {
  read_tern(
    "SOILDIV",
    kingdom       = kingdom,
    axis          = axis,
    api_key       = api_key,
    max_tries     = max_tries,
    initial_delay = initial_delay
  )
}
