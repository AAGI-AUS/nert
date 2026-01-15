testthat::test_that("read_aet downloads a raster when TERN_API_KEY is present", {
  testthat::skip_on_cran()
  if (!nzchar(Sys.getenv("TERN_API_KEY", ""))) {
    testthat::skip("TERN_API_KEY not set; skipping download test")
  }

  # Replace with an actual filename present in TERN AET folder if needed
  fname <- "AET_CMRSET_MONTH_2023-01.tif"

  r <- nert::read_aet(file = fname, api_key = Sys.getenv("TERN_API_KEY"))
  testthat::expect_s3_class(r, "SpatRaster")
})
