# Offline tests for the retry/backoff logic in .read_cog().
# terra::rast is mocked so no network I/O occurs; initial_delay = 0 keeps the
# backoff Sys.sleep() instantaneous.

test_that(".read_cog returns the raster on the first successful attempt", {
  fake <- .fixture_numeric_raster()
  testthat::local_mocked_bindings(
    rast = function(x, ...) fake,
    .package = "terra"
  )
  r <- .read_cog("/vsicurl/https://example", max_tries = 3L, initial_delay = 0L)
  expect_s4_class(r, "SpatRaster")
})

test_that(".read_cog retries a transient failure then succeeds", {
  fake <- .fixture_numeric_raster()
  attempts <- 0L
  testthat::local_mocked_bindings(
    rast = function(x, ...) {
      attempts <<- attempts + 1L
      if (attempts < 2L) {
        stop("transient failure")
      }
      fake
    },
    .package = "terra"
  )
  r <- .read_cog("/vsicurl/https://example", max_tries = 3L, initial_delay = 0L)
  expect_s4_class(r, "SpatRaster")
  expect_identical(attempts, 2L)
})

test_that(".read_cog aborts after exhausting all retries", {
  testthat::local_mocked_bindings(
    rast = function(x, ...) stop("permanent failure"),
    .package = "terra"
  )
  expect_error(
    .read_cog("/vsicurl/https://example", max_tries = 2L, initial_delay = 0L),
    "Download failed after 2 attempts"
  )
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
