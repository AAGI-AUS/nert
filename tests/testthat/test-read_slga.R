# Offline behaviour tests for read_slga().
# Mocking via helper-mocks.R; no network I/O.

KEY <- "test-key-0000"

# ---- All attributes resolve to a unique, well-formed URL -------------

test_that("each SLGA attribute resolves to a unique URL", {
  sink <- .use_mocked_cog()
  attrs <- c(
    "AWC",
    "CLY",
    "SND",
    "SLT",
    "BDW",
    "PHC",
    "PHW",
    "NTO",
    "AVP",
    "PTO",
    "CEC",
    "ECE",
    "DUL",
    "L15"
  )
  for (attr in attrs) {
    read_slga(attr, api_key = KEY)
  }
  expect_length(sink$urls, 14L)
  expect_length(unique(sink$urls), 14L)
})

test_that("AWC URL contains the documented prefix/version/date", {
  sink <- .use_mocked_cog()
  read_slga("AWC", api_key = KEY)
  expect_match(
    sink$urls,
    "/AWC/v2/AWC_000_005_EV_N_P_AU_TRN_N_20210614.tif",
    fixed = TRUE
  )
})

test_that("PHC URL uses 'pHc' subdir (preserved case) and AU_NAT_C suffix", {
  # SLGA pHc directory is mixed-case on the TERN bucket; preserve it.
  sink <- .use_mocked_cog()
  read_slga("PHC", api_key = KEY)
  expect_match(
    sink$urls,
    "/pHc/v2/PHC_000_005_EV_N_P_AU_NAT_C_20210913.tif",
    fixed = TRUE
  )
})

test_that("NTO URL uses v2 / 20231101 release", {
  sink <- .use_mocked_cog()
  read_slga("NTO", api_key = KEY)
  expect_match(
    sink$urls,
    "/NTO/v2/NTO_000_005_EV_N_P_AU_NAT_C_20231101.tif",
    fixed = TRUE
  )
})

test_that("PHW URL uses v1 / 20220520 release", {
  sink <- .use_mocked_cog()
  read_slga("PHW", api_key = KEY)
  expect_match(
    sink$urls,
    "/PHW/v1/PHW_000_005_EV_N_P_AU_TRN_N_20220520.tif",
    fixed = TRUE
  )
})

test_that("CLY URL uses v2 / 20210902 release", {
  sink <- .use_mocked_cog()
  read_slga("CLY", api_key = KEY)
  expect_match(
    sink$urls,
    "/CLY/v2/CLY_000_005_EV_N_P_AU_TRN_N_20210902.tif",
    fixed = TRUE
  )
})

test_that("SND URL uses v2 / 20210902 release", {
  sink <- .use_mocked_cog()
  read_slga("SND", api_key = KEY)
  expect_match(
    sink$urls,
    "/SND/v2/SND_000_005_EV_N_P_AU_TRN_N_20210902.tif",
    fixed = TRUE
  )
})

test_that("SLT URL uses v2 / 20210902 release", {
  sink <- .use_mocked_cog()
  read_slga("SLT", api_key = KEY)
  expect_match(
    sink$urls,
    "/SLT/v2/SLT_000_005_EV_N_P_AU_TRN_N_20210902.tif",
    fixed = TRUE
  )
})

test_that("BDW URL uses v2 / 20230607 release", {
  sink <- .use_mocked_cog()
  read_slga("BDW", api_key = KEY)
  expect_match(
    sink$urls,
    "/BDW/v2/BDW_000_005_EV_N_P_AU_TRN_N_20230607.tif",
    fixed = TRUE
  )
})

test_that("AVP URL uses v1 / 20220826 release", {
  sink <- .use_mocked_cog()
  read_slga("AVP", api_key = KEY)
  expect_match(
    sink$urls,
    "/AVP/v1/AVP_000_005_EV_N_P_AU_TRN_N_20220826.tif",
    fixed = TRUE
  )
})

test_that("PTO URL uses v2 / 20231101 release", {
  sink <- .use_mocked_cog()
  read_slga("PTO", api_key = KEY)
  expect_match(
    sink$urls,
    "/PTO/v2/PTO_000_005_EV_N_P_AU_NAT_C_20231101.tif",
    fixed = TRUE
  )
})

test_that("CEC URL uses v1 / 20220826 release", {
  sink <- .use_mocked_cog()
  read_slga("CEC", api_key = KEY)
  expect_match(
    sink$urls,
    "/CEC/v1/CEC_000_005_EV_N_P_AU_TRN_N_20220826.tif",
    fixed = TRUE
  )
})

test_that("ECE URL uses v1 / 20140801 release", {
  sink <- .use_mocked_cog()
  read_slga("ECE", api_key = KEY)
  expect_match(
    sink$urls,
    "/ECE/v1/ECE_000_005_EV_N_P_AU_NAT_C_20140801.tif",
    fixed = TRUE
  )
})

test_that("DUL URL uses v1 / 20210614 release", {
  sink <- .use_mocked_cog()
  read_slga("DUL", api_key = KEY)
  expect_match(
    sink$urls,
    "/DUL/v1/DUL_000_005_EV_N_P_AU_TRN_N_20210614.tif",
    fixed = TRUE
  )
})

test_that("L15 URL uses v1 / 20210614 release", {
  sink <- .use_mocked_cog()
  read_slga("L15", api_key = KEY)
  expect_match(
    sink$urls,
    "/L15/v1/L15_000_005_EV_N_P_AU_TRN_N_20210614.tif",
    fixed = TRUE
  )
})

# ---- Depth selector --------------------------------------------------------

test_that("depth selector flows through to the filename", {
  sink <- .use_mocked_cog()
  for (d in c(
    "000_005",
    "005_015",
    "015_030",
    "030_060",
    "060_100",
    "100_200"
  )) {
    read_slga("AWC", depth = d, api_key = KEY)
  }
  expect_true(all(mapply(
    function(d, url) grepl(paste0("AWC_", d, "_EV"), url, fixed = TRUE),
    c("000_005", "005_015", "015_030", "030_060", "060_100", "100_200"),
    sink$urls
  )))
})

test_that("read_slga rejects an unknown depth", {
  expect_error(
    read_slga("AWC", depth = "999_999", api_key = KEY),
    "must be one of"
  )
})

# Russell (08/06): Another inadequate test: we need these to actually
#   correspond to reality in the mocking. Prior to my change below it
#   was checking for a "CI" dataset that doesn't exist on the TERN
#   server, so the unit tests thought everything was fine even when
#   read_slga() couldn't return the confidence interval rasters.
test_that("collection switches between EV, 05, 95 in the filename", {
  sink <- .use_mocked_cog()
  read_slga("AWC", collection = "EV", api_key = KEY)
  read_slga("AWC", collection = "05", api_key = KEY)
  read_slga("AWC", collection = "95", api_key = KEY)
  expect_match(sink$urls[[1L]], "_EV_N_P_", fixed = TRUE)
  expect_match(sink$urls[[2L]], "_05_N_P_", fixed = TRUE)
  expect_match(sink$urls[[3L]], "_95_N_P_", fixed = TRUE)
})

test_that("read_slga rejects an unknown collection", {
  expect_error(
    read_slga("AWC", collection = "XX", api_key = KEY),
    "must be one of"
  )
})

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
  expect_match(
    sink$urls,
    "SoilAndLandscapeGrid/AWC/v2/AWC_000_005_EV",
    fixed = TRUE
  )
})

test_that("read_tern dispatches the slga_cly alias through to CLY", {
  sink <- .use_mocked_cog()
  read_tern("CLY", api_key = KEY)
  expect_match(
    sink$urls,
    "SoilAndLandscapeGrid/CLY/v2/CLY_000_005_EV",
    fixed = TRUE
  )
})

# ---- Direct handler unit tests ---------------------------------------------
# The SLGA handler is dispatched through the `.tern_datasets` registry (built
# from `.slga_config`), which holds it by reference; exercise it directly to
# unit-test depth/statistic handling and per-attribute URL construction.

test_that(".read_tern_slga builds URLs from the config directly", {
  sink <- .use_mocked_cog()
  # AWC, explicit depth + 95th-percentile statistic
  r <- .read_tern_slga(
    "482301c2", list(depth = "005_015", collection = "95"), KEY, 1L, 0L
  )
  # PHC uses a distinct dir/suffix/date and default depth/EV
  .read_tern_slga("258afc98", list(), KEY, 1L, 0L)
  expect_s4_class(r, "SpatRaster")
  expect_match(
    sink$urls[[1L]],
    "SoilAndLandscapeGrid/AWC/v2/AWC_005_015_95_N_P_AU_TRN_N_20210614.tif",
    fixed = TRUE
  )
  expect_match(
    sink$urls[[2L]],
    "SoilAndLandscapeGrid/pHc/v2/PHC_000_005_EV_N_P_AU_NAT_C_20210913.tif",
    fixed = TRUE
  )
})

test_that(".read_tern_slga rejects bad depth/statistic directly", {
  expect_error(
    .read_tern_slga("482301c2", list(depth = "999_999"), KEY, 1L, 0L),
    "must be one of"
  )
  expect_error(
    .read_tern_slga("482301c2", list(collection = "ZZ"), KEY, 1L, 0L),
    "must be one of"
  )
})
