# Offline behaviour tests for read_slga().
# Mocking via helper-mocks.R; no network I/O.

KEY <- "test-key-0000"

# ---- All eight attributes resolve to a unique, well-formed URL -------------

test_that("each SLGA attribute resolves to a unique URL", {
  sink <- .use_mocked_cog()
  for (attr in c("AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO")) {
    read_slga(attr, api_key = KEY)
  }
  expect_length(sink$urls, 8L)
  expect_length(unique(sink$urls), 8L)
})

test_that("AWC URL contains the documented prefix/version/date", {
  sink <- .use_mocked_cog()
  read_slga("AWC", api_key = KEY)
  expect_match(sink$urls, "/AWC/v2/AWC_000_005_EV_N_P_AU_TRN_N_20210614.tif",
               fixed = TRUE)
})

test_that("PHC URL uses 'pHc' subdir (preserved case) and AU_NAT_C suffix", {
  # SLGA pHc directory is mixed-case on the TERN bucket; preserve it.
  sink <- .use_mocked_cog()
  read_slga("PHC", api_key = KEY)
  expect_match(sink$urls, "/pHc/v2/PHC_000_005_EV_N_P_AU_NAT_C_20210913.tif",
               fixed = TRUE)
})

test_that("NTO URL uses v2 / 20231101 release", {
  sink <- .use_mocked_cog()
  read_slga("NTO", api_key = KEY)
  expect_match(sink$urls, "/NTO/v2/NTO_000_005_EV_N_P_AU_NAT_C_20231101.tif",
               fixed = TRUE)
})

test_that("PHW URL uses v1 / 20220520 release", {
  sink <- .use_mocked_cog()
  read_slga("PHW", api_key = KEY)
  expect_match(sink$urls, "/PHW/v1/PHW_000_005_EV_N_P_AU_TRN_N_20220520.tif",
               fixed = TRUE)
})

# ---- Depth selector --------------------------------------------------------

test_that("depth selector flows through to the filename", {
  sink <- .use_mocked_cog()
  for (d in c("000_005", "005_015", "015_030",
              "030_060", "060_100", "100_200")) {
    read_slga("AWC", depth = d, api_key = KEY)
  }
  expect_true(all(mapply(
    function(d, url) grepl(paste0("AWC_", d, "_EV"), url, fixed = TRUE),
    c("000_005", "005_015", "015_030", "030_060", "060_100", "100_200"),
    sink$urls
  )))
})

test_that("read_slga rejects an unknown depth", {
  expect_error(read_slga("AWC", depth = "999_999", api_key = KEY),
               "must be one of")
})

# ---- Collection (EV / CI) selector ----------------------------------------

test_that("collection switches between EV and CI in the filename", {
  sink <- .use_mocked_cog()
  read_slga("AWC", collection = "EV", api_key = KEY)
  read_slga("AWC", collection = "CI", api_key = KEY)
  expect_match(sink$urls[[1L]], "_EV_N_P_", fixed = TRUE)
  expect_match(sink$urls[[2L]], "_CI_N_P_", fixed = TRUE)
})

test_that("read_slga rejects an unknown collection", {
  expect_error(read_slga("AWC", collection = "XX", api_key = KEY),
               "must be one of")
})

# ---- Attribute validation --------------------------------------------------

test_that("read_slga rejects an unsupported attribute", {
  expect_error(read_slga("ZZZ", api_key = KEY), "must be one of")
})

test_that("read_slga is case-insensitive on the attribute name", {
  sink <- .use_mocked_cog()
  read_slga("awc", api_key = KEY)
  read_slga("Awc", api_key = KEY)
  read_slga("AWC", api_key = KEY)
  expect_identical(length(unique(sink$urls)), 1L)
})

# ---- read_tern with raw SLGA dispatch id -----------------------------------

test_that("read_tern dispatches AWC alias to the SLGA handler", {
  sink <- .use_mocked_cog()
  read_tern("AWC", api_key = KEY)
  expect_length(sink$urls, 1L)
  expect_match(sink$urls, "SoilAndLandscapeGrid/AWC/v2/AWC_000_005_EV",
               fixed = TRUE)
})

test_that("read_tern dispatches the slga_cly alias through to CLY", {
  sink <- .use_mocked_cog()
  read_tern("CLY", api_key = KEY)
  expect_match(sink$urls, "SoilAndLandscapeGrid/CLY/v2/CLY_000_005_EV",
               fixed = TRUE)
})
