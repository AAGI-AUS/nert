test_that("A valid URL is created for the ETa collection", {
  month_ <- lubridate::parse_date_time("2023-01-01", "Ymd")
  url <- .make_aet_url("ETa", month_, "test_key")
  expect_identical(
    url,
    paste0(
      "/vsicurl/https://apikey:test_key@data.tern.org.au/landscapes/aet/",
      "v2_2/2023/2023_01_01/CMRSET_LANDSAT_V2_2_2023_01_01_ETa.vrt"
    )
  )
})

test_that("A valid URL is created for the pixel_qa collection", {
  month_ <- lubridate::parse_date_time("2023-06-01", "Ymd")
  url <- .make_aet_url("pixel_qa", month_, "test_key")
  expect_identical(
    url,
    paste0(
      "/vsicurl/https://apikey:test_key@data.tern.org.au/landscapes/aet/",
      "v2_2/2023/2023_06_01/CMRSET_LANDSAT_V2_2_2023_06_01_pixel_qa.vrt"
    )
  )
})

test_that("The year and date string are correctly embedded in the URL", {
  month_ <- lubridate::parse_date_time("2000-02-01", "Ymd")
  url <- .make_aet_url("ETa", month_, "key123")
  expect_true(grepl("2000/2000_02_01", url))
  expect_true(grepl("CMRSET_LANDSAT_V2_2_2000_02_01_ETa", url))
})

test_that("An invalid collection throws an error", {
  month_ <- lubridate::parse_date_time("2023-01-01", "Ymd")
  expect_error(.make_aet_url("invalid", month_, "test_key"))
})
