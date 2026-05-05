# Package load hook: initialise nert package options.
#
# Pattern adapted from {read.abares} (Adam H. Sparks, rOpenSci-review):
# https://github.com/ropensci/read.abares/blob/main/R/zzz.R
#
# Closes AAGI-AUS/nert#20.

# nocov start
.onLoad <- function(libname, pkgname) {
  .init_nert_options()
}
# nocov end


#' Initialise \pkg{nert} package options (internal)
#'
#' Extracted from `.onLoad()` to allow direct unit testing.  Sets
#' package-level defaults for the retry behaviour shared by every
#' `read_*()` and `collect_tern_data()` call:
#' \itemize{
#'   \item `nert.max_tries` — integer, default `3L`
#'   \item `nert.initial_delay` — integer (seconds), default `1L`
#' }
#'
#' Existing user-set values (e.g. set in `.Rprofile` or via
#' [base::options()] before `library(nert)`) are preserved; only
#' unset options are populated with defaults.
#'
#' @returns `NULL`, invisibly.  Called for its side effect on
#'   [base::options()].
#' @autoglobal
#' @dev
.init_nert_options <- function() {
  op <- options()
  op_nert <- list(
    nert.max_tries     = 3L,
    nert.initial_delay = 1L
  )
  toset <- !(names(op_nert) %in% names(op))
  if (any(toset)) {
    options(op_nert[toset])
  }
  invisible(NULL)
}
