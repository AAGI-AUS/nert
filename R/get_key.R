#' Get or Set Up API Key for TERN
#'
#' Fetches your \acronym{TERN} \acronym{API} key through \pkg{keyring}.  If no
#'   key is found, instructions for setting one up are shown and an error is
#'   raised.  Can be used to check that the key that \R is using is the key that
#'   you wish to be using, or for guidance in setting the key up in the first
#'   place.
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
#' \pkg{nert} reads the key through \pkg{keyring}, a suggested package, so
#'   install it first with `install.packages("keyring")`.
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
#' A key held in the default store is used as well.  On macOS this is the login
#'   keychain, which unlocks when you log in:
#'
#' ```r
#' library(keyring)
#' key_set("TERN_API_KEY")
#' ```
#'
#' On a machine with no password manager, \pkg{keyring} reads the environment
#'   instead.  Set both variables in the `.Renviron` file that
#'   [usethis::edit_r_environ()] opens, then restart \R:
#'
#' ```
#' R_KEYRING_BACKEND=env
#' TERN_API_KEY=your_api_key
#' ```
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
  if (!rlang::is_installed("keyring")) {
    cli::cli_abort(
      c(
        "{.pkg keyring} is required to read your TERN API key.",
        "i" = "Install it with {.code install.packages('keyring')}, then store
               your key as shown in {.code ?get_key}."
      ),
      class = "nert_no_keyring_package"
    )
  }

  backend <- tryCatch(
    keyring::default_backend(),
    error = function(e) {
      .set_tern_key(reports = paste0("keyring: ", conditionMessage(e)))
    }
  )

  reports <- character()

  # The "nert" keyring first, then the default store.
  for (store in list("nert", NULL)) {
    attempt <- .read_tern_key(backend, keyring = store)

    if (nzchar(attempt$key)) {
      return(attempt$key)
    }

    reports <- c(reports, attempt$report)
  }

  .set_tern_key(reports = reports)
}

#' Read the TERN API Key From One Credential Store
#'
#' Reports the key or what the store raised when no key is supplied.
#'
#' @param backend The \pkg{keyring} backend, from [keyring::default_backend()].
#' @param keyring Name of the keyring to read, or `NULL` for the default store.
#' @returns A named `list`: `key`, empty when no key was supplied, and `report`,
#'   what the store raised.
#'
#' @dev
.read_tern_key <- function(backend, keyring) {
  if (!is.null(keyring) && !isTRUE(backend$has_keyring_support())) {
    return(list(key = "", report = character()))
  }

  store <- if (is.null(keyring)) {
    "the default credential store"
  } else {
    paste0("the ", keyring, " keyring")
  }

  return(tryCatch(
    list(
      key = backend$get("TERN_API_KEY", keyring = keyring),
      report = character()
    ),
    error = function(e) {
      list(
        key = "",
        report = paste0(store, ": ", conditionMessage(e))
      )
    }
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
#' @param reports A `character` vector of what each credential store raised,
#'   listed in the error.
#' @returns Called for its side-effects, shows instructions for acquiring and
#'   storing a key and raises an error of class `nert_no_key`.
.set_tern_key <- function(reports = character()) {
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
      login keychain, which unlocks when you log in."
    )
  }

  cli::cat_line()

  message <- "Could not read a TERN API key from any credential store."

  if (length(reports) > 0L) {
    message <- c(message, rlang::set_names(reports, "*"))
  }

  rlang::abort(message, class = "nert_no_key")
}
