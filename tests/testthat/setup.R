has_tern_key <- function() {
  tryCatch(
    nzchar(get_key()),
    nert_no_key = function(cnd) FALSE
  )
}

# Readers set GDAL_HTTP_USERPWD and warn when it was unset; start the run
# with a key already set so that warning fires only where a test asks for it.
terra::setGDALconfig("GDAL_HTTP_USERPWD", "apikey:test-key-0000")
withr::defer(
  terra::setGDALconfig("GDAL_HTTP_USERPWD", ""),
  testthat::teardown_env()
)
