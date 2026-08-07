#' Get or Set Up API Key for TERN
#'
#' Checks first to get key from your .Rprofile or .Renviron (or similar) file.
#'   If it's not found, then it suggests setting it up.  Can be used to check
#'   that your key that \R is using is the key that you wish to be using or for
#'   guidance in setting up the keys.
#'
#' # Requesting an API Key
#'
#' To request an \acronym{API} key, go to
#'   <https://account.tern.org.au/authenticated_user/apikeys> and click on
#'   "Sign In" in the upper right corner. Sign in with your proper credentials.
#'   Then, from the left-hand menu, click on "Create API Key".  Once this is
#'   done, copy the key and put it in your .Renviron using
#'   [usethis::edit_r_environ()] as `TERN_API_KEY="your_api_key"`. Restart your
#'   \R session and the query should work.
#'
#' @returns A string value with your \acronym{API} key value.
#'
#' @examples
#' \dontrun{
#' get_key()
#' }
#'
#' @export
get_key <- function() {
  key <- tryCatch(
    keyring::key_get(
      "TERN_API_KEY",
      keyring = "nert"
    ),
    error = function(e) ""
  )

  if (nzchar(key)) {
    return(key)
  }

  .set_tern_key()
}

#' Help the User Request an API Key for the TERN API
#'
#' Opens a browser window at the TERN API key request URL and provides
#'   instruction on how to store the key. After filling the form you will get
#'   the key soon, but not immediately.
#'
#' @dev
#'
#' @returns Called for its side-effects, checks for presence of a TERN key in
#'   the user's key ring and errors if one is not found with instructions for
#'   acquiring one.
.set_tern_key <- function() {
  if (rlang::is_interactive()) {
    cli::cli_alert_warning(
      "You need to create and/or set your TERN API key. Go to
      {.url https://account.tern.org.au/authenticated_user/apikeys} to request
      one. After getting your key, set it up as {.val TERN_API_KEY} using the
      {.pkg keyring} package."
    )
    cli::cat_line()
    cli::cli_rule(left = "Instructions")
    cli::cli_code(c(
      "library(keyring)",
      "keyring_create('nert')",
      "key_set('TERN_API_KEY', keyring = 'nert')"
    ))
  }

  cli::cat_line()
  rlang::abort(
    "No TERN_API_KEY found. See the instructions above."
  )
}
