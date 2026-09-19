has_tern_key <- function() {
  tryCatch(
    nzchar(get_key()),
    nert_no_key = function(cnd) FALSE
  )
}
