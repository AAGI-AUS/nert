# Offline behaviour tests for read_phenology().
# Mocking via helper-mocks.R; network I/O only for the sanity check.

# Phenology metric -> directory name registry mirrored from
# internal_functions.R::.phenology_metrics.  Update both if either changes.
METRIC_DIR <- list(
  SGS = "1_Start_of_the_growing_season",
  PGS = "2_Peak_of_the_growing_season",
  EGS = "3_End_of_the_growing_season",
  LGS = "4_Length_of_the_growing_season",
  EVI1 = "5_Minimum_EVI_value_before_PGS",
  EVI2 = "6_Minimum_EVI_value_after_PGS",
  EVIP = "7_Peak_EVI_value_of_the_growing_season",
  EVII = "8_Integral_EVI_value_of_the_growing_season",
  SGS_month = "9_Start_of_the_growing_season_by_month",
  PGS_month = "10_Peak_of_the_growing_season_by_month",
  EGS_month = "11_End_of_the_growing_season_by_month"
)

# Sanity-check test ------------------------------------------------------------
# We need the above METRIC_DIR test fixture to actually match what
# TERN has on their servers, so this network test pulls the directory
# listing and double-checks that nothing has changed. (Not run on CRAN,
# GitHub CI: run this locally with xml2 installed.)
test_that("METRIC_DIR matches with the actual TERN server directories", {
  skip_on_ci()
  skip_if_not_installed("xml2")

  url <- "https://data.tern.org.au/remote-sensing/modis/phenology_myd13a1/"
  html <- xml2::read_html(url)
  dir_listing <- xml2::xml_attr(
    xml2::xml_find_all(html, xpath = "//table//tr//a"),
    "href"
  )
  dir_listing <- gsub("/", "", dir_listing, fixed = TRUE)
  for (dir in METRIC_DIR) {
    expect_true(dir %in% dir_listing)
  }
})


# From here, it's non-network I/O tests using the mocked COGs and test key.
KEY <- "test-key-0000"

test_that("every phenology metric maps to its documented subdirectory", {
  sink <- .use_mocked_cog()
  for (m in names(METRIC_DIR)) {
    read_phenology(year = 2018L, collection = m, api_key = KEY)
  }
  expect_length(sink$urls, length(METRIC_DIR))

  # Map the dataset variant names to the filenames in the TERN
  # server directory
  filename_prefix <- c(
    "SGS" = "SGS",
    "PGS" = "PGS",
    "EGS" = "EGS",
    "LGS" = "LGS",
    "EVI1" = "Minimum_EVI_1",
    "EVI2" = "Minimum_EVI_2",
    "EVIP" = "Peak_EVI",
    "EVII" = "Integral_EVI",
    "SGS_month" = "SGS",
    "PGS_month" = "PGS",
    "EGS_month" = "EGS"
  )
  for (i in seq_along(METRIC_DIR)) {
    m <- names(METRIC_DIR)[[i]]
    dir <- METRIC_DIR[[m]]
    m <- unname(filename_prefix[m])
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
  expect_error(
    read_phenology(year = 2018L, season = 0L, api_key = KEY),
    "must be 1 or 2"
  )
  expect_error(
    read_phenology(year = 2018L, season = 3L, api_key = KEY),
    "must be 1 or 2"
  )
})

test_that("a non-scalar season is rejected with a clear message", {
  expect_error(
    read_phenology(year = 2018L, season = c(1L, 2L), api_key = KEY),
    "must be a single value"
  )
})

# ---- Year validator --------------------------------------------------------

test_that("year < 2003 is rejected", {
  expect_error(read_phenology(year = 2002L, api_key = KEY), "2003")
})

test_that("year > 2018 is rejected", {
  expect_error(read_phenology(year = 2019L, api_key = KEY), "2018")
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
