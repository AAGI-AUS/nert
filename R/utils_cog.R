# Cross-cutting helpers for COG access.

#' Read a COG from TERN
#' @param dots Named list of `...` args from [read_tern()].
#' @param dataset_id Raw `dataset_id` (unused; uniform validator signature).
#' @returns `NULL`; called for its side effects (argument validation).
#' @dev
.read_cog <- function(full_url, max_tries = NULL, initial_delay = NULL) {
  max_tries <- max_tries %||% getOption("nert.max_tries", 3L)
  initial_delay <- initial_delay %||% getOption("nert.initial_delay", 1L)

  params <- suppressWarnings(as.integer(c(max_tries, initial_delay)))
  max_tries <- params[[1L]]
  initial_delay <- params[[2L]]
  if (is.na(max_tries) || max_tries < 1L) {
    cli::cli_abort(
      "{.arg max_tries} must be a positive integer; got {.val {max_tries}}."
    )
  }
  if (is.na(initial_delay) || initial_delay < 0L) {
    cli::cli_abort(
      "{.arg initial_delay} must be a non-negative integer; got {.val {initial_delay}}."
    )
  }

  # GDAL retries HTTP 429 and 5xx responses, including reads after the open.
  terra::setGDALconfig("GDAL_HTTP_MAX_RETRY", as.character(max_tries - 1L))
  terra::setGDALconfig("GDAL_HTTP_RETRY_DELAY", as.character(initial_delay))

  return(tryCatch(
    terra::rast(full_url),
    error = function(e) {
      msg <- "Could not read the file from TERN."
      if (max_tries > 1L) {
        msg <- c(
          msg,
          "i" = "Busy and server-error responses were retried up to
            {max_tries - 1L} time{?s}."
        )
      }
      cli::cli_abort(msg)
    }
  ))
}

#' Fix improper API keys
#'
#' @param api_key A `string` value containing a TERN API key for checking
#'
#' @returns A `string` value with replacement of troublesome characters if
#'  necessary.
#' @dev
.check_api_key <- function(api_key) {
  return(gsub("/", "%2f", api_key, fixed = TRUE))
}
