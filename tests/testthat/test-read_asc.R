test_that("get_asc returns the soil classification data", {
  skip_on_cran()
  skip_on_ci()
  asc <- read_asc()
  expect_named(asc, "Class")
})


test_that("get_smips returns the confusion index for soil class", {
  skip_on_cran()
  skip_on_ci()
  asc <- read_asc(confusion_index = TRUE)
  expect_named(asc, "ASC_CI_C_P_AU_TRN_N.cog")
})
