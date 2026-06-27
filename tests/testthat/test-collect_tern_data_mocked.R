# Offline tests for the fetch path of collect_tern_data().
#
# Together with `test-collect_tern_data.R` (planner / parser tests) this
# exercises the full path from user call to populated output, with all
# COG reads routed through the mocked `.read_cog` binding in the {nert}
# namespace.  Real `terra::extract()` runs against in-memory fixture
# rasters, so the values that end up in the output table are real
# extractions from real (tiny) rasters -- not values invented by the mock.

KEY <- "test-key-0000"

# ---- Golden path -----------------------------------------------------------

test_that("collect_tern_data fills SMIPS column at requested locations", {
  .use_mocked_cog(raster = .fixture_numeric_raster(value = 42))
  out <- collect_tern_data(
    date_range = as.Date(c("2024-01-01", "2024-01-02")),
    lon = c(138.6, 139.5),
    lat = c(-34.9, -35.5),
    datasets = "SMIPS",
    smips_collection = "totalbucket",
    api_key = KEY,
    verbose = FALSE
  )
  expect_s3_class(out, "data.table")
  expect_identical(nrow(out), 4L) # 2 dates x 2 locations
  expect_true("SMIPS_totalbucket" %in% names(out))
  expect_true(all(out$SMIPS_totalbucket == 42))
})

test_that("collect_tern_data emits one COG read per work item (vectorised)", {
  sink <- .use_mocked_cog()
  collect_tern_data(
    date_range = seq(as.Date("2024-01-01"), as.Date("2024-01-03"), by = "day"),
    lon = c(138.6, 139.5, 140.0),
    lat = c(-34.9, -35.5, -36.0),
    datasets = "SMIPS",
    smips_collection = "totalbucket",
    api_key = KEY,
    verbose = FALSE
  )
  # 1 variant x 3 dates = 3 work items, regardless of #locations.
  expect_length(sink$urls, 3L)
})

test_that("collect_tern_data emits the right shape for SMIPS x SLGA mix", {
  .use_mocked_cog()
  out <- collect_tern_data(
    date_range = as.Date(c("2024-01-01", "2024-01-01")),
    lon = 138.6,
    lat = -34.9,
    datasets = c("SMIPS", "AWC"),
    smips_collection = "totalbucket",
    depth = "000_005",
    api_key = KEY,
    verbose = FALSE
  )
  expect_setequal(
    names(out),
    c("date", "lon", "lat", "SMIPS_totalbucket", "AWC")
  )
})

test_that("ASC populates a character column", {
  .use_mocked_cog(raster = .fixture_character_raster())
  out <- collect_tern_data(
    date_range = as.Date("2024-01-01"),
    lon = 138.6,
    lat = -34.9,
    datasets = "ASC",
    api_key = KEY,
    verbose = FALSE
  )
  expect_type(out$ASC, "character")
  expect_false(anyNA(out$ASC))
})

test_that("CANOPY (static) value is replicated across the date axis", {
  .use_mocked_cog(raster = .fixture_numeric_raster(value = 12))
  out <- collect_tern_data(
    date_range = seq(as.Date("2024-01-01"), as.Date("2024-01-05"), by = "day"),
    lon = 138.6,
    lat = -34.9,
    datasets = "CANOPY",
    api_key = KEY,
    verbose = FALSE
  )
  expect_identical(nrow(out), 5L)
  expect_true(all(out$CANOPY == 12))
})

# ---- Failure mode: schema invariance ---------------------------------------

test_that("a per-COG fetch failure leaves the column at NA without dropping it", {
  .use_mocked_cog(error_msg = "simulated COG fetch failure")
  out <- suppressWarnings(collect_tern_data(
    date_range = as.Date("2024-01-01"),
    lon = 138.6,
    lat = -34.9,
    datasets = "SMIPS",
    smips_collection = "totalbucket",
    api_key = KEY,
    verbose = FALSE
  ))
  expect_true("SMIPS_totalbucket" %in% names(out))
  expect_true(all(is.na(out$SMIPS_totalbucket)))
})

test_that("fetch failure surfaces a cli_warn carrying the dataset/date label", {
  .use_mocked_cog(error_msg = "simulated COG fetch failure")
  expect_warning(
    collect_tern_data(
      date_range = as.Date("2024-01-01"),
      lon = 138.6,
      lat = -34.9,
      datasets = "SMIPS",
      smips_collection = "totalbucket",
      api_key = KEY,
      verbose = FALSE
    ),
    "SMIPS totalbucket 2024-01-01"
  )
})

# ---- Output schema columns are predeclared at planning time ----------------

test_that("column set is invariant under partial failure", {
  .use_mocked_cog(error_msg = "boom")
  out <- suppressWarnings(collect_tern_data(
    date_range = as.Date(c("2024-01-01", "2024-01-01")),
    lon = 138.6,
    lat = -34.9,
    datasets = c("SMIPS", "AWC", "CANOPY"),
    smips_collection = "totalbucket",
    depth = "000_005",
    api_key = KEY,
    verbose = FALSE
  ))
  # Every requested dataset still has its column, all NA on failure.
  expect_setequal(
    names(out),
    c("date", "lon", "lat", "SMIPS_totalbucket", "AWC", "CANOPY")
  )
  for (col in c("SMIPS_totalbucket", "AWC", "CANOPY")) {
    expect_true(all(is.na(out[[col]])))
  }
})

# ---- na.rm = TRUE drops all-NA rows ---------------------------------------

test_that("na.rm=TRUE drops rows where every data column is NA", {
  .use_mocked_cog(error_msg = "boom")
  out <- suppressWarnings(collect_tern_data(
    date_range = as.Date("2024-01-01"),
    lon = 138.6,
    lat = -34.9,
    datasets = "SMIPS",
    smips_collection = "totalbucket",
    api_key = KEY,
    verbose = FALSE,
    na.rm = TRUE
  ))
  expect_identical(nrow(out), 0L)
})
