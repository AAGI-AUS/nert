test_that("read_aet returns a SpatRaster for a valid month", {
  skip_on_cran()
  skip_on_ci()
  skip_if(!nzchar(Sys.getenv("TERN_API_KEY")), "TERN API key not available")
  r <- read_aet(month = "2023-01-01")
  expect_s4_class(r, "SpatRaster")
})

test_that("read_aet errors with an appropriate message if no month provided", {
  expect_error(
    read_aet(api_key = "test_key"),
    "You must provide a month for this request."
  )
})

test_that("read_aet snaps mid-month dates to the first of the month", {
  skip_on_cran()
  skip_on_ci()
  skip_if(!nzchar(Sys.getenv("TERN_API_KEY")), "TERN API key not available")
  r1 <- read_aet(month = "2023-01-01")
  r2 <- read_aet(month = "2023-01-15")
  expect_equal(terra::nlyr(r1), terra::nlyr(r2))
  expect_equal(as.vector(terra::ext(r1)), as.vector(terra::ext(r2)))
})

test_that("read_aet errors for dates before 2000-02-01", {
  expect_error(
    read_aet(month = "1999-12-01", api_key = "test_key"),
    "AET data are not available before 2000-02-01"
  )
})
