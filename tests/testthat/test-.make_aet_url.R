test_that("A valid URL is created for the ETa collection", {
  month_ <- lubridate::parse_date_time("2023-01-01", "Ymd")
  url <- .make_aet_url("ETa", month_, "test_key")
  # Pin only the load-bearing path segments. Auth segment, host, version
  # directory, and filename suffix are deliberately not pinned: changing
  # any of those should be a maintenance update, not a test break.
  expect_match(url, "/landscapes/aet/", fixed = TRUE)
  expect_match(url, "ETa", fixed = TRUE)
})

test_that("A valid URL is created for the pixel_qa collection", {
  month_ <- lubridate::parse_date_time("2023-06-01", "Ymd")
  url <- .make_aet_url("pixel_qa", month_, "test_key")
  expect_match(url, "/landscapes/aet/", fixed = TRUE)
  expect_match(url, "pixel_qa", fixed = TRUE)
})

test_that("The year and date string are correctly embedded in the URL", {
  month_ <- lubridate::parse_date_time("2000-02-01", "Ymd")
  url <- .make_aet_url("ETa", month_, "key123")
  expect_match(url, "2000/2000_02_01", fixed = TRUE)
  expect_match(url, "2000_02_01_ETa", fixed = TRUE)
})

test_that("An invalid collection throws an error", {
  month_ <- lubridate::parse_date_time("2023-01-01", "Ymd")
  expect_error(.make_aet_url("invalid", month_, "test_key"))
})
