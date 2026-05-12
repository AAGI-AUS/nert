#' Read a COG from TERN
#'
#' @param full_url The URL providing access to the requested data.
#' @param max_tries The number of times to retry downloading before timing out.
#'
#' @returns A [terra::rast()] object of the requested data.
#' @autoglobal
#' @dev
.read_cog <- function(full_url, max_tries, initial_delay) {
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
