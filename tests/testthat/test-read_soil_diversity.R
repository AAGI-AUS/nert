# Offline behaviour tests for read_soil_diversity().
# Mocking via helper-mocks.R; no network I/O.

KEY <- "test-key-0000"

test_that("defaults resolve to Bacteria axis-1 URL", {
  sink <- .use_mocked_cog()
  read_soil_diversity(api_key = KEY)
  expect_match(sink$urls, "NMDS_Bacteria_1_Bacteria_pred.tif", fixed = TRUE)
  expect_match(sink$urls,
               "Other/SoilBetaDiversity/NMDS_Bacteria_1_Bacteria_pred.tif",
               fixed = TRUE)
})

test_that("Fungi collection flows into the filename", {
  sink <- .use_mocked_cog()
  read_soil_diversity(collection = "Fungi", api_key = KEY)
  expect_match(sink$urls, "NMDS_Fungi_1_Fungi_pred.tif", fixed = TRUE)
})

test_that("axis flows through (1, 2, 3 all distinct)", {
  sink <- .use_mocked_cog()
  for (a in 1L:3L) {
    read_soil_diversity(axis = a, api_key = KEY)
  }
  expect_length(unique(sink$urls), 3L)
  expect_match(sink$urls[[1L]], "_1_", fixed = TRUE)
  expect_match(sink$urls[[2L]], "_2_", fixed = TRUE)
  expect_match(sink$urls[[3L]], "_3_", fixed = TRUE)
})

test_that("Fungi axis 2 combines both args", {
  sink <- .use_mocked_cog()
  read_soil_diversity(collection = "Fungi", axis = 2L, api_key = KEY)
  expect_match(sink$urls, "NMDS_Fungi_2_Fungi_pred.tif", fixed = TRUE)
})

# ---- Validation -----------------------------------------------------------

test_that("axis must be 1, 2, or 3", {
  expect_error(read_soil_diversity(axis = 0L, api_key = KEY),
               "must be 1, 2, or 3")
  expect_error(read_soil_diversity(axis = 4L, api_key = KEY),
               "must be 1, 2, or 3")
})

test_that("collection must be Bacteria or Fungi", {
  expect_error(read_soil_diversity(collection = "Archaea", api_key = KEY),
               "must be one of")
})

test_that("axis is coerced to integer", {
  sink <- .use_mocked_cog()
  read_soil_diversity(axis = 2, api_key = KEY) # numeric, not integer
  expect_match(sink$urls, "_2_", fixed = TRUE)
})
