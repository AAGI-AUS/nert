#' Get or Set Up API Key for TERN
#'
#' Checks first to get key from your .Rprofile or .Renviron (or similar) file.
#'   If it's not found, then it suggests setting it up.  Can be used to check
#'   that your key that \R is using is the key that you wish to be using or for
#'   guidance in setting up the keys.
#'
#' @note
#' \acronym{TERN} creates \acronym{API} keys that have special characters that
#'   include \dQuote{/}, which causes the query to fail. Currently, `get_key()`
#'   checks for this in the `API_KEY` string and replaces it with \dQuote(%2f)
#'   so that the query will work properly.
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
    return(gsub("/", "%2f", TERN_API_KEY, fixed = TRUE))
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
#'   accounts page.
.set_tern_key <- function() {
  if (interactive()) {
    utils::browseURL("https://account.tern.org.au/authenticated_user/apikeys")
  }

  stop(
    "You need to create and/or set your TERN API key.\n",
    "After getting your key set it as 'TERN_API_KEY' in .Renviron.\n",
    "TERN_API_KEY='youractualkeynotthisstring'\n",
    "For that, use `usethis::edit_r_environ()`"
  )

  invisible("https://account.tern.org.au/authenticated_user/apikeys")
}
