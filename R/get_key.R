#' Get or Set Up API Key for TERN
#'
#' Fetches your \acronym{TERN} \acronym{API} key from the \pkg{keyring}
#'   package's credential store.  If no key is found, instructions for setting
#'   one up are shown and an error is raised.  Can be used to check that the
#'   key that \R is using is the key that you wish to be using, or for guidance
#'   in setting the key up in the first place.
#'
#' # Requesting an API Key
#'
#' To request an \acronym{API} key, go to
#'   <https://account.tern.org.au/authenticated_user/apikeys> and click on
#'   "Sign In" in the upper right corner. Sign in with your proper credentials.
#'   Then, from the left-hand menu, click on "Create API Key".  Copy the key
#'   before leaving the page, as it cannot be read back afterwards.
#'
#' # Storing your key
#'
#' \pkg{nert} reads the key through \pkg{keyring}, which is a suggested
#'   package rather than a hard dependency, so install it first with
#'   `install.packages("keyring")`.
#'
#' The `"nert"` keyring is read first, where the backend supports named
#'   keyrings:
#'
#' ```r
#' library(keyring)
#' keyring_create("nert")
#' key_set("TERN_API_KEY", keyring = "nert")
#' ```
#'
#' A key held in the default store is used as well.  This is the more
#'   comfortable option on macOS, where a named keyring is a separate keychain
#'   file that locks when the machine sleeps or restarts and then asks for a
#'   password of its own.  The login keychain does not:
#'
#' ```r
#' library(keyring)
#' key_set("TERN_API_KEY")
#' ```
#'
#' On a machine with no password manager, such as a server or a continuous
#'   integration runner, \pkg{keyring} reads the environment instead.  Set both
#'   variables in the `.Renviron` file that [usethis::edit_r_environ()] opens,
#'   then restart \R:
#'
#' ```
#' R_KEYRING_BACKEND=env
#' TERN_API_KEY=your_api_key
#' ```
#'
#' Setting `TERN_API_KEY` on its own has no effect on macOS or Windows, where
#'   \pkg{keyring} reads the system password manager unless
#'   `R_KEYRING_BACKEND` sends it elsewhere.
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
  if (!.has_keyring()) {
    cli::cli_abort(
      c(
        "The {.pkg keyring} package is required to read your TERN API key.",
        "i" = "Install it with {.code install.packages('keyring')}, then store
               your key as shown in {.code ?get_key}."
      )
    )
  }

  key <- .read_tern_key(keyring = "nert")

  if (!nzchar(key)) {
    key <- .read_tern_key(keyring = NULL)
  }

  if (nzchar(key)) {
    return(key)
  }

  .set_tern_key()
}

#' Report Whether the keyring Package Is Installed
#'
#' \pkg{keyring} is a suggested package, so its absence has to be reported as a
#'   missing package rather than as a missing key.  Wrapping
#'   [requireNamespace()] keeps the check mockable in the test suite.
#'
#' @returns A `logical` value, `TRUE` when \pkg{keyring} is installed.
#'
#' @dev
.has_keyring <- function() {
  return(requireNamespace("keyring", quietly = TRUE))
}

#' Read the TERN API Key From One Credential Store
#'
#' Returns an empty string rather than raising an error when no key is held, so
#'   that the caller can go on to the next store.  A named keyring is skipped
#'   where the active backend does not support one, which is what keeps the
#'   environment backend used by servers and continuous integration runners
#'   from warning on every call that the `keyring` argument is ignored.
#'
#' @param keyring Name of the keyring to read, or `NULL` for the default store.
#' @returns A `character` string holding the key, empty when none is found.
#'
#' @dev
.read_tern_key <- function(keyring) {
  named_supported <- tryCatch(
    keyring::has_keyring_support(),
    error = function(e) FALSE
  )

  if (!is.null(keyring) && !isTRUE(named_supported)) {
    return("")
  }

  return(tryCatch(
    keyring::key_get(
      "TERN_API_KEY",
      keyring = keyring
    ),
    error = function(e) ""
  ))
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
    cli::cat_line()
    cli::cli_alert_info(
      "On macOS, {.code key_set('TERN_API_KEY')} on its own puts the key in the
      login keychain, which does not lock behind a second password."
    )
  }

  cli::cat_line()
  rlang::abort(
    "No TERN_API_KEY found. See the instructions above."
  )
}
