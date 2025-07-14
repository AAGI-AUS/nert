test_that("get_smips returns the total bucket data for 2020-01-01", {
  skip_on_cran()
  skip_on_ci()
  smips <- read_smips(day = "2020-01-01")
  expect_named(smips, "smips_totalbucket_mm_20200101")
})


test_that("get_smips returns the Soil Moisture index data for 2020-01-01", {
  skip_on_cran()
  skip_on_ci()
  smips <- read_smips(day = "2020-01-01", collection = "SMindex")
  expect_named(smips, "smips_smi_perc_20200101")
})


test_that("get_smips errors with an appropriate message if no day provided", {
  skip_on_cran()
  skip_on_ci()
  expect_error(
    read_smips(collection = "SMindex"),
    "You must provide a single day's date for this request."
  )
})
