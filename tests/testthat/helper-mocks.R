# Offline mocking helpers for the network-bound read_*() functions and
# collect_tern_data().
#
# Why this layer (and not httptest2):
#   All TERN COG access in {nert} flows through `.read_cog()`, which calls
#   `terra::rast()`.  `terra::rast()` opens a GDAL /vsicurl/ handle and
#   issues HTTP range requests from C via libcurl -- which httptest2 cannot
#   intercept (httptest2 mocks the R-side {httr2} request layer).  Mocking
#   the package-internal `.read_cog()` binding through
#   `testthat::local_mocked_bindings()` is therefore the right cut: every
#   read_*() handler funnels through it, the URL string carries every
#   parameter the user supplied, and no network or libcurl path is ever
#   exercised offline.
#
# Two products are exposed:
#   * `.fixture_numeric_raster()` / `.fixture_character_raster()` -- tiny
#     in-memory SpatRasters covering an Australia-shaped bounding box.
#   * `.use_mocked_cog()` -- installs a mocked `.read_cog` binding in the
#     {nert} namespace for the lifetime of the calling test, capturing
#     URLs into a sink environment.

# ---- Fixture rasters --------------------------------------------------------

#' Tiny numeric SpatRaster covering an Australia-shaped bbox.
#'
#' Used as a stand-in for any real TERN COG in offline tests.  A 10x10 grid
#' spanning roughly lon [112, 155], lat [-45, -9] is enough to cover every
#' Australian test coordinate; real `terra::extract()` will return `value`
#' for any point falling inside that bbox.
#'
#' @param value Numeric value to fill the raster with (default `42`).
#' @return A `SpatRaster`.
#' @noRd
.fixture_numeric_raster <- function(value = 42) {
  r <- terra::rast(
    nrows = 10L, ncols = 10L,
    xmin = 112, xmax = 155,
    ymin = -45, ymax = -9,
    crs  = "EPSG:4326"
  )
  terra::values(r) <- rep(value, terra::ncell(r))
  names(r) <- "test_layer"
  r
}

#' Tiny categorical (character) SpatRaster -- mimics the ASC product.
#'
#' Single-class factor raster whose extracted values come back as character
#' soil-order labels, matching what `read_asc()` returns.
#'
#' @return A `SpatRaster` with one factor level "2 - Sodosol".
#' @noRd
.fixture_character_raster <- function() {
  r <- terra::rast(
    nrows = 10L, ncols = 10L,
    xmin = 112, xmax = 155,
    ymin = -45, ymax = -9,
    crs  = "EPSG:4326"
  )
  terra::values(r) <- rep(1L, terra::ncell(r))
  levels(r) <- data.frame(ID = 1L, Class = "2 - Sodosol")
  names(r) <- "Class"
  r
}

# ---- Mock installation ------------------------------------------------------

#' Install a mocked `.read_cog` binding in the {nert} namespace.
#'
#' Mock persists until the calling frame (typically `test_that()`) exits.
#' Every URL passed to `.read_cog()` is appended to `sink$urls`; the
#' supplied `raster` is returned so any downstream `terra::extract()` call
#' sees a real (in-memory) SpatRaster.
#'
#' @param raster    SpatRaster the mock should return.  Default: numeric
#'   fixture filled with `42`.
#' @param error_msg If non-NULL, the mock errors with this message instead
#'   of returning -- used to test schema invariance on fetch failure.
#' @param .env      Caller's environment (do not pass explicitly; defaults
#'   to `parent.frame()`).
#' @return A URL-sink environment with field `$urls` (character vector,
#'   appended in call order).
#' @noRd
.use_mocked_cog <- function(raster    = .fixture_numeric_raster(),
                            error_msg = NULL,
                            .env      = parent.frame()) {
  sink <- new.env(parent = emptyenv())
  sink$urls <- character()

  mock_fn <- if (!is.null(error_msg)) {
    force(error_msg)
    function(full_url, max_tries = NULL, initial_delay = NULL) {
      sink$urls <- c(sink$urls, full_url)
      stop(error_msg)
    }
  } else {
    force(raster)
    function(full_url, max_tries = NULL, initial_delay = NULL) {
      sink$urls <- c(sink$urls, full_url)
      raster
    }
  }

  testthat::local_mocked_bindings(
    .read_cog = mock_fn,
    .package  = "nert",
    .env      = .env
  )
  sink
}
