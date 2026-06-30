test_that("A valid SMIPS date passes the bounds check", {
  expect_null(.check_collection_agreement("totalbucket", as.Date("2024-01-15")))
  expect_null(.check_collection_agreement("SMindex", as.Date("2020-06-30")))
  expect_null(.check_collection_agreement("bucket1", as.Date("2015-11-20")))
})

test_that("totalbucket / SMindex reach back to 2005; bucket-level starts 2015", {
  # totalbucket and SMindex are archived back to 2005 (confirmed by live
  # resolution against data.tern.org.au)
  expect_null(.check_collection_agreement("totalbucket", as.Date("2005-01-01")))
  expect_null(.check_collection_agreement("totalbucket", as.Date("2008-06-15")))
  expect_null(.check_collection_agreement("SMindex", as.Date("2005-01-01")))
  # the bucket-level collections start in 2015, so a 2008 request is rejected
  expect_error(
    .check_collection_agreement("bucket1", as.Date("2008-06-15")),
    "not generally available before 2015-01-01"
  )
  # the error message names the offending collection
  expect_error(
    .check_collection_agreement("bucket1", as.Date("2008-06-15")),
    "bucket1"
  )
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

test_that("Dates before a collection's earliest date are rejected", {
  # bucket-level collection: rejected before 2015
  expect_error(
    .check_collection_agreement("bucket1", as.Date("2014-07-19")),
    "not generally available before 2015-01-01"
  )
  # totalbucket / SMindex: rejected before 2005 (message reports 2005)
  expect_error(
    .check_collection_agreement("SMindex", as.Date("2004-01-01")),
    "not generally available before 2005-01-01"
  )
  expect_error(
    .check_collection_agreement("totalbucket", as.Date("2004-12-31")),
    "not generally available before 2005-01-01"
  )
})

test_that("Each collection's earliest date passes", {
  expect_null(.check_collection_agreement("totalbucket", as.Date("2005-01-01")))
  expect_null(.check_collection_agreement("bucket1", as.Date("2015-01-01")))
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
