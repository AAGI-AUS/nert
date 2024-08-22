#' Get or Set Up API Key for TERN
#'
#' Checks first to get key from your .Rprofile or .Renviron (or similar) file.
#'   If it's not found, then it suggests setting it up.  Can be used to check
#'   that your key that \R is using is the key that you wish to be using or for
#'   guidance in setting up the keys.
#'
#' @details
#' The suggestion is to use your .Renviron to set up the API key. However, if
#'  you regularly interact with the APIs outside of \R using some other
#'  language you may wish to set these up in your .bashrc, .zshrc, or
#'  config.fish for cross-language use.
#'
#' @return A string value with your \acronym{API} key value.
#'
#' @examples
#' \dontrun{
#' get_key()
#' }
#'
#' @export
get_key <- function() {
  TERN_API_KEY <- Sys.getenv("TERN_API_KEY")

  if (!nzchar(TERN_API_KEY)) {
    .set_tern_key()
  } else {
    return(TERN_API_KEY)
  }
}

#' Help the User Request an API Key for the TERN API
#'
#' Opens a browser window at the TERN API key request URL and provides
#'   instruction on how to store the key. After filling the form you will get
#'   the key soon, but not immediately.
#'
#' @keywords internal
#' @noRd
#' @return Called for its side-effects, opens a browser window at the TERN
#'   weather data API key request form.
.set_tern_key <- function() {
  if (interactive()) {
    utils::browseURL("https://ternapikeydetails")
  }

  stop(
    "You need to set your TERN API key.\n",
    "After getting your key set it as 'DPIRD_API_KEY' in .Renviron.\n",
    "TERN_API_KEY='youractualkeynotthisstring'\n",
    "For that, use `usethis::edit_r_environ()`"
  )

  invisible("https://ternapikeydetails")
}
