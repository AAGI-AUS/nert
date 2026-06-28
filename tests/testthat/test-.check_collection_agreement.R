test_that("A valid SMIPS date passes the bounds check", {
  expect_null(.check_collection_agreement("totalbucket", as.Date("2024-01-15")))
  expect_null(.check_collection_agreement("SMindex", as.Date("2020-06-30")))
  # First archived SMIPS date is 2015-11-20 inclusive
  expect_null(.check_collection_agreement("totalbucket", as.Date("2015-11-20")))
})

# Adding some tests to check that dates work in any format.
# Russell (07/06): Note that we're hard-coding an assumption here that
#   different timezones don't matter (e.g., see Issue #47): someone asking
#   for the 2026-02-01 dataset should expect to get the 2026-02-01 dataset
#   (in 'Australia time'). I think this is a safe assumption for most use cases.
test_that("The .day argument is checked consistently across various types", {
  expect_error(
    .check_collection_agreement("totalbucket", "2000-01-01"),
    "You requested 2000-01-01"
  )
  expect_error(
    .check_collection_agreement("totalbucket", as.Date("2000-01-01")),
    "You requested 2000-01-01"
  )
  expect_error(
    .check_collection_agreement("totalbucket", as.POSIXct("2000-01-01")),
    "You requested 2000-01-01"
  )
  expect_error(
    .check_collection_agreement(
      "totalbucket",
      as.POSIXct("2000-01-01", tz = "UTC")
    ),
    "You requested 2000-01-01"
  )
  expect_error(
    .check_collection_agreement(
      "totalbucket",
      as.POSIXct("2000-01-01", tz = "Australia/Adelaide")
    ),
    "You requested 2000-01-01"
  )
  expect_error(
    .check_collection_agreement(
      "totalbucket",
      as.POSIXct("2000-01-01", tz = "EST")
    ),
    "You requested 2000-01-01"
  )
})

test_that("Dates before 2015-01-01 are rejected", {
  expect_error(
    .check_collection_agreement("totalbucket", as.Date("2014-07-19")),
    "not generally available before 2015-01-01"
  )
  expect_error(
    .check_collection_agreement("SMindex", as.Date("2004-01-01")),
    "not generally available before 2015-01-01"
  )
})

test_that("The 2015-01-01 date is passed successfully", {
  expect_null(.check_collection_agreement("totalbucket", as.Date("2015-01-01")))
})

test_that("Dates beyond today's date are rejected", {
  expect_error(
    .check_collection_agreement(
      "totalbucket",
      lubridate::today() + lubridate::days(3)
    ),
    "not yet available"
  )
  expect_error(
    .check_collection_agreement(
      "totalbucket",
      lubridate::today() + lubridate::years(2)
    ),
    "not yet available"
  )
})
