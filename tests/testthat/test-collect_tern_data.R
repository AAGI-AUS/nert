# Offline tests for collect_tern_data() internals.  These exercise the parser
# and work-item planner without any network I/O.

# .parse_coordinates ---------------------------------------------------------

test_that(".parse_coordinates accepts scalar lon/lat", {
  c1 <- .parse_coordinates(138.6, -34.9, NULL)
  expect_identical(nrow(c1), 1L)
  expect_named(c1, c("lon", "lat"))
})

test_that(".parse_coordinates accepts vector lon/lat of equal length", {
  c1 <- .parse_coordinates(c(138.6, 139.5), c(-34.9, -35.5), NULL)
  expect_identical(nrow(c1), 2L)
})

test_that(".parse_coordinates accepts xy data.frame with lon/lat columns", {
  c1 <- .parse_coordinates(
    NULL,
    NULL,
    data.frame(lon = c(138.6, 139.5), lat = c(-34.9, -35.5))
  )
  expect_identical(nrow(c1), 2L)
})

test_that(".parse_coordinates accepts xy data.frame with x/y columns", {
  c1 <- .parse_coordinates(
    NULL,
    NULL,
    data.frame(x = c(138.6, 139.5), y = c(-34.9, -35.5))
  )
  expect_identical(nrow(c1), 2L)
  expect_identical(c1$lon, c(138.6, 139.5))
})

test_that(".parse_coordinates accepts xy matrix", {
  m <- matrix(
    c(138.6, 139.5, -34.9, -35.5),
    ncol = 2L,
    dimnames = list(NULL, c("lon", "lat"))
  )
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
  expect_error(.parse_coordinates(89, 0, NULL), "out of bounds")
  expect_error(.parse_coordinates(0, -52, NULL), "out of bounds")
  expect_error(.parse_coordinates(0, -7, NULL), "out of bounds")
})

test_that(".parse_coordinates rejects NA coordinates", {
  expect_error(.parse_coordinates(NA_real_, 0, NULL), "must not be")
  expect_error(.parse_coordinates(0, NA_real_, NULL), "must not be")
})

test_that(".parse_coordinates rejects xy without recognised columns", {
  expect_error(
    .parse_coordinates(NULL, NULL, data.frame(a = 1, b = 2)),
    "must have columns"
  )
})

test_that(".parse_coordinates rejects when both lon/lat and xy missing", {
  expect_error(.parse_coordinates(NULL, NULL, NULL), "must provide")
})

# .parse_date_range ---------------------------------------------------------

test_that(".parse_date_range expands a length-2 character range to daily", {
  d <- .parse_date_range(c("2024-01-01", "2024-01-05"))
  expect_length(d, 5L)
  expect_equal(d[1L], as.Date("2024-01-01"))
})

test_that(".parse_date_range preserves an explicit Date vector", {
  in_dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-03"), by = "day")
  d <- .parse_date_range(in_dates)
  expect_identical(d, in_dates)
})

test_that(".parse_date_range rejects unparseable dates", {
  expect_error(
    .parse_date_range(c("nope", "also-nope")),
    "not in a standard unambiguous format"
  )
})

test_that(".parse_date_range rejects a reversed range with a clear message", {
  expect_error(
    .parse_date_range(c("2024-01-05", "2024-01-01")),
    "must not be after its end"
  )
  expect_error(
    .parse_date_range(c(as.Date("2024-01-05"), as.Date("2024-01-01"))),
    "must not be after its end"
  )
})

# .normalise_datasets -------------------------------------------------------

test_that(".normalise_datasets returns the full alias set for NULL/'all'", {
  all_aliases <- c(
    "SMIPS",
    "ASC",
    "AET",
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
    "L15",
    "SOILDIV",
    "CANOPY",
    "PHENOLOGY"
  )
  expect_length(.normalise_datasets(NULL), length(all_aliases))
  expect_identical(sort(.normalise_datasets(NULL)), sort(all_aliases))
  expect_identical(.normalise_datasets("all"), .normalise_datasets(NULL))
})

test_that(".normalise_datasets deduplicates", {
  expect_identical(
    .normalise_datasets(c("SMIPS", "SMIPS", "ASC")),
    c("SMIPS", "ASC")
  )
})

test_that(".normalise_datasets preserves order", {
  expect_identical(
    .normalise_datasets(c("SMIPS", "ASC", "AET", "CLY", "ECE")),
    c("SMIPS", "ASC", "AET", "CLY", "ECE")
  )
  expect_false(isTRUE(all.equal(
    .normalise_datasets(c("SMIPS", "ASC", "AET", "CLY", "ECE")),
    sort(c("SMIPS", "ASC", "AET", "CLY", "ECE"))
  )))
})

test_that(".normalise_datasets warns and filters invalid aliases", {
  expect_warning(
    out <- .normalise_datasets(c("SMIPS", "BOGUS")),
    "Invalid"
  )
  expect_identical(out, "SMIPS")
})

test_that(".normalise_datasets errors when no valid aliases remain", {
  suppressWarnings(
    expect_error(.normalise_datasets("BOGUS"), "No valid")
  )
})

# .normalise_depth -------------------------------------------------------

test_that(".normalise_depth returns the full depth set for NULL/'all'", {
  valid_depths <- c(
    "000_005",
    "005_015",
    "015_030",
    "030_060",
    "060_100",
    "100_200"
  )
  expect_length(.normalise_depth(NULL), length(valid_depths))
  expect_identical(sort(.normalise_depth(NULL)), sort(valid_depths))
  expect_identical(.normalise_depth("all"), .normalise_depth(NULL))
})

test_that(".normalise_depth deduplicates", {
  expect_identical(
    .normalise_depth(c("000_005", "005_015", "000_005")),
    c("000_005", "005_015")
  )
})

test_that(".normalise_depth preserves order", {
  expect_identical(
    .normalise_depth(c("060_100", "015_030", "030_060")),
    c("060_100", "015_030", "030_060")
  )
  expect_false(isTRUE(all.equal(
    .normalise_depth(c("060_100", "015_030", "030_060")),
    sort(c("060_100", "015_030", "030_060"))
  )))
})

test_that(".normalise_depth warns and filters invalid depths", {
  expect_warning(
    out <- .normalise_depth(c("000_005", "005-015")),
    "Invalid"
  )
  expect_identical(out, "000_005")
})

test_that(".normalise_depth errors when no valid depths remain", {
  suppressWarnings(
    expect_error(.normalise_depth("000_010"), "No valid")
  )
})

# .normalise_stat -------------------------------------------------------

test_that(".normalise_stat returns the full stat set for NULL/'all'", {
  valid_stats <- c("EV", "05", "95")
  expect_length(.normalise_stat(NULL), length(valid_stats))
  expect_identical(sort(.normalise_stat(NULL)), sort(valid_stats))
  expect_identical(.normalise_stat("all"), .normalise_stat(NULL))
})

test_that(".normalise_stat deduplicates", {
  expect_identical(
    .normalise_stat(c("EV", "05", "EV")),
    c("EV", "05")
  )
})

test_that(".normalise_stat preserves order", {
  expect_identical(
    .normalise_stat(c("05", "EV", "95")),
    c("05", "EV", "95")
  )
  expect_false(isTRUE(all.equal(
    .normalise_stat(c("05", "EV", "95")),
    sort(c("05", "EV", "95"))
  )))
  expect_false(isTRUE(all.equal(
    .normalise_stat(c("05", "EV", "95")),
    c("EV", "05", "95")
  )))
})

test_that(".normalise_stat warns and filters invalid statistics", {
  expect_warning(
    out <- .normalise_stat(c("EV", "CI")),
    "Invalid"
  )
  expect_identical(out, "EV")
})

test_that(".normalise_stat errors when no valid statistics remain", {
  suppressWarnings(
    expect_error(.normalise_stat("CI"), "No valid")
  )
})

# .normalise_smips_collection --------------------------------------------------

test_that(".normalise_smips_collection returns the full SMIPS set for NULL/'all'", {
  valid_smips <- c(
    "totalbucket",
    "SMindex",
    "bucket1",
    "bucket2",
    "deepD",
    "runoff"
  )
  expect_length(.normalise_smips_collection(NULL), length(valid_smips))
  expect_identical(sort(.normalise_smips_collection(NULL)), sort(valid_smips))
  expect_identical(
    .normalise_smips_collection("all"),
    .normalise_smips_collection(NULL)
  )
})

test_that(".normalise_smips_collection deduplicates", {
  expect_identical(
    .normalise_smips_collection(c("bucket1", "bucket1", "bucket2", "bucket1")),
    c("bucket1", "bucket2")
  )
})

test_that(".normalise_smips_collection preserves order", {
  expect_identical(
    .normalise_smips_collection(c("bucket1", "deepD", "bucket2", "SMindex")),
    c("bucket1", "deepD", "bucket2", "SMindex")
  )
  expect_false(isTRUE(all.equal(
    .normalise_smips_collection(c("bucket1", "deepD", "bucket2", "SMindex")),
    sort(c("bucket1", "deepD", "bucket2", "SMindex"))
  )))
})

test_that(".normalise_smips_collection warns and filters invalid variants", {
  expect_warning(
    out <- .normalise_smips_collection(c("soil_moisture", "EV", "runoff")),
    "Invalid"
  )
  expect_identical(out, "runoff")
})

test_that(".normalise_smips_collection errors when no valid variants remain", {
  suppressWarnings(
    expect_error(.normalise_smips_collection("soil_moisture"), "No valid")
  )
})

# .normalise_asc_collection --------------------------------------------------

test_that(".normalise_asc_collection returns the full ASC set for NULL/'all'", {
  valid_asc <- c("EV", "CI")
  expect_length(.normalise_asc_collection(NULL), length(valid_asc))
  expect_identical(sort(.normalise_asc_collection(NULL)), sort(valid_asc))
  expect_identical(
    .normalise_asc_collection("all"),
    .normalise_asc_collection(NULL)
  )
})

test_that(".normalise_asc_collection deduplicates", {
  expect_identical(
    .normalise_asc_collection(c("EV", "EV", "CI", "EV")),
    c("EV", "CI")
  )
})

test_that(".normalise_asc_collection preserves order", {
  expect_identical(
    .normalise_asc_collection(c("CI", "EV")),
    c("CI", "EV")
  )
  expect_false(isTRUE(all.equal(
    .normalise_asc_collection(c("EV", "CI")),
    c("CI", "EV")
  )))
})

test_that(".normalise_asc_collection warns and filters invalid variants", {
  expect_warning(
    out <- .normalise_asc_collection(c("EV", "order")),
    "Invalid"
  )
  expect_identical(out, "EV")
})

test_that(".normalise_asc_collection errors when no valid variants remain", {
  suppressWarnings(
    expect_error(.normalise_asc_collection("soil_order"), "No valid")
  )
})

# .normalise_aet_collection --------------------------------------------------

test_that(".normalise_aet_collection returns the full AET set for NULL/'all'", {
  valid_aet <- c("ETa", "pixel_qa")
  expect_identical(length(.normalise_aet_collection(NULL)), length(valid_aet))
  expect_identical(sort(.normalise_aet_collection(NULL)), sort(valid_aet))
  expect_identical(
    .normalise_aet_collection("all"),
    .normalise_aet_collection(NULL)
  )
})

test_that(".normalise_aet_collection deduplicates", {
  expect_identical(
    .normalise_aet_collection(c("ETa", "pixel_qa", "pixel_qa")),
    c("ETa", "pixel_qa")
  )
})

test_that(".normalise_aet_collection preserves order", {
  expect_identical(
    .normalise_aet_collection(c("pixel_qa", "ETa")),
    c("pixel_qa", "ETa")
  )
  expect_false(isTRUE(all.equal(
    .normalise_aet_collection(c("pixel_qa", "ETa")),
    sort(c("pixel_qa", "ETa"))
  )))
})

test_that(".normalise_aet_collection warns and filters invalid variants", {
  expect_warning(
    out <- .normalise_aet_collection(c("ETa", "CI", "EV")),
    "Invalid"
  )
  expect_identical(out, "ETa")
})

test_that(".normalise_aet_collection errors when no valid variants remain", {
  suppressWarnings(
    expect_error(.normalise_aet_collection("EV"), "No valid")
  )
})

# .normalise_soildiv_collection ------------------------------------------------

test_that(".normalise_soildiv_collection returns the full SOILDIV set for NULL/'all'", {
  valid_soildiv <- c(
    "Bacteria_NMDS1",
    "Bacteria_NMDS2",
    "Bacteria_NMDS3",
    "Fungi_NMDS1",
    "Fungi_NMDS2",
    "Fungi_NMDS3"
  )
  expect_identical(
    length(.normalise_soildiv_collection(NULL)),
    length(valid_soildiv)
  )
  expect_identical(
    sort(.normalise_soildiv_collection(NULL)),
    sort(valid_soildiv)
  )
  expect_identical(
    .normalise_soildiv_collection("all"),
    .normalise_soildiv_collection(NULL)
  )
})

test_that(".normalise_soildiv_collection deduplicates", {
  expect_identical(
    .normalise_soildiv_collection(c(
      "Bacteria_NMDS1",
      "Bacteria_NMDS2",
      "Bacteria_NMDS1"
    )),
    c("Bacteria_NMDS1", "Bacteria_NMDS2")
  )
})

test_that(".normalise_soildiv_collection preserves order", {
  expect_identical(
    .normalise_soildiv_collection(c(
      "Bacteria_NMDS2",
      "Fungi_NMDS1",
      "Bacteria_NMDS1"
    )),
    c("Bacteria_NMDS2", "Fungi_NMDS1", "Bacteria_NMDS1")
  )
  expect_false(isTRUE(all.equal(
    .normalise_soildiv_collection(c(
      "Bacteria_NMDS2",
      "Fungi_NMDS1",
      "Bacteria_NMDS1"
    )),
    sort(c("Bacteria_NMDS2", "Fungi_NMDS1", "Bacteria_NMDS1"))
  )))
})

test_that(".normalise_soildiv_collection warns and filters invalid variants", {
  expect_warning(
    out <- .normalise_soildiv_collection(c(
      "bacteria_nmds1",
      "bac_nmds2",
      "Fungi_NMDS3"
    )),
    "Invalid"
  )
  expect_identical(out, "Fungi_NMDS3")
})

test_that(".normalise_soildiv_collection errors when no valid variants remain", {
  suppressWarnings(
    expect_error(
      .normalise_soildiv_collection(c("bac_NMDS1", "funNMDS2")),
      "No valid"
    )
  )
})

# .normalise_phen_collection ----------------------------------------------

test_that(".normalise_phen_collection returns the full SOILDIV set for NULL/'all'", {
  valid_phenology <- c(
    "SGS",
    "PGS",
    "EGS",
    "LGS",
    "EVI1",
    "EVI2",
    "EVIP",
    "EVII",
    "SGS_month",
    "PGS_month",
    "EGS_month"
  )
  expect_identical(
    length(.normalise_phen_collection(NULL)),
    length(valid_phenology)
  )
  expect_identical(
    sort(.normalise_phen_collection(NULL)),
    sort(valid_phenology)
  )
  expect_identical(
    .normalise_phen_collection("all"),
    .normalise_phen_collection(NULL)
  )
})

test_that(".normalise_phen_collection deduplicates", {
  expect_identical(
    .normalise_phen_collection(c("SGS", "PGS", "SGS", "SGS_month", "SGS")),
    c("SGS", "PGS", "SGS_month")
  )
})

test_that(".normalise_phen_collection preserves order", {
  expect_identical(
    .normalise_phen_collection(c("EGS", "EGS_month", "SGS", "EVII")),
    c("EGS", "EGS_month", "SGS", "EVII")
  )
  expect_false(isTRUE(all.equal(
    .normalise_phen_collection(c("EGS", "EGS_month", "SGS", "EVII")),
    c("SGS", "EGS", "EVII", "EGS_month")
  )))
  expect_false(isTRUE(all.equal(
    .normalise_phen_collection(c("EGS", "EGS_month", "SGS", "EVII")),
    sort(c("EGS", "EGS_month", "SGS", "EVII"))
  )))
})

test_that(".normalise_phen_collection warns and filters invalid variants", {
  expect_warning(
    out <- .normalise_phen_collection(c("SGS", "Minimum_EVI_1", "LGS")),
    "Invalid"
  )
  expect_identical(out, c("SGS", "LGS"))
})

test_that(".normalise_phen_collection errors when no valid variants remain", {
  suppressWarnings(
    expect_error(
      .normalise_phen_collection(c("Minimum_EVI_2", "Integral_EVI")),
      "No valid"
    )
  )
})

# .build_work_items planner: shape only -------------------------------------

test_that("work-item planner emits one item per SMIPS (date, variant)", {
  dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-03"), by = "day")
  items <- .build_work_items(
    "SMIPS",
    dates,
    smips_collection = .normalise_smips_collection(NULL)
  )
  # 6 variants x 3 dates = 18 items
  expect_length(items, 18L)
  expect_true(all(vapply(items, function(x) x$ds == "SMIPS", logical(1L))))
})

test_that("work-item planner emits one item per AET (date, variant)", {
  dates <- seq(as.Date("2023-06-01"), as.Date("2023-08-01"), by = "month")
  items <- .build_work_items(
    "AET",
    dates,
    aet_collection = .normalise_aet_collection(NULL)
  )
  # 2 variants x 3 dates = 6 items
  expect_identical(length(items), 6L)
})

test_that("work-item planner emits 18 items for an SLGA dataset depth='all', stat='all'", {
  items <- .build_work_items(
    "AWC",
    as.Date("2024-01-01"),
    depth = .normalise_depth(NULL),
    stat = .normalise_stat(NULL)
  )
  # 1 SLGA dataset x 6 depths x 3 statistics = 18 items
  expect_identical(length(items), 18L)
  expect_true(all(grepl(
    "^AWC_",
    vapply(items, function(x) x$cols[1L], character(1L))
  )))
})

test_that("work-item planner emits 14 items for all SLGA datasets at one depth, one stat", {
  slga_aliases <- c(
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
  items <- .build_work_items(
    .normalise_datasets(slga_aliases),
    as.Date("2020-01-01"),
    depth = "000_005",
    stat = "EV"
  )
  # 14 SLGA datasets x 1 depth x 1 stat = 14 items
  expect_identical(length(items), 14L)
  expect_true(all(grepl(
    "_EV_000_005",
    vapply(items, function(x) x$cols[1L], character(1L)),
    fixed = TRUE
  )))
})

test_that("work-item planner emits one item for SLGA single depth, single stat", {
  items <- .build_work_items(
    "CLY",
    as.Date("2024-01-01"),
    depth = "000_005",
    stat = "EV"
  )
  expect_identical(length(items), 1L)
  expect_identical(items[[1L]]$cols, "CLY_EV_000_005")
})

test_that("work-item planner emits one item per ASC variant", {
  items <- .build_work_items(
    "ASC",
    as.Date("2022-02-03"),
    asc_collection = .normalise_asc_collection(NULL)
  )
  # 2 variants = 2 items
  expect_identical(length(items), 2L)
  expect_true(is.na(items[[1]]$date_idx))
  expect_true(is.na(items[[2]]$date_idx))
  expect_true(all(grepl(
    "^ASC_",
    vapply(items, function(x) x$cols[1L], character(1L))
  )))
})

test_that("work-item planner emits one item for CANOPY", {
  items <- .build_work_items("CANOPY", as.Date("2011-01-01"))
  expect_identical(length(items), 1L)
  expect_true(is.na(items[[1]]$date_idx))
  expect_identical(items[[1]]$cols, "CANOPY")
})

test_that("work-item planner emits one item per SOILDIV variant", {
  items <- .build_work_items(
    "SOILDIV",
    as.Date("2021-12-21"),
    soildiv_collection = .normalise_soildiv_collection(NULL)
  )
  # 6 variants = 6 items
  expect_identical(length(items), 6L)
  for (i in 1:6) {
    expect_true(is.na(items[[i]]$date_idx))
  }
  expect_true(all(grepl(
    "^SOILDIV_",
    vapply(items, function(x) x$cols[1L], character(1L))
  )))
})

test_that("work-item planner emits one item per PHENOLOGY (year,variant)", {
  items <- .build_work_items(
    "PHENOLOGY",
    as.Date("2018-09-01"),
    phenology_collection = .normalise_phen_collection(NULL)
  )
  # 6 variants = 6 items
  expect_identical(length(items), 22L)
  for (i in 1:22) {
    expect_true(is.na(items[[i]]$date_idx))
    expect_identical(items[[i]]$args$year, 2018)
  }
  expect_true(all(grepl(
    "^PHENOLOGY_",
    vapply(items, function(x) x$cols[1L], character(1L))
  )))
})

test_that("SMIPS work items have numeric-type", {
  items <- .build_work_items(
    "SMIPS",
    as.Date("2024-01-01"),
    smips_collection = .normalise_smips_collection(NULL)
  )
  for (i in seq_along(items)) {
    expect_identical(items[[i]]$type, "numeric")
  }
})

test_that("ASC work items have EV character-typed, CI numeric-typed", {
  items <- .build_work_items(
    "ASC",
    as.Date("2024-01-01"),
    asc_collection = .normalise_asc_collection(NULL)
  )
  expect_identical(items[[1L]]$type, "character")
  expect_identical(items[[2L]]$type, "numeric")
})

test_that("AET work items have ETa numeric-typed, pixel_qa numeric-typed", {
  items <- .build_work_items(
    "AET",
    as.Date("2024-01-01"),
    aet_collection = .normalise_aet_collection(NULL)
  )
  expect_identical(items[[1L]]$type, "numeric")
  expect_identical(items[[2L]]$type, "numeric")
})

test_that("SLGA dataset work items have numeric-type for all depths, variants", {
  slga_aliases <- c(
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
  items <- .build_work_items(
    slga_aliases,
    as.Date("2020-01-01"),
    depth = .normalise_depth(NULL),
    stat = .normalise_stat(NULL)
  )
  for (i in seq_along(items)) {
    expect_identical(items[[i]]$type, "numeric")
  }
})

test_that("CANOPY work items have numeric-type", {
  items <- .build_work_items("CANOPY", as.Date("2024-01-01"))
  expect_identical(items[[1]]$type, "numeric")
})

test_that("SOILDIV work items have numeric-type for all variants", {
  items <- .build_work_items(
    "SOILDIV",
    as.Date("2011-01-01"),
    soildiv_collection = .normalise_soildiv_collection(NULL)
  )
  for (i in seq_along(items)) {
    expect_identical(items[[i]]$type, "numeric")
  }
})

test_that("PHENOLOGY work items have numeric-type for all variants", {
  items <- .build_work_items(
    "PHENOLOGY",
    as.Date("2011-01-01"),
    phenology_collection = .normalise_phen_collection(NULL)
  )
  for (i in seq_along(items)) {
    expect_identical(items[[i]]$type, "numeric")
  }
})


# Russell (19/06/2026): So we actually expect the PHENOLOGY datasets to
#   clamp to 2003-2018 -- this should be documented somewhere besides in
#   these tests.
test_that("PHENOLOGY clamps year to 2003-2018 window", {
  items <- .build_work_items(
    "PHENOLOGY",
    as.Date("2024-06-01"),
    phenology_collection = .normalise_phen_collection(NULL)
  )
  for (i in seq_along(items)) {
    expect_identical(items[[i]]$args$year, 2018)
  }
  items2 <- .build_work_items(
    "PHENOLOGY",
    as.Date("1990-06-01"),
    phenology_collection = .normalise_phen_collection(NULL)
  )
  for (i in seq_along(items)) {
    expect_identical(items2[[i]]$args$year, 2003)
  }
})

# Schema invariant: failed work items leave columns as NA, schema stable ----

test_that("collect_tern_data plans schema independently of fetch success", {
  # Plan-only: confirm the column set for a typical multi-dataset call
  items <- .build_work_items(
    c("SMIPS", "AWC", "CANOPY", "ASC"),
    seq(as.Date("2024-01-01"), as.Date("2024-01-02"), by = "day"),
    smips_collection = c("bucket1", "bucket2"),
    stat = "EV",
    depth = c("000_005", "060_100"),
    asc_collection = c("EV", "CI")
  )
  cols <- unique(unlist(lapply(items, function(x) x$cols)))
  expect_setequal(
    cols,
    c(
      "SMIPS_bucket1",
      "SMIPS_bucket2",
      "AWC_EV_000_005",
      "AWC_EV_060_100",
      "CANOPY",
      "ASC_EV",
      "ASC_CI"
    )
  )
})
