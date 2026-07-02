test_that("Key retrieval works when a key exists", {
  a_key <- "some_api_key"
  withr::local_envvar(TERN_API_KEY = a_key)
  expect_identical(get_key(), a_key)
})

test_that("Key retrieval throws errors when a key does not exist", {
  withr::local_envvar(TERN_API_KEY = "")
  expect_error(get_key())
})

# Note: get_key() does not gsub any problematic characters like "/",
# this task is left to the read_* functions when they are making the
# queries (by calling .check_api_key, for example).
test_that("Key retrieval performs no sanitation on problematic chars", {
  a_key <- "abc/123"
  withr::local_envvar(TERN_API_KEY = a_key)
  expect_identical(get_key(), a_key)
})

test_that("an interactive session opens the key-request page before aborting", {
  withr::local_envvar(TERN_API_KEY = "")
  opened <- new.env(parent = emptyenv())
  testthat::local_mocked_bindings(
    is_interactive = function() TRUE,
    .package = "rlang"
  )
  testthat::local_mocked_bindings(
    browseURL = function(url, ...) {
      opened$url <- url
      invisible()
    },
    .package = "utils"
  )
  expect_error(get_key(), "TERN API key")
  expect_match(opened$url, "account.tern.org.au", fixed = TRUE)
})
