# Offline behaviour tests for read_phenology().
# Mocking via helper-mocks.R; no network I/O.

KEY <- "test-key-0000"

# Phenology metric -> directory name registry mirrored from
# internal_functions.R::.phenology_metrics.  Update both if either changes.
METRIC_DIR <- list(
  SGS = "1_Start_of_the_growing_season",
  PGS = "2_Peak_of_the_growing_season",
  EGS = "3_End_of_the_growing_season",
  LGS = "4_Length_of_the_growing_season",
  SOS = "5_Start_of_season",
  POS = "6_Peak_of_season",
  EOS = "7_End_of_season",
  LOS = "8_Length_of_season",
  ROG = "9_Rate_of_greening",
  ROS = "10_Rate_of_senescence"
)

# ---- All ten metrics map to the documented subdirectory --------------------

test_that("every phenology metric maps to its documented subdirectory", {
  sink <- .use_mocked_cog()
  for (m in names(METRIC_DIR)) {
    read_phenology(year = 2018L, collection = m, api_key = KEY)
  }
  expect_length(sink$urls, length(METRIC_DIR))
  for (i in seq_along(METRIC_DIR)) {
    m   <- names(METRIC_DIR)[[i]]
    dir <- METRIC_DIR[[m]]
    expect_match(
      sink$urls[[i]],
      sprintf("/phenology_myd13a1/%s/%s_2018_Season1.tif", dir, m),
      fixed = TRUE
    )
  }
})

# ---- Season selector flows into the filename -------------------------------

test_that("season = 2 lands in the filename", {
  sink <- .use_mocked_cog()
  read_phenology(year = 2015L, season = 2L, api_key = KEY)
  expect_match(sink$urls, "SGS_2015_Season2.tif", fixed = TRUE)
})

test_that("season must be 1 or 2", {
  expect_error(read_phenology(year = 2018L, season = 0L, api_key = KEY),
               "must be 1 or 2")
  expect_error(read_phenology(year = 2018L, season = 3L, api_key = KEY),
               "must be 1 or 2")
})

# ---- Year validator --------------------------------------------------------

test_that("year < 2003 is rejected", {
  expect_error(read_phenology(year = 2002L, api_key = KEY),
               "2003")
})

test_that("year > 2018 is rejected", {
  expect_error(read_phenology(year = 2019L, api_key = KEY),
               "2018")
})

test_that("year = 2003 (lower bound) is accepted", {
  sink <- .use_mocked_cog()
  read_phenology(year = 2003L, api_key = KEY)
  expect_match(sink$urls, "SGS_2003_Season1.tif", fixed = TRUE)
})

test_that("year = 2018 (upper bound) is accepted", {
  sink <- .use_mocked_cog()
  read_phenology(year = 2018L, api_key = KEY)
  expect_match(sink$urls, "SGS_2018_Season1.tif", fixed = TRUE)
})

test_that("year coerces from integer-valued numeric", {
  sink <- .use_mocked_cog()
  read_phenology(year = 2018, api_key = KEY) # numeric, not L
  expect_match(sink$urls, "_2018_", fixed = TRUE)
})

# ---- Collection validation -------------------------------------------------

test_that("unknown collection is rejected", {
  expect_error(
    read_phenology(year = 2018L, collection = "XYZ", api_key = KEY),
    "must be one of"
  )
})

# ---- read_tern dispatch ----------------------------------------------------

test_that("read_tern dispatches PHENOLOGY alias through to phenology handler", {
  sink <- .use_mocked_cog()
  read_tern("PHENOLOGY", year = 2018L, api_key = KEY)
  expect_match(sink$urls, "/phenology_myd13a1/", fixed = TRUE)
})
