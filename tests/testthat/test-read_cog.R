# Offline tests for .read_cog(). terra::rast is mocked so no network I/O occurs.

test_that(".read_cog returns the raster on the first successful attempt", {
  fake <- .fixture_numeric_raster()
  testthat::local_mocked_bindings(
    rast = function(x, ...) fake,
    .package = "terra"
  )
  r <- .read_cog("/vsicurl/https://example", max_tries = 3L, initial_delay = 0L)
  expect_s4_class(r, "SpatRaster")
})

test_that(".read_cog sets GDAL's HTTP retries from max_tries and initial_delay", {
  fake <- .fixture_numeric_raster()
  testthat::local_mocked_bindings(
    rast = function(x, ...) fake,
    .package = "terra"
  )
  withr::defer(terra::setGDALconfig("GDAL_HTTP_MAX_RETRY", ""))
  withr::defer(terra::setGDALconfig("GDAL_HTTP_RETRY_DELAY", ""))
  .read_cog("/vsicurl/https://example", max_tries = 4L, initial_delay = 2L)
  expect_identical(
    unname(terra::getGDALconfig(c(
      "GDAL_HTTP_MAX_RETRY",
      "GDAL_HTTP_RETRY_DELAY"
    ))),
    c("3", "2")
  )
})

test_that(".read_cog opens the file once and reports a failure", {
  attempts <- 0L
  testthat::local_mocked_bindings(
    rast = function(x, ...) {
      attempts <<- attempts + 1L
      stop("file does not exist")
    },
    .package = "terra"
  )
  expect_error(
    .read_cog("/vsicurl/https://example", max_tries = 3L, initial_delay = 0L),
    "retried up to 2 times"
  )
  expect_identical(attempts, 1L)
})

test_that(".read_cog validates max_tries and initial_delay", {
  expect_error(
    .read_cog("u", max_tries = 0L, initial_delay = 1L),
    "positive integer"
  )
  expect_error(
    .read_cog("u", max_tries = NA_integer_, initial_delay = 1L),
    "positive integer"
  )
  expect_error(
    .read_cog("u", max_tries = 3L, initial_delay = -1L),
    "non-negative integer"
  )
})

test_that(".read_cog resolves NULL arguments from options", {
  fake <- .fixture_numeric_raster()
  testthat::local_mocked_bindings(
    rast = function(x, ...) fake,
    .package = "terra"
  )
  withr::local_options(nert.max_tries = 2L, nert.initial_delay = 0L)
  r <- .read_cog("/vsicurl/https://example")
  expect_s4_class(r, "SpatRaster")
})
