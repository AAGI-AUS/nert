has_tern_key <- function() {
  tryCatch(
    {
      key <- keyring::key_get(
        service = "TERN_API_KEY",
        keyring = "nert"
      )

      nzchar(key)
    },
    error = function(e) FALSE
  )
}

skip_if_no_tern_key <- function() {
  testthat::skip_if_not(
    has_tern_key(),
    "TERN API key not available in keyring"
  )
}
