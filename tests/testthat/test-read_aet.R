test_that("read_aet returns AET data", {
  skip_on_cran()
  skip_on_ci()
  aet <- read_aet()
  expect_s4_class(aet, "SpatRaster")
})

test_that("read_aet returns data with correct name pattern", {
  skip_on_cran()
  skip_on_ci()
  aet <- read_aet()
  # Adjust the expected name based on actual data naming
  expect_match(names(aet), "aet")
})
