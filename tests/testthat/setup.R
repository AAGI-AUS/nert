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
