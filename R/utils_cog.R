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

  for (attempt in seq_len(max_tries)) {
    result <- tryCatch(
      {
        terra::rast(full_url)
      },
      error = function(e) {
        if (attempt < max_tries) {
          delay <- initial_delay * 2L^(attempt - 1L)
          cli::cli_alert(
            "Download failed on attempt {attempt}. Retrying in {delay} seconds..."
          )
          Sys.sleep(delay)
        }
        NULL
      }
    )

    if (!is.null(result)) {
      return(result)
    }
  }

  cli::cli_abort("Download failed after {max_tries} attempts.")
}

#' Pass the TERN API key to GDAL
#'
#' Sets the GDAL `GDAL_HTTP_USERPWD` option, which stays set for the rest of the
#' R session because terra reads raster values only when they are used.
#'
#' @param api_key A `string` value containing a TERN API key.
#' @returns `invisible(NULL)`. This function is called for its side effect.
#' @dev
.set_tern_auth <- function(api_key) {
  terra::setGDALconfig("GDAL_HTTP_USERPWD", paste0("apikey:", api_key))
  return(invisible(NULL))
}
