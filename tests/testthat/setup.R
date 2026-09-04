has_tern_key <- function() {
  key <- tryCatch(
    get_key(),
    error = function(e) ""
  )

  nzchar(key)
}
