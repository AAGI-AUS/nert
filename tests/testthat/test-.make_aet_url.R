test_that("A valid URL is created for the ETa collection", {
  month_ <- lubridate::parse_date_time("2023-01-01", "Ymd")
  url <- .make_aet_url("ETa", month_, "test_key")
  expect_match(url, "^/vsicurl/https://apikey:test_key@", perl = TRUE)
  expect_match(url, "model-derived/aet/v2_2/2023/2023_01_01/",
               fixed = TRUE)
  expect_match(url, "CMRSET_LANDSAT_V2_2_2023_01_01_ETa\\.vrt$",
               perl = TRUE)
})

test_that("A valid URL is created for the pixel_qa collection", {
  month_ <- lubridate::parse_date_time("2023-06-01", "Ymd")
  url <- .make_aet_url("pixel_qa", month_, "test_key")
  expect_match(url, "CMRSET_LANDSAT_V2_2_2023_06_01_pixel_qa\\.vrt$",
               perl = TRUE)
})

test_that("The year and date string are correctly embedded in the URL", {
  month_ <- lubridate::parse_date_time("2000-02-01", "Ymd")
  url <- .make_aet_url("ETa", month_, "key123")
  expect_match(url, "/2000/2000_02_01/", fixed = TRUE)
  expect_match(url, "CMRSET_LANDSAT_V2_2_2000_02_01_ETa", fixed = TRUE)
})

test_that("An invalid collection throws an error", {
  month_ <- lubridate::parse_date_time("2023-01-01", "Ymd")
  expect_error(.make_aet_url("invalid", month_, "test_key"))
})
