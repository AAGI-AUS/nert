# Offline behaviour tests for read_smips() and its internal handler.
# Mocking via helper-mocks.R; no network I/O.

KEY <- "test-key-0000"

# ---- End-to-end read_smips() -----------------------------------------------

test_that("read_smips builds the documented totalbucket URL", {
  sink <- .use_mocked_cog()
  r <- read_smips(date = "2024-01-15", api_key = KEY)
  expect_s4_class(r, "SpatRaster")
  expect_match(
    sink$urls,
    "/smips/v1_0/totalbucket/2024/smips_totalbucket_mm_20240115.tif",
    fixed = TRUE
  )
})

test_that("read_smips SMindex collection maps to the smi_perc filename", {
  sink <- .use_mocked_cog()
  read_smips(date = "2024-01-15", collection = "SMindex", api_key = KEY)
  expect_match(
    sink$urls,
    "/smips/v1_0/SMindex/2024/smips_smi_perc_20240115.tif",
    fixed = TRUE
  )
})

test_that("read_smips rejects a date before the collection's availability", {
  # totalbucket/SMindex are available from 2005; earlier dates are refused.
  expect_error(
    read_smips(date = "1990-01-01", api_key = KEY),
    "not generally available"
  )
})

test_that("read_smips rejects an unknown collection", {
  expect_error(
    read_smips(date = "2024-01-15", collection = "nope", api_key = KEY),
    "must be one of"
  )
})

# ---- Direct handler/validator unit tests -----------------------------------
# read_smips() dispatches through the `.tern_datasets` registry, which holds the
# validator and handler by reference; exercise them directly to unit-test the
# date contract and per-collection URL construction.

test_that(".validate_smips requires a date directly", {
  expect_error(.validate_smips(list(), "d1995ee8"), "requires a")
  expect_null(.validate_smips(list(date = "2024-01-15"), "d1995ee8"))
})

test_that(".read_tern_smips builds per-collection URLs directly", {
  sink <- .use_mocked_cog()
  r <- .read_tern_smips(
    "d1995ee8", list(date = "2020-06-30", collection = "bucket1"), KEY, 1L, 0L
  )
  # legacy 'day' parameter + default totalbucket collection
  .read_tern_smips("d1995ee8", list(day = "2024-02-01"), KEY, 1L, 0L)
  expect_s4_class(r, "SpatRaster")
  expect_match(
    sink$urls[[1L]],
    "/smips/v1_0/bucket1/2020/smips_bucket1_mm_20200630.tif",
    fixed = TRUE
  )
  expect_match(
    sink$urls[[2L]],
    "/smips/v1_0/totalbucket/2024/smips_totalbucket_mm_20240201.tif",
    fixed = TRUE
  )
})
