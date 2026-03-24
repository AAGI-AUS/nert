# Load TERN_API_KEY when R CMD check doesn't inherit user environment variables.
# R CMD check sanitises the environment by unsetting R_ENVIRON_USER, so keys
# stored in ~/.Renviron are not available unless we explicitly re-read them.
if (!nzchar(Sys.getenv("TERN_API_KEY"))) {
  renviron <- file.path(Sys.getenv("HOME"), ".Renviron")
  if (file.exists(renviron)) {
    lines <- readLines(renviron, warn = FALSE)
    key_line <- grep("^TERN_API_KEY", lines, value = TRUE)
    if (length(key_line) > 0L) {
      key <- sub("^TERN_API_KEY\\s*=\\s*", "", key_line[[1L]])
      key <- gsub("^['\"]|['\"]$", "", key)
      Sys.setenv(TERN_API_KEY = key)
    }
  }
}
