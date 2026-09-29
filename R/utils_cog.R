# Cross-cutting helpers for COG access.

#' Read a COG from TERN
#' @param dots Named list of `...` args from [read_tern()].
#' @param dataset_id Raw `dataset_id` (unused; uniform validator signature).
#' @returns `NULL`; called for its side effects (argument validation).
#' @dev
.read_cog <- function(
  full_url,
  max_tries = NULL,
  initial_delay = NULL,
  opts = NULL
) {
  max_tries <- if (is.null(max_tries)) {
    getOption("nert.max_tries", 3L)
  } else {
    max_tries
  }
  initial_delay <- if (is.null(initial_delay)) {
    getOption("nert.initial_delay", 1L)
  } else {
    initial_delay
  }

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

  # GDAL retries busy and server errors, including reads after the open.
  terra::setGDALconfig("GDAL_HTTP_MAX_RETRY", as.character(max_tries - 1L))
  terra::setGDALconfig("GDAL_HTTP_RETRY_DELAY", as.character(initial_delay))

  return(tryCatch(
    terra::rast(full_url, opts = opts),
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

#' Pass the TERN API key to GDAL
#'
#' Sets the GDAL `GDAL_HTTP_USERPWD` option, which stays set for the rest of the
#' R session because terra reads raster values only when they are used. Warns
#' the first time it is set. When the key changes, TERN files are no longer
#' cached, so a read that failed with the old key is not reused.
#'
#' @param api_key A `string` value containing a TERN API key.
#' @returns `invisible(NULL)`. This function is called for its side effect.
#' @dev
.set_tern_auth <- function(api_key) {
  userpwd <- paste0("apikey:", api_key)
  current <- unname(terra::getGDALconfig("GDAL_HTTP_USERPWD"))
  if (identical(current, userpwd)) {
    return(invisible(NULL))
  }
  if (nzchar(current)) {
    terra::setGDALconfig(
      "CPL_VSIL_CURL_NON_CACHED",
      "/vsicurl/https://data.tern.org.au/"
    )
  } else {
    cli::cli_warn(c(
      "nert has set the GDAL option {.envvar GDAL_HTTP_USERPWD} to your TERN
       API key for the rest of this R session.",
      "i" = "GDAL sends the key with every {.code /vsicurl} request in this
       session, including requests to servers other than TERN.",
      "i" = "Restart R to clear it."
    ))
  }
  terra::setGDALconfig("GDAL_HTTP_USERPWD", userpwd)
  return(invisible(NULL))
}
