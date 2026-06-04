# URL-construction snapshots.
#
# Every TERN COG read in {nert} resolves to a single GDAL /vsicurl/ URL.
# These snapshots pin the URL that each read_*() builds so any accidental
# change to a path, prefix, version, or file-naming convention is caught
# by R CMD check rather than by a user receiving HTTP 404 from terra.
#
# Mocking is via `helper-mocks.R::.use_mocked_cog()` -- the `.read_cog`
# binding in the {nert} namespace is replaced for the lifetime of each
# `test_that()` block, capturing URLs without any network I/O.

# A fixed dummy api_key keeps snapshots stable across machines (real keys
# vary by user; a literal placeholder pins the URL template).
KEY <- "test-key-0000"

# ---- SMIPS ------------------------------------------------------------------

test_that("SMIPS URLs are stable across all six collections", {
  sink <- .use_mocked_cog()
  for (col in c("totalbucket", "SMindex", "bucket1", "bucket2",
                "deepD", "runoff")) {
    read_smips("2024-01-15", collection = col, api_key = KEY)
  }
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

# ---- ASC --------------------------------------------------------------------

test_that("ASC URLs are stable for EV and CI", {
  sink <- .use_mocked_cog()
  read_asc(collection = "EV", api_key = KEY)
  read_asc(collection = "CI", api_key = KEY)
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

# ---- AET --------------------------------------------------------------------

test_that("AET URLs are stable for ETa and pixel_qa", {
  sink <- .use_mocked_cog()
  read_aet("2023-06-01", collection = "ETa",      api_key = KEY)
  read_aet("2023-06-01", collection = "pixel_qa", api_key = KEY)
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

# ---- SLGA (all eight attributes, default depth 000_005, stat EV) ------------

test_that("SLGA URLs are stable across all eight attributes", {
  sink <- .use_mocked_cog()
  for (attr in c("AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO")) {
    read_slga(attr, api_key = KEY)
  }
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

test_that("SLGA URLs are stable across all six depth intervals", {
  sink <- .use_mocked_cog()
  for (d in c("000_005", "005_015", "015_030",
              "030_060", "060_100", "100_200")) {
    read_slga("AWC", depth = d, api_key = KEY)
  }
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

test_that("SLGA EV vs CI URLs are stable", {
  sink <- .use_mocked_cog()
  read_slga("AWC", collection = "EV", api_key = KEY)
  read_slga("AWC", collection = "CI", api_key = KEY)
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

# ---- Soil Beta Diversity ---------------------------------------------------

test_that("Soil Beta Diversity URLs are stable across collections and axes", {
  sink <- .use_mocked_cog()
  for (col in c("Bacteria", "Fungi")) {
    for (axis in 1L:3L) {
      read_soil_diversity(collection = col, axis = axis, api_key = KEY)
    }
  }
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

# ---- Canopy Height ---------------------------------------------------------

test_that("Canopy Height URL is stable", {
  sink <- .use_mocked_cog()
  read_canopy_height(api_key = KEY)
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

# ---- Phenology -------------------------------------------------------------

test_that("Phenology URLs are stable across all eight metrics", {
  sink <- .use_mocked_cog()
  for (m in c("SGS", "PGS", "EGS", "LGS", "EVI1", "EVI2", "EVIP", "EVII")) {
    read_phenology(year = 2018L, season = 1L, collection = m, api_key = KEY)
  }
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

test_that("Phenology URLs are stable across seasons and years", {
  sink <- .use_mocked_cog()
  read_phenology(year = 2003L, season = 1L, api_key = KEY)
  read_phenology(year = 2018L, season = 2L, api_key = KEY)
  expect_snapshot(cat(sink$urls, sep = "\n"))
})

# ---- API-key URL-encoding (slash -> %2f) ----------------------------------

test_that("api_key with '/' is URL-encoded as %2f in every URL", {
  sink <- .use_mocked_cog()
  read_canopy_height(api_key = "abc/def/ghi")
  expect_match(sink$urls, "apikey:abc%2fdef%2fghi@", fixed = TRUE)
})
