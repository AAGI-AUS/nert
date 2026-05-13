# Cross-cutting helpers for COG access.
#
# These helpers are not specific to any single TERN dataset; every
# read_*() handler ultimately funnels through `.read_cog()` and the
# `.check_api_key()` URL-encoding step.  Dataset-specific helpers
# (e.g. `.make_aet_url()`, `.make_smips_url()`) live in the dataset's
# own read_*.R file alongside its exported wrapper.

#' Read a COG from TERN
#'
#' @param full_url The URL providing access to the requested data.
#' @param max_tries Maximum number of download attempts before erroring.
#'   When `NULL` (default), resolved at call time from
#'   `getOption("nert.max_tries", 3L)`.  Pass an integer to override
#'   for a single call.
#' @param initial_delay Initial retry delay in seconds (doubles each
#'   attempt).  When `NULL` (default), resolved at call time from
#'   `getOption("nert.initial_delay", 1L)`.  Pass an integer to override
#'   for a single call.
#'
#' @returns A [terra::rast()] object of the requested data.
#' @importFrom rlang %||%
#' @autoglobal
#' @dev
.read_cog <- function(full_url, max_tries = NULL, initial_delay = NULL) {
  max_tries     <- max_tries     %||% getOption("nert.max_tries", 3L)
  initial_delay <- initial_delay %||% getOption("nert.initial_delay", 1L)

  max_tries     <- suppressWarnings(as.integer(max_tries))
  initial_delay <- suppressWarnings(as.integer(initial_delay))
  if (is.na(max_tries) || max_tries < 1L) {
    cli::cli_abort(
      "{.arg max_tries} must be a positive integer; got {.val {max_tries}}."
    )
  }
  if (is.na(initial_delay) || initial_delay < 0L) {
    cli::cli_abort(
      "{.arg initial_delay} must be a non-negative integer; \\
       got {.val {initial_delay}}."
    )
  }

  attempt <- 1L
  success <- FALSE

  while (attempt <= max_tries && !success) {
    tryCatch(
      {
        r <- terra::rast(full_url)
        success <- TRUE
        return(r)
      },
      error = function(e) {
        if (attempt < max_tries) {
          delay <- initial_delay * 2L^(attempt - 1L)
          cli::cli_alert(
            "Download failed on attempt { attempt }.
                         Retrying in { delay } seconds..."
          )
          Sys.sleep(delay)
          attempt <<- attempt + 1L
        } else {
          cli::cli_abort(
            "Download failed after { max_tries } attempts.",
            parent = e
          )
        }
      }
    )
  }
}

#' Fix improper API keys
#'
#' @param api_key A `string` value containing a TERN API key for checking
#'
#' @returns A `string` value with replacement of troublesome characters if
#'  necessary.
#' @dev
.check_api_key <- function(api_key) {
  gsub("/", "%2f", api_key, fixed = TRUE)
}
