#' Create an sf Object from Point Locations
#'
#' Accepts three coordinate input formats and returns an [sf::sf] POINT object
#' (\acronym{EPSG}:4326) with a `location` column for use in `extract_*()`
#' functions.
#'
#' @param xy Point locations in one of three formats:
#'   * A named list, _e.g.,_
#'     `list("Corrigin" = c(x = 117.87, y = -32.33))`
#'   * A `data.frame` with columns `location`, `x` (longitude), and `y`
#'     (latitude)
#'   * An [sf::sf] POINT object (with an optional `location` column; row
#'     names are used if the column is absent)
#'
#' @returns An [sf::sf] POINT object in \acronym{EPSG}:4326 with a `location`
#'   column.
#' @autoglobal
#' @dev
#' @keywords internal
.create_sf <- function(xy) {
  if (inherits(xy, "sf")) {
    if (!"location" %in% names(xy)) {
      xy$location <- rownames(xy)
    }
    return(xy)
  }

  if (is.list(xy) && !is.data.frame(xy)) {
    if (is.null(names(xy))) {
      cli::cli_abort(
        "When {.arg xy} is a list, it must be a named list with location names
         as names, _e.g.,_
         {.code list(\"Site1\" = c(x = 116.0, y = -32.0))}."
      )
    }
    location <- names(xy)
    x <- vapply(xy, function(v) v[["x"]], numeric(1L))
    y <- vapply(xy, function(v) v[["y"]], numeric(1L))
    df <- data.frame(location = location, x = x, y = y)
    return(sf::st_as_sf(df, coords = c("x", "y"), crs = 4326L))
  }

  if (is.data.frame(xy)) {
    required_cols <- c("location", "x", "y")
    missing_cols <- setdiff(required_cols, names(xy))
    if (length(missing_cols) > 0L) {
      cli::cli_abort(
        "When {.arg xy} is a {.cls data.frame}, it must have columns
         {.field location}, {.field x} (longitude), and {.field y} (latitude).
         Missing: {.field {missing_cols}}."
      )
    }
    return(sf::st_as_sf(xy, coords = c("x", "y"), crs = 4326L))
  }

  cli::cli_abort(
    "{.arg xy} must be a named list, a {.cls data.frame} with columns
     {.field location}, {.field x}, and {.field y}, or an {.cls sf} POINT
     object.  Got {.cls {class(xy)}}."
  )
}
