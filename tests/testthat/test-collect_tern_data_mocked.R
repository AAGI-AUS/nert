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

test_that("collect_tern_data resolves API key once before work-item loop", {
  .use_mocked_cog()
  calls <- 0L
  testthat::local_mocked_bindings(
    get_key = function() {
      calls <<- calls + 1L
      KEY
    },
    .package = "nert"
  )

  out <- collect_tern_data(
    date_range = seq(as.Date("2024-01-01"), as.Date("2024-01-03"), by = "day"),
    lon = 138.6,
    lat = -34.9,
    datasets = "SMIPS",
    smips_collection = c("bucket1", "totalbucket"),
    verbose = FALSE
  )

  expect_identical(calls, 1L)
  expect_true(all(out$SMIPS_bucket1 == 42))
  expect_true(all(out$SMIPS_totalbucket == 42))
})

test_that("collect_tern_data errors once when API key is missing", {
  calls <- 0L
  testthat::local_mocked_bindings(
    get_key = function() {
      calls <<- calls + 1L
      cli::cli_abort("mock missing key")
    },
    .package = "nert"
  )

  expect_error(
    collect_tern_data(
      date_range = seq(
        as.Date("2024-01-01"),
        as.Date("2024-01-03"),
        by = "day"
      ),
      lon = 138.6,
      lat = -34.9,
      datasets = "SMIPS",
      smips_collection = c("bucket1", "totalbucket"),
      verbose = FALSE
    ),
    "mock missing key"
  )
  expect_identical(calls, 1L)
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
    stat = "EV",
    api_key = KEY,
    verbose = FALSE
  )
  expect_setequal(
    names(out),
    c("date", "lon", "lat", "SMIPS_totalbucket", "AWC_EV_000_005")
  )
})

test_that("ASC populates a character column for EV, a double column for CI", {
  .use_mocked_cog(raster = .fixture_character_raster())
  out <- collect_tern_data(
    date_range = as.Date("2024-01-01"),
    lon = 138.6,
    lat = -34.9,
    datasets = "ASC",
    api_key = KEY,
    verbose = FALSE
  )
  expect_type(out$ASC_EV, "character")
  expect_type(out$ASC_CI, "double")
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
  expect_true(all(out$CANOPY_best_pick == 12))
  expect_true(all(out$CANOPY_median == 12))
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
    stat = "05",
    canopy_collection = "best_pick",
    api_key = KEY,
    verbose = FALSE
  ))
  # Every requested dataset still has its column, all NA on failure.
  expect_setequal(
    names(out),
    c(
      "date",
      "lon",
      "lat",
      "SMIPS_totalbucket",
      "AWC_05_000_005",
      "CANOPY_best_pick"
    )
  )
  for (col in c("SMIPS_totalbucket", "AWC_05_000_005", "CANOPY_best_pick")) {
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

# ---- PHENOLOGY resolves per row, not per request (#95) ---------------------

test_that("PHENOLOGY writes each year's value into that year's rows", {
  by_year <- c("2017" = 17, "2018" = 18)
  urls <- character()
  testthat::local_mocked_bindings(
    .read_cog = function(full_url, max_tries = NULL, initial_delay = NULL) {
      urls <<- c(urls, full_url)
      year <- sub("^.*_(\\d{4})_Season\\d\\.tif$", "\\1", full_url)
      .fixture_numeric_raster(value = by_year[[year]])
    },
    .package = "nert"
  )

  dates <- as.Date(c("2017-06-01", "2017-12-01", "2018-06-01"))
  out <- collect_tern_data(
    dates = dates,
    lon = c(138.6, 139.5),
    lat = c(-34.9, -35.5),
    datasets = "PHENOLOGY",
    phenology_collection = "SGS",
    api_key = KEY,
    verbose = FALSE
  )

  # 2 seasons x 2 years = 4 reads, and 2 columns rather than 4
  expect_length(urls, 4L)
  expect_true(all(c("PHENOLOGY_SGS_s1", "PHENOLOGY_SGS_s2") %in% names(out)))
  expect_identical(nrow(out), 6L) # 3 dates x 2 locations

  # Every row carries the value belonging to the year of its own date
  expected <- unname(by_year[format(out$date, "%Y")])
  expect_identical(out$PHENOLOGY_SGS_s1, expected)
  expect_identical(out$PHENOLOGY_SGS_s2, expected)
  expect_false(anyNA(out$PHENOLOGY_SGS_s1))
})

test_that("PHENOLOGY rows outside 2003-2018 are NA with a warning", {
  sink <- .use_mocked_cog(raster = .fixture_numeric_raster(value = 5))
  # The out-of-window date comes first, where it used to decide the year
  dates <- as.Date(c("1990-06-01", "2005-06-01", "2024-06-01"))
  warns <- character()
  out <- withCallingHandlers(
    collect_tern_data(
      dates = dates,
      lon = 138.6,
      lat = -34.9,
      datasets = "PHENOLOGY",
      phenology_collection = "SGS",
      api_key = KEY,
      verbose = FALSE
    ),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  # Only 2005 is read, once per season
  expect_length(sink$urls, 2L)
  expect_true(all(grepl("_2005_Season[12]\\.tif$", sink$urls)))
  # 2 out-of-window years x 2 seasons, each naming the window
  expect_length(warns, 4L)
  expect_true(all(grepl("2003--2018", warns)))

  expected <- ifelse(format(out$date, "%Y") == "2005", 5, NA_real_)
  expect_identical(out$PHENOLOGY_SGS_s1, expected)
  expect_identical(out$PHENOLOGY_SGS_s2, expected)
})

test_that("the #95 reprex returns NA PHENOLOGY columns without reading", {
  sink <- .use_mocked_cog()
  out <- suppressWarnings(collect_tern_data(
    date_range = seq(as.Date("2024-01-01"), as.Date("2024-01-05"), by = "day"),
    lon = 138.6,
    lat = -34.9,
    datasets = "PHENOLOGY",
    phenology_collection = "SGS",
    api_key = KEY,
    verbose = FALSE
  ))
  expect_length(sink$urls, 0L)
  expect_identical(nrow(out), 5L)
  expect_true(all(is.na(out$PHENOLOGY_SGS_s1)))
  expect_true(all(is.na(out$PHENOLOGY_SGS_s2)))
})
