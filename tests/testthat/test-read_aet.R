# Offline behaviour tests for read_aet().
# Mocking via helper-mocks.R; no network I/O.

KEY <- "test-key-0000"

test_that("read_aet builds the documented ETa URL for a valid month", {
  sink <- .use_mocked_cog()
  read_aet("2023-06-01", api_key = KEY)
  expect_length(sink$urls, 1L)
  expect_match(
    sink$urls,
    "/model-derived/aet/v2_2/2023/2023_06_01/CMRSET_LANDSAT_V2_2_2023_06_01_ETa.vrt",
    fixed = TRUE
  )
})

test_that("read_aet builds the pixel_qa URL on request", {
  sink <- .use_mocked_cog()
  read_aet("2023-06-01", collection = "pixel_qa", api_key = KEY)
  expect_match(sink$urls, "_pixel_qa.vrt$")
})

test_that("read_aet snaps mid-month dates to the first of the month", {
  sink <- .use_mocked_cog()
  read_aet("2023-06-15", api_key = KEY)
  read_aet("2023-06-30", api_key = KEY)
  expect_true(all(grepl("2023_06_01_ETa.vrt", sink$urls, fixed = TRUE)))
})

test_that("read_aet accepts Date inputs as well as strings", {
  sink <- .use_mocked_cog()
  read_aet(as.Date("2023-06-01"), api_key = KEY)
  expect_match(sink$urls, "2023_06_01_ETa.vrt$")
})

test_that("read_aet returns the raster supplied by the mocked .read_cog", {
  fixture <- .fixture_numeric_raster(value = 99)
  .use_mocked_cog(raster = fixture)
  r <- read_aet("2023-06-01", api_key = KEY)
  expect_s4_class(r, "SpatRaster")
  expect_equal(unname(terra::values(r)[1L, 1L]), 99)
})

# ---- Validation errors (surfaced before .read_cog is reached) --------------

test_that("read_aet errors when date is missing", {
  expect_error(read_aet(), "argument \"date\" is missing")
})

test_that("read_aet errors for dates before 1987-05-01", {
  expect_error(
    read_aet("1979-06-01", api_key = KEY),
    "AET data are not available before 1987"
  )
  expect_error(
    read_aet("1987-04-30", api_key = KEY),
    "AET data are not available before 1987"
  )
})

test_that("read_aet accepts the earliest available date (1987-05-01)", {
  sink <- .use_mocked_cog()
  read_aet("1987-05-01", api_key = KEY)
  expect_match(sink$urls, "1987_05_01_ETa.vrt$")
})

test_that("read_aet rejects an unknown collection at .make_aet_url", {
  expect_error(
    read_aet("2023-06-01", collection = "bogus", api_key = KEY),
    "must be one of"
  )
})

test_that("read_aet rejects vector dates via .check_date", {
  expect_error(
    read_aet(c("2023-06-01", "2023-07-01"), api_key = KEY),
    "Only one day is allowed"
  )
})

# ---- max_tries / initial_delay propagation --------------------------------

test_that("read_aet propagates max_tries and initial_delay overrides", {
  captured <- new.env(parent = emptyenv())
  testthat::local_mocked_bindings(
    .read_cog = function(full_url, max_tries = NULL, initial_delay = NULL) {
      captured$max_tries <- max_tries
      captured$initial_delay <- initial_delay
      .fixture_numeric_raster()
    },
    .package = "nert"
  )
  read_aet("2023-06-01", api_key = KEY, max_tries = 7L, initial_delay = 4L)
  expect_identical(captured$max_tries, 7L)
  expect_identical(captured$initial_delay, 4L)
})
