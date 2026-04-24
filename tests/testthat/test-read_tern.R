# Tests for read_tern() — unified TERN COG accessor
# Integration tests (those that hit the network) are skipped unless a real
# TERN_API_KEY is set in the environment.

# ── dispatch / ID normalisation ───────────────────────────────────────────────

test_that(".tern_dispatch_id normalises full UUID key", {
  expect_identical(.tern_dispatch_id("TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0"), "d1995ee8")
})

test_that(".tern_dispatch_id normalises short prefix key", {
  expect_identical(.tern_dispatch_id("TERN/d1995ee8"), "d1995ee8")
  expect_identical(.tern_dispatch_id("TERN/15728dba"), "15728dba")
  expect_identical(.tern_dispatch_id("TERN/9fefa68b"), "9fefa68b")
})

test_that(".tern_dispatch_id strips prefix and lowercases", {
  expect_identical(.tern_dispatch_id("TERN/D1995EE8"), "d1995ee8")
  expect_identical(.tern_dispatch_id("CSIRO/abcd1234"), "abcd1234")
})

# ── error: missing dataset_id ─────────────────────────────────────────────────

test_that("read_tern errors when dataset_id is missing", {
  expect_error(read_tern(), "dataset_id")
})

# ── error: unsupported dataset ────────────────────────────────────────────────

test_that("read_tern errors informatively for unsupported dataset", {
  expect_error(
    read_tern("TERN/unknown123"),
    "not currently implemented"
  )
})

test_that("read_tern error for unsupported dataset mentions supported keys", {
  err <- tryCatch(
    read_tern("TERN/unknown123"),
    error = function(e) conditionMessage(e)
  )
  expect_match(err, "SMIPS", fixed = TRUE)
})

# ── SMIPS: parameter validation ───────────────────────────────────────────────

test_that("read_tern SMIPS errors when date is missing", {
  expect_error(
    read_tern("TERN/d1995ee8"),
    "SMIPS requires"
  )
})

test_that("read_tern SMIPS accepts full UUID and errors on missing date", {
  expect_error(
    read_tern("TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0"),
    "SMIPS requires" # correct dataset found; only date is missing
  )
})

# ── AET: parameter validation ─────────────────────────────────────────────────

test_that("read_tern AET errors when date is missing", {
  expect_error(
    read_tern("TERN/9fefa68b"),
    "AET requires"
  )
})

test_that("read_tern AET accepts legacy 'month' arg name", {
  # Should reach .check_aet_date, not the missing-date guard
  expect_error(
    read_tern("TERN/9fefa68b", month = "1999-01-01"),
    "AET data are not available before 2000"
  )
})

test_that("read_tern AET errors for date before 2000-02-01", {
  expect_error(
    read_tern("TERN/9fefa68b", date = "2000-01-01"),
    "AET data are not available before 2000"
  )
})

# ── SMIPS: URL construction (via .make_smips_url internals) ──────────────────

test_that("read_tern SMIPS builds correct URL filename via internal helper", {
  day <- .check_date("2024-01-15")
  expect_identical(.make_smips_url("totalbucket", day), "smips_totalbucket_mm_20240115.tif")
  expect_identical(.make_smips_url("SMindex", day), "smips_smi_perc_20240115.tif")
})

# ── AET: URL construction ─────────────────────────────────────────────────────

test_that("read_tern AET builds correct URL via .make_aet_url", {
  month <- .check_aet_date("2023-06-01")
  url <- .make_aet_url("ETa", month, "testkey")
  expect_match(url, "2023/2023_06_01/CMRSET_LANDSAT_V2_2_2023_06_01_ETa.vrt")
})

test_that(".make_aet_url errors for invalid collection", {
  month <- .check_aet_date("2023-06-01")
  expect_error(
    .make_aet_url("bad_collection", month, "testkey"),
    "bad_collection"
  )
})

# ── Integration tests (network; skipped without API key) ─────────────────────

test_that("read_tern SMIPS returns SpatRaster for valid date", {
  skip_if(
    !nzchar(Sys.getenv("TERN_API_KEY")),
    "TERN_API_KEY not set — skipping network test"
  )
  r <- read_tern("TERN/d1995ee8", date = "2024-01-15")
  expect_s4_class(r, "SpatRaster")
})

test_that("read_tern SMIPS SMindex collection returns SpatRaster", {
  skip_if(
    !nzchar(Sys.getenv("TERN_API_KEY")),
    "TERN_API_KEY not set — skipping network test"
  )
  r <- read_tern("TERN/d1995ee8", date = "2024-01-15", collection = "SMindex")
  expect_s4_class(r, "SpatRaster")
})

test_that("read_tern ASC returns SpatRaster (EV)", {
  skip_if(
    !nzchar(Sys.getenv("TERN_API_KEY")),
    "TERN_API_KEY not set — skipping network test"
  )
  r <- read_tern("TERN/15728dba")
  expect_s4_class(r, "SpatRaster")
})

test_that("read_tern ASC returns SpatRaster for confusion index", {
  skip_if(
    !nzchar(Sys.getenv("TERN_API_KEY")),
    "TERN_API_KEY not set — skipping network test"
  )
  r <- read_tern("TERN/15728dba", collection = "CI")
  expect_s4_class(r, "SpatRaster")
})

test_that("read_tern AET returns SpatRaster for valid month", {
  skip_if(
    !nzchar(Sys.getenv("TERN_API_KEY")),
    "TERN_API_KEY not set — skipping network test"
  )
  r <- read_tern("TERN/9fefa68b", date = "2023-06-01")
  expect_s4_class(r, "SpatRaster")
})

test_that("read_tern AET mid-month date is snapped to first of month", {
  skip_if(
    !nzchar(Sys.getenv("TERN_API_KEY")),
    "TERN_API_KEY not set — skipping network test"
  )
  r1 <- read_tern("TERN/9fefa68b", date = "2023-06-01")
  r2 <- read_tern("TERN/9fefa68b", date = "2023-06-15")
  # Compare the first 1000 rows (or adjust as needed)
  v1 <- terra::values(r1, row = 1, nrows = 1000)
  v2 <- terra::values(r2, row = 1, nrows = 1000)
  expect_identical(v1, v2)
})
