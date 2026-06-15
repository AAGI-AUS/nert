# Tests for input-validation hardening introduced in 1.0.1.  These tests are
# deterministic and offline -- they never touch the TERN API.

# .read_cog -- max_tries / initial_delay sanitisation ------------------------

test_that(".read_cog rejects max_tries < 1 before any network I/O", {
  expect_error(
    .read_cog("file:///dev/null", max_tries = 0L),
    "must be a positive integer"
  )
  expect_error(
    .read_cog("file:///dev/null", max_tries = -2L),
    "must be a positive integer"
  )
  expect_error(
    .read_cog("file:///dev/null", max_tries = "two"),
    "must be a positive integer"
  )
})

test_that(".read_cog rejects negative initial_delay", {
  expect_error(
    .read_cog("file:///dev/null", max_tries = 1L, initial_delay = -1L),
    "must be a non-negative integer"
  )
})

# .tern_dispatch_id -- vector inputs -----------------------------------------

test_that(".tern_dispatch_id rejects vector input", {
  expect_error(
    .tern_dispatch_id(c("SMIPS", "ASC")),
    "must be a single character string"
  )
  expect_error(
    .tern_dispatch_id(character(0)),
    "must be a single character string"
  )
})

test_that("read_tern rejects vector dataset_id", {
  expect_error(
    read_tern(c("SMIPS", "ASC")),
    "must be a single character string"
  )
})

test_that("read_phenology errors cleanly when year is omitted", {
  expect_error(read_phenology(), "Phenology requires")
})

test_that("Phenology year validator rejects non-integer values", {
  expect_error(
    read_tern("PHENOLOGY", year = 2018.5),
    "must be an integer"
  )
  expect_error(
    read_tern("PHENOLOGY", year = "2018-01"),
    "must be an integer"
  )
})

test_that("Phenology year validator rejects vector years", {
  expect_error(
    read_tern("PHENOLOGY", year = c(2018L, 2019L)),
    "must be a single value"
  )
})
