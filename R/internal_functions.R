#' Check that the user hasn't blindly copied the "your_api_key" string from the
#' examples
#'
#' @autoglobal
#' @dev
.check_not_example_api_key <- function(.api_key) {
  if (!is.null(.api_key) && .api_key == "your_api_key") {
    stop(
      "You have copied the example code and not provided a proper API key.
         An API key may be requested from TERN to access this resource. Please
         see the help file for {.fn get_key} for more information.",
      call. = FALSE
    )
  }
  return(invisible(NULL))
}


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
          delay <- initial_delay * 2^(attempt - 1)
          cli::cli_alert(
            "Download failed on attempt { attempt }.
                         Retrying in { delay } seconds..."
          )
          Sys.sleep(delay)
          attempt <<- attempt + 1
        } else {
          cli::cli_abort("Download failed after { max_tries } attempts.")
          stop(e)
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
