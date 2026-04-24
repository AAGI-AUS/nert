test_that("Date is snapped to first of month", {
  date_checked <- .check_aet_date("2023-01-15")
  expect_identical(format(date_checked, "%Y-%m-%d"), "2023-01-01")

  # Already on first of month
  date_checked <- .check_aet_date("2023-06-01")
  expect_identical(format(date_checked, "%Y-%m-%d"), "2023-06-01")
})

test_that("Dates before 2000-02-01 throw an error", {
  expect_error(
    .check_aet_date("2000-01-01"),
    "AET data are not available before 2000-02-01"
  )
  expect_error(
    .check_aet_date("1999-12-01"),
    "AET data are not available before 2000-02-01"
  )
})

test_that("Dates on or after 2000-02-01 are accepted", {
  expect_no_error(.check_aet_date("2000-02-01"))
  expect_no_error(.check_aet_date("2023-06-15"))
})

test_that(".check_aet_date returns POSIXct", {
  date_checked <- .check_aet_date("2023-01-01")
  expect_true(lubridate::is.POSIXct(date_checked))
})
