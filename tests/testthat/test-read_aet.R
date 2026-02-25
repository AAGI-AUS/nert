test_that("read_aet returns a raster object for AET data", {
  skip_on_cran()
  skip_on_ci()
  aet <- read_aet(year = 2024, month = 1)
  expect_s4_class(aet, "SpatRaster")
})

test_that("read_aet returns a raster object for QA data", {
  skip_on_cran()
  skip_on_ci()
  aet_qa <- read_aet(year = 2024, month = 1, qa = TRUE)
  expect_s4_class(aet_qa, "SpatRaster")
})

test_that("read_aet returns non-NA data", {
  skip_on_cran()
  skip_on_ci()
  aet <- read_aet(year = 2024, month = 1)
  expect_true(!all(is.na(terra::values(aet))))
})

test_that("read_aet errors with missing year", {
  skip_on_cran()
  skip_on_ci()
  expect_error(
    read_aet(month = 1),
    "You must provide a year for this request."
  )
})

test_that("read_aet errors with invalid year", {
  skip_on_cran()
  skip_on_ci()
  expect_error(
    read_aet(year = 1970, month = 1),
    "Year must be a number between 1987 and 2025."
  )
})

test_that("read_aet errors with invalid month", {
  skip_on_cran()
  skip_on_ci()
  expect_error(
    read_aet(year = 2024, month = 13),
    "Month must be a number between 1 and 12."
  )
})

test_that("read_aet works with custom API key", {
  skip_on_cran()
  skip_on_ci()
  api_key <- Sys.getenv("TERN_API_KEY")
  if (nzchar(api_key)) {
    aet <- read_aet(year = 2024, month = 1, api_key = api_key)
    expect_s4_class(aet, "SpatRaster")
  } else {
    skip("TERN_API_KEY not set in environment")
  }
})

?read_aet
help(read_aet)


