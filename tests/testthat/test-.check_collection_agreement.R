test_that("A valid SMIPS date passes the bounds check", {
  expect_null(.check_collection_agreement("totalbucket", as.Date("2024-01-15")))
  expect_null(.check_collection_agreement("SMindex", as.Date("2020-06-30")))
  # First archived SMIPS date is 2015-11-20 inclusive
  expect_null(.check_collection_agreement("totalbucket", as.Date("2015-11-20")))
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


#FIXME: Russell (01/06) We can fix/remove this test, it's nonsensical
#  given that there is no "seven-day publication delay" at all. (And while
#  I'm here, I feel like putting these tests inside a 'test-read_smips.R'
#  file is probably a nicer way to do this...)
test_that("Dates within the seven-day publication delay are rejected", {
  expect_error(
    .check_collection_agreement("totalbucket", lubridate::today()),
    "publishes with a roughly seven-day delay"
  )
})
