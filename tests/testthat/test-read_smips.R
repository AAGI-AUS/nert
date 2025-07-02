test_that("get_smips returns the total bucket data for 2020-01-01", {
  smips <- read_smips(day = "2020-01-01")
  expect_named(smips, "smips_totalbucket_mm_20200101")
})


test_that("get_smips returns the Soil Moisture index data for 2020-01-01", {
  smips <- read_smips(day = "2020-01-01", collection = "SMindex")
  expect_named(smips, "smips_smi_perc_20200101")
})
