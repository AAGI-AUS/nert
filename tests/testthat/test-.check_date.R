test_that("Date validation works with valid dates", {
  reference_date <- "2020-01-01"

  # posix object
  date_ <- lubridate::as_datetime(reference_date)
  date_checked <- .check_date(date_)

  expect_true(lubridate::is.POSIXct(date_checked))
  expect_equal(date_checked, date_)

  # date object
  date_ <- as.Date(reference_date)
  date_checked <- .check_date(date_)

  expect_true(lubridate::is.POSIXct(date_checked))
  expect_equal(toString(date_checked), toString(date_))

  # different timezone
  date_ <- lubridate::as_datetime(reference_date, tz = "Australia/Adelaide")
  date_checked <- .check_date(date_)

  expect_true(lubridate::is.POSIXct(date_checked))
  expect_equal(date_checked, date_)

  # various string formats: "Ymd", "dmY", "BdY", "Bdy", "bdY", "bdy"
  # Ymd
  date_checked <- .check_date("2020-01-01")

  expect_true(lubridate::is.POSIXct(date_checked))
  expect_equal(toString(date_checked), reference_date)

  # dmY
  date_checked <- .check_date("01-01-2020")

  expect_true(lubridate::is.POSIXct(date_checked))
  expect_equal(toString(date_checked), reference_date)

  # BdY, bdY
  date_checked <- .check_date("january-01-2020")

  expect_true(lubridate::is.POSIXct(date_checked))
  expect_equal(toString(date_checked), reference_date)

  date_checked <- .check_date("Jan-01-2020")

  expect_true(lubridate::is.POSIXct(date_checked))
  expect_equal(toString(date_checked), reference_date)

  # Bdy, bdy
  date_checked <- .check_date("January-01-20")

  expect_true(lubridate::is.POSIXct(date_checked))
  expect_equal(toString(date_checked), reference_date)

  date_checked <- .check_date("jan-01-20")

  expect_true(lubridate::is.POSIXct(date_checked))
  expect_equal(toString(date_checked), reference_date)
})

test_that("Date validation throws error with invalid dates", {
  # multiple dates
  expect_error(.check_date(c("2020-01-01", "2020-01-02")), "Only one day is allowed per request.")

  # invalid formats
  expect_error(
    .check_date("2020-31-12"),
    "2020-31-12 is not in a valid date format. Please enter a valid date format."
  )
  expect_error(
    .check_date("2020-12-33"),
    "2020-12-33 is not in a valid date format. Please enter a valid date format."
  )
  expect_error(
    .check_date("jane-01-20"),
    "jane-01-20 is not in a valid date format. Please enter a valid date format."
  )
  expect_error(
    .check_date("today"),
    "today is not in a valid date format. Please enter a valid date format."
  )
})
