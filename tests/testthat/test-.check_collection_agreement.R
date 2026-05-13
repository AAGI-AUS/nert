test_that("A valid SMIPS date passes the bounds check", {
  expect_null(.check_collection_agreement("totalbucket", as.Date("2024-01-15")))
  expect_null(.check_collection_agreement("SMindex", as.Date("2020-06-30")))
  # First archived SMIPS date is 2015-11-20 inclusive
  expect_null(.check_collection_agreement("totalbucket", as.Date("2015-11-20")))
})

test_that("Dates before 2015-11-20 are rejected", {
  expect_error(
    .check_collection_agreement("totalbucket", as.Date("2015-11-19")),
    "not available before 2015-11-20"
  )
  expect_error(
    .check_collection_agreement("SMindex", as.Date("2004-01-01")),
    "not available before 2015-11-20"
  )
})

test_that("Dates within the seven-day publication delay are rejected", {
  expect_error(
    .check_collection_agreement("totalbucket", lubridate::today()),
    "publishes with a roughly seven-day delay"
  )
})
