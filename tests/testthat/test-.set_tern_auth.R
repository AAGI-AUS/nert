test_that(".set_tern_auth warns on the first key in a session", {
  .local_gdal_config("GDAL_HTTP_USERPWD", "")
  expect_warning(.set_tern_auth("key-a"), "rest of this R session")
  expect_identical(
    unname(terra::getGDALconfig("GDAL_HTTP_USERPWD")),
    "apikey:key-a"
  )
  expect_no_warning(.set_tern_auth("key-a"))
})

test_that(".set_tern_auth stops caching TERN files when the key changes", {
  .local_gdal_config("GDAL_HTTP_USERPWD", "apikey:key-a")
  .local_gdal_config("CPL_VSIL_CURL_NON_CACHED", "")
  .set_tern_auth("key-a")
  expect_identical(unname(terra::getGDALconfig("CPL_VSIL_CURL_NON_CACHED")), "")
  expect_no_warning(.set_tern_auth("key-b"))
  expect_identical(
    unname(terra::getGDALconfig("CPL_VSIL_CURL_NON_CACHED")),
    "/vsicurl/https://data.tern.org.au/"
  )
})
