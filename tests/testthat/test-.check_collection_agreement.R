test_that("A valid collection combination passes", {
  expect_null(.check_collection_agreement("totalbucket", as.Date("2007-01-01")))
  expect_null(.check_collection_agreement("some_collection", as.Date("2007-01-01")))
  expect_null(.check_collection_agreement("some_collection", lubridate::today() - 7))
})

test_that("An invalid collection combination throws an error", {
  last_week <- lubridate::today() - 7

  error_msg <- paste0("The data are not available before 2005 and roughly much past ", last_week)
  expect_error(
    .check_collection_agreement("some_collection", lubridate::today()),
    error_msg
  )
  expect_error(
    .check_collection_agreement("totalbucket", as.Date("2004-01-01")),
    error_msg
  )
})
