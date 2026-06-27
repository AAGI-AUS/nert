# Offline behaviour tests for read_canopy_height().
# Mocking via helper-mocks.R; no network I/O.

KEY <- "test-key-0000"

test_that("read_canopy_height resolves to the documented static URL", {
  sink <- .use_mocked_cog()
  read_canopy_height(api_key = KEY)
  expect_length(sink$urls, 1L)
  expect_match(
    sink$urls,
    paste0(
      "/vsicurl/https://apikey:",
      KEY,
      "@data.tern.org.au/model-derived/OzTreeMap/",
      "CanopyHeightComposite/best_pick_files_bhLNnun.tif"
    ),
    fixed = TRUE
  )
})

test_that("read_canopy_height returns a SpatRaster from the mock", {
  .use_mocked_cog(raster = .fixture_numeric_raster(value = 7))
  r <- read_canopy_height(api_key = KEY)
  expect_s4_class(r, "SpatRaster")
  expect_equal(unname(terra::values(r)[1L, 1L]), 7)
})

test_that("api_key with '/' is URL-encoded as %2f", {
  sink <- .use_mocked_cog()
  read_canopy_height(api_key = "abc/def")
  expect_match(sink$urls, "apikey:abc%2fdef@", fixed = TRUE)
})

test_that("read_canopy_height propagates max_tries / initial_delay", {
  captured <- new.env(parent = emptyenv())
  testthat::local_mocked_bindings(
    .read_cog = function(full_url, max_tries = NULL, initial_delay = NULL) {
      captured$max_tries <- max_tries
      captured$initial_delay <- initial_delay
      .fixture_numeric_raster()
    },
    .package = "nert"
  )
  read_canopy_height(api_key = KEY, max_tries = 9L, initial_delay = 3L)
  expect_identical(captured$max_tries, 9L)
  expect_identical(captured$initial_delay, 3L)
})

test_that("read_canopy_height dispatches via the CANOPY alias", {
  sink <- .use_mocked_cog()
  read_tern("CANOPY", api_key = KEY)
  expect_match(sink$urls, "best_pick_files_bhLNnun.tif", fixed = TRUE)
})
