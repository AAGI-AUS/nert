#' Extract Values for a Region or Point of Interest From a COG
#'
#' @param x A [terra::rast()] object, typically a \acronym{TERN} provided
#'  \acronym{COG}, but any `rast` object will work.
#' @param lonlat Geographic coordinates, either a single point or a bounding box
#'   for a cell or region entered as x, y (longitude, latitude) coordinates.
#'   See argument details for more.  Defaults to `NULL` returning all values
#'   available in the \acronym{COG} for Australia.
#' @section Argument details for `lonlat`:
#' \describe{
#'  \item{For a single point}{To get a specific cell supply a length-two numeric
#'   vector giving the decimal degree longitude and latitude in that order for
#'   data to download, _e.g._, `lonlat = c(115.5, -50.5)`.}
#'
#'  \item{Bounding box}{To get a region, supply a length-four numeric
#'  vector as lower left (lon, lat) and upper right (lon, lat) coordinates,
#'  _e.g._, `lonlat = c(xmin, xmax, ymin, ymax)` in that order for a
#'  given region, _e.g._, a bounding box for the south western corner of
#'  Australia: `lonlat = c(113, 118, -35, -30)`.}
#'  }
#'

extract_cog <- function(cog, lonlat) {

  lonlat <- .check_lonlat(lonlat = lonlat)

  if (length(lonlat) == 2) {
    r <- terra::extract(lonlat)
  }
  if (length(lonlat) == 4) {
    lonlat <- terra::vect(lonlat)
    r <- terra::crop(r, lonlat)
  }
}


#' Check User-supplied `lonlat` for Validity
#'
#' Validates user entered `lonlat` values as falling within Australia
#'
#' @param lonlat User entered `lonlat` value.
#'
#' @return A list called `lonlat`
#' @keywords internal
#' @autoglobal
#' @noRd


.check_lonlat <- function(lonlat) {

  # these values are derived from the SLGAcloud package,
  # https://github.com/AusSoilsDSM/SLGACloud/blob/17197979d042da6b26bdbb6d41b6ab28f3e3f9a1/R/rasterMethods.R#L68C21-L68C85


  au_lon <- c(112.904998779, 153.994995117)
  au_lat <- c(-43.73500061, -9.005000114)

  if (is.numeric(lonlat) & length(lonlat) == 2) {
    if (lonlat[1] < au_lon[[1]] | lonlat[1] > au_lon[[2]]) {
      cli::cli_abort(
        call = rlang::caller_env(),
        c(i = "Please check your longitude, {.var {lonlat[1]}},
                         to be sure it is valid.")
      )
    }
    if (lonlat[2] < au_lat[[1]] | lonlat[2] > au_lat[[2]]) {
      cli::cli_abort(
        call = rlang::caller_env(),
        c(i = "Please check your latitude, {.val {lonlat[2]}},
          value to be sure it is valid.")
      )
    }
    longitude <- lonlat[1]
    latitude <- lonlat[2]
  } else if (length(lonlat) == 4 & is.numeric(lonlat)) {
    if (any(lonlat[1] < au_lon[[1]] |
            lonlat[3] < au_lon[[1]] |
            lonlat[1] > au_lon[[2]] |
            lonlat[3] > au_lon[[2]])) {
      cli::cli_abort(
        call = rlang::caller_env(),
        c(i = "Please check your longitude values, {.var {lonlat[1]}} and
            {.var {lonlat[3]}}, to be sure they are valid.")
      )
    } else if (any(lonlat[2] < au_lat[[1]] |
                   lonlat[4] < au_lat[[1]] |
                   lonlat[2] > au_lat[[2]] |
                   lonlat[4] > au_lat[[2]])) {
      cli::cli_abort(
        call = rlang::caller_env(),
        c(i = "Please check your latitude values, {.var {lonlat[2]}} and
          {.var {lonlat[4]}}, to be sure they are valid.")
      )
    } else if (lonlat[2] > lonlat[4]) {
      cli::cli_abort(
        call = rlang::caller_env(),
        c(
          i = "The first `lonlat` {.arg lat} value must be the minimum value.")
      )
    } else if (lonlat[1] > lonlat[3]) {
      cli::cli_abort(
        call = rlang::caller_env(),
        c(
          i = "The first `lonlat` {.arg lon} value must be the minimum value.")
      )
    }
    bbox <- c(
      "xmin" = lonlat[1],
      "ymin" = lonlat[2],
      "xmax" = lonlat[3],
      "ymax" = lonlat[4]
    )
  } else {
    cli::cli_abort(
      call = rlang::caller_env(),
      c(i = "You have entered an invalid request for `lonlat`
          {.arg {lonlat}}."))
  }

  if (!is.null(bbox)) {
    lonlat_identifier <- list(bbox, identifier)
    names(lonlat_identifier) <- c("bbox", "identifier")
  } else if (identifier == "global") {
    lonlat_identifier <- list("global")
    names(lonlat_identifier) <- "identifier"
  } else {
    lonlat_identifier <- list(longitude, latitude, identifier)
    names(lonlat_identifier) <-
      c("longitude", "latitude", "identifier")
  }
  return(lonlat_identifier)
}


#' Check that the user hasn't blindly copied the "your_api_key" string from the
#' examples
#'
#' @keywords Internal
#' @autoglobal
#' @noRd

.check_not_example_api_key <- function(.api_key) {
  if (!is.null(.api_key) && .api_key == "your_api_key") {
    stop("You have copied the example code and not provided a proper API key.
         An API key may be requested from DPIRD or for SILO you must use your
         e-mail address as an API key. See the help for the respective functions
         for more.",
         call. = FALSE)
  }
  return(invisible(NULL))
}
