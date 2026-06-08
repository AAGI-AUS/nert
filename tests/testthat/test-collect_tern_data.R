# Offline tests for collect_tern_data() internals.  These exercise the parser
# and work-item planner without any network I/O.

# .parse_coordinates ---------------------------------------------------------

test_that(".parse_coordinates accepts scalar lon/lat", {
  c1 <- .parse_coordinates(138.6, -34.9, NULL)
  expect_identical(nrow(c1), 1L)
  expect_identical(names(c1), c("lon", "lat"))
})

test_that(".parse_coordinates accepts vector lon/lat of equal length", {
  c1 <- .parse_coordinates(c(138.6, 139.5), c(-34.9, -35.5), NULL)
  expect_identical(nrow(c1), 2L)
})

test_that(".parse_coordinates accepts xy data.frame with lon/lat columns", {
  c1 <- .parse_coordinates(NULL, NULL,
                           data.frame(lon = c(138.6, 139.5),
                                      lat = c(-34.9, -35.5)))
  expect_identical(nrow(c1), 2L)
})

test_that(".parse_coordinates accepts xy data.frame with x/y columns", {
  c1 <- .parse_coordinates(NULL, NULL,
                           data.frame(x = c(138.6, 139.5),
                                      y = c(-34.9, -35.5)))
  expect_identical(nrow(c1), 2L)
  expect_identical(c1$lon, c(138.6, 139.5))
})

test_that(".parse_coordinates accepts xy matrix", {
  m <- matrix(c(138.6, 139.5, -34.9, -35.5), ncol = 2L,
              dimnames = list(NULL, c("lon", "lat")))
  c1 <- .parse_coordinates(NULL, NULL, m)
  expect_identical(nrow(c1), 2L)
})

test_that(".parse_coordinates rejects mismatched lon/lat lengths", {
  expect_error(
    .parse_coordinates(c(138.6, 139.5), -34.9, NULL),
    "equal length"
  )
})

test_that(".parse_coordinates rejects out-of-bounds coordinates", {
  expect_error(.parse_coordinates(181, 0, NULL), "out of bounds")
  expect_error(.parse_coordinates(0, 91, NULL), "out of bounds")
})

test_that(".parse_coordinates rejects NA coordinates", {
  expect_error(.parse_coordinates(NA_real_, 0, NULL), "must not be")
  expect_error(.parse_coordinates(0, NA_real_, NULL), "must not be")
})

test_that(".parse_coordinates rejects xy without recognised columns", {
  expect_error(
    .parse_coordinates(NULL, NULL,
                       data.frame(a = 1, b = 2)),
    "must have columns"
  )
})

test_that(".parse_coordinates rejects when both lon/lat and xy missing", {
  expect_error(.parse_coordinates(NULL, NULL, NULL), "must provide")
})

# .parse_date_range ---------------------------------------------------------

test_that(".parse_date_range expands a length-2 character range to daily", {
  d <- .parse_date_range(c("2024-01-01", "2024-01-05"))
  expect_identical(length(d), 5L)
  expect_equal(d[1L], as.Date("2024-01-01"))
})

test_that(".parse_date_range preserves an explicit Date vector", {
  in_dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-03"), by = "day")
  d <- .parse_date_range(in_dates)
  expect_identical(d, in_dates)
})

test_that(".parse_date_range rejects unparseable dates", {
  expect_error(.parse_date_range(c("nope", "also-nope")),
               "No valid dates")
})

# .normalise_datasets -------------------------------------------------------

test_that(".normalise_datasets returns the full alias set for NULL/'all'", {
  expect_identical(length(.normalise_datasets(NULL)), 20L)
  expect_identical(.normalise_datasets("all"), .normalise_datasets(NULL))
})

test_that(".normalise_datasets case-folds and deduplicates", {
  expect_identical(
    .normalise_datasets(c("smips", "SMIPS", "asc")),
    c("SMIPS", "ASC")
  )
})

test_that(".normalise_datasets warns and filters unknown aliases", {
  expect_warning(
    out <- .normalise_datasets(c("SMIPS", "BOGUS")),
    "Unknown datasets"
  )
  expect_identical(out, "SMIPS")
})

test_that(".normalise_datasets errors when no recognised aliases remain", {
  suppressWarnings(
    expect_error(.normalise_datasets("BOGUS"), "supported datasets")
  )
})

# .build_work_items planner: shape only -------------------------------------

test_that("work-item planner emits one item per SMIPS (date, variant)", {
  dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-03"), by = "day")
  items <- .build_work_items("SMIPS", dates, "all", "EV", "all")
  # 6 variants x 3 dates = 18 items
  expect_identical(length(items), 18L)
  expect_true(all(vapply(items, function(x) x$ds == "SMIPS", logical(1L))))
})

test_that("work-item planner emits one item per AET date", {
  dates <- seq(as.Date("2023-06-01"), as.Date("2023-08-01"), by = "month")
  items <- .build_work_items("AET", dates, "all", "EV", "all")
  expect_identical(length(items), 3L)
})

test_that("work-item planner emits six items for SLGA depth='all'", {
  items <- .build_work_items("AWC", as.Date("2024-01-01"),
                             "all", "EV", "all")
  expect_identical(length(items), 6L)
  expect_true(all(grepl("^AWC_", vapply(items, function(x) x$cols[1L],
                                        character(1L)))))
})

test_that("work-item planner emits one item for SLGA single depth", {
  items <- .build_work_items("CLY", as.Date("2024-01-01"),
                             "000_005", "EV", "all")
  expect_identical(length(items), 1L)
  expect_identical(items[[1L]]$cols, "CLY")
})

test_that("work-item planner emits one item each for static non-SLGA", {
  for (ds in c("ASC", "CANOPY", "SOILDIV", "PHENOLOGY")) {
    items <- .build_work_items(ds, as.Date("2010-06-01"),
                               "all", "EV", "all")
    expect_identical(length(items), 1L)
    expect_true(is.na(items[[1L]]$date_idx))
  }
})

test_that("ASC work item is flagged character-typed", {
  items <- .build_work_items("ASC", as.Date("2024-01-01"),
                             "all", "EV", "all")
  expect_identical(items[[1L]]$type, "character")
})

test_that("All other datasets are flagged numeric-typed", {
  for (ds in c("SMIPS", "AET", "AWC", "CLY", "CANOPY",
               "SOILDIV", "PHENOLOGY")) {
    items <- .build_work_items(ds, as.Date("2010-06-01"),
                               "000_005", "EV", "totalbucket")
    expect_true(all(vapply(items, function(x) x$type == "numeric",
                           logical(1L))))
  }
})

test_that("PHENOLOGY clamps year to 2003-2018 window", {
  items <- .build_work_items("PHENOLOGY", as.Date("2024-06-01"),
                             "all", "EV", "all")
  expect_identical(items[[1L]]$args$year, 2018L)
  items2 <- .build_work_items("PHENOLOGY", as.Date("1990-06-01"),
                              "all", "EV", "all")
  expect_identical(items2[[1L]]$args$year, 2003L)
})

# Schema invariant: failed work items leave columns as NA, schema stable ----

test_that("collect_tern_data plans schema independently of fetch success", {
  # Plan-only: confirm the column set for a typical multi-dataset call
  items <- .build_work_items(
    c("SMIPS", "AWC", "ASC", "CANOPY"),
    seq(as.Date("2024-01-01"), as.Date("2024-01-02"), by = "day"),
    "all", "EV", "all"
  )
  cols <- unique(unlist(lapply(items, function(x) x$cols)))
  expect_setequal(cols, c(
    "SMIPS_totalbucket", "SMIPS_SMindex", "SMIPS_bucket1",
    "SMIPS_bucket2", "SMIPS_deepD", "SMIPS_runoff",
    "AWC_000_005", "AWC_005_015", "AWC_015_030",
    "AWC_030_060", "AWC_060_100", "AWC_100_200",
    "ASC", "CANOPY"
  ))
})
