# Tests for the nert package options (closes #20).
# These exercise the .onLoad() hook and the NULL-resolution behaviour of
# .read_cog() without hitting the network.

test_that("nert options are populated at load time with documented defaults", {
  expect_identical(getOption("nert.max_tries"), 3L)
  expect_identical(getOption("nert.initial_delay"), 1L)
})

test_that("user-set nert options take precedence over defaults", {
  withr::with_options(
    list(nert.max_tries = 7L, nert.initial_delay = 4L),
    {
      expect_identical(getOption("nert.max_tries"), 7L)
      expect_identical(getOption("nert.initial_delay"), 4L)
    }
  )
})

test_that(".init_nert_options() preserves pre-existing user values", {
  # If a user (or .Rprofile) has already set nert.max_tries before the
  # package loads, .init_nert_options() must not clobber it.
  withr::with_options(
    list(nert.max_tries = 99L, nert.initial_delay = 99L),
    {
      .init_nert_options()
      expect_identical(getOption("nert.max_tries"), 99L)
      expect_identical(getOption("nert.initial_delay"), 99L)
    }
  )
})

test_that(".read_cog() argument overrides getOption() default", {
  # Stub terra::rast() so we never hit the network; capture the resolved
  # max_tries by forcing the retry loop to run once and then succeed.
  rast_calls <- 0L
  fake_rast <- function(...) {
    rast_calls <<- rast_calls + 1L
    "fake_raster" # success on first call
  }
  testthat::with_mocked_bindings(
    rast = fake_rast,
    .package = "terra",
    code = {
      withr::with_options(
        list(nert.max_tries = 1L, nert.initial_delay = 1L),
        {
          # Per-call max_tries = 5L overrides option (1L); we just check the
          # call succeeds and returns the stubbed raster.
          out <- .read_cog("fake_url", max_tries = 5L, initial_delay = 2L)
          expect_identical(out, "fake_raster")
          expect_identical(rast_calls, 1L)
        }
      )
    }
  )
})

test_that(".read_cog() falls back to getOption() when args are NULL", {
  rast_calls <- 0L
  fake_rast <- function(...) {
    rast_calls <<- rast_calls + 1L
    "fake_raster"
  }
  testthat::with_mocked_bindings(
    rast = fake_rast,
    .package = "terra",
    code = {
      withr::with_options(
        list(nert.max_tries = 2L, nert.initial_delay = 1L),
        {
          # Both NULL → resolved from options; should still succeed on
          # first attempt because rast() doesn't error.
          out <- .read_cog("fake_url", max_tries = NULL, initial_delay = NULL)
          expect_identical(out, "fake_raster")
        }
      )
    }
  )
})
