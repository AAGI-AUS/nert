KEY <- "test-key-0000"

# ---- Network integration tests (skipped without API key) -------------------

test_that("read_asc returns the soil classification data", {
  skip_on_ci()
  skip_if(!nzchar(Sys.getenv("TERN_API_KEY")), "TERN API key not available")
  asc <- read_asc()
  expect_named(asc, "Class")
})


test_that("read_asc returns the confusion index for soil class", {
  skip_on_ci()
  skip_if(!nzchar(Sys.getenv("TERN_API_KEY")), "TERN API key not available")
  asc <- read_asc(collection = "CI")
  expect_named(asc, "ASC_CI_C_P_AU_TRN_N.cog")
})

# ---- Offline URL-construction tests (mocked .read_cog) --------------------

test_that("read_asc() default builds the EV URL", {
  sink <- .use_mocked_cog(raster = .fixture_character_raster())
  read_asc(api_key = KEY)
  expect_length(sink$urls, 1L)
  expect_match(
    sink$urls,
    paste0(
      "/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/",
      "ASC_EV_C_P_AU_TRN_N.cog.tif"
    ),
    fixed = TRUE
  )
})

test_that("read_asc(collection = \"CI\") builds the CI URL", {
  sink <- .use_mocked_cog()
  read_asc(collection = "CI", api_key = KEY)
  expect_match(sink$urls, "ASC_CI_C_P_AU_TRN_N.cog.tif", fixed = TRUE)
})

test_that("read_asc returns the raster supplied by the mocked .read_cog", {
  .use_mocked_cog(raster = .fixture_character_raster())
  r <- read_asc(api_key = KEY)
  expect_s4_class(r, "SpatRaster")
  expect_named(r, "Class")
})

test_that("read_asc URL-encodes a '/' in the api_key", {
  sink <- .use_mocked_cog()
  read_asc(api_key = "abc/def")
  expect_match(sink$urls, "apikey:abc%2fdef@", fixed = TRUE)
})

test_that("read_asc dispatches via the ASC alias in read_tern", {
  sink <- .use_mocked_cog()
  read_tern("ASC", api_key = KEY)
  expect_match(sink$urls, "ASC_EV_C_P_AU_TRN_N.cog.tif", fixed = TRUE)
})

test_that("read_tern ASC respects collection = 'CI'", {
  sink <- .use_mocked_cog()
  read_tern("ASC", collection = "CI", api_key = KEY)
  expect_match(sink$urls, "ASC_CI_C_P_AU_TRN_N.cog.tif", fixed = TRUE)
})

test_that("read_tern ASC rejects unknown collection at arg_match", {
  expect_error(
    read_tern("ASC", collection = "XX", api_key = KEY),
    "must be one of"
  )
})

# ---- Direct handler unit tests ---------------------------------------------
# read_asc() dispatches through the `.tern_datasets` registry, which holds the
# handler by reference; exercise the handler directly to unit-test its argument
# handling and URL construction.

test_that(".read_tern_asc builds EV/CI URLs and defaults to EV", {
  sink <- .use_mocked_cog()
  r <- .read_tern_asc("15728dba", list(collection = "CI"), KEY, 1L, 0L)
  .read_tern_asc("15728dba", list(), KEY, 1L, 0L)
  expect_s4_class(r, "SpatRaster")
  expect_match(sink$urls[[1L]], "ASC_CI_C_P_AU_TRN_N.cog.tif", fixed = TRUE)
  expect_match(sink$urls[[2L]], "ASC_EV_C_P_AU_TRN_N.cog.tif", fixed = TRUE)
})

test_that(".read_tern_asc rejects an unknown collection directly", {
  expect_error(
    .read_tern_asc("15728dba", list(collection = "ZZ"), KEY, 1L, 0L),
    "must be one of"
  )
})
