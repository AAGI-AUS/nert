test_that("Key retrieval works when a key exists", {
  a_key <- "some_api_key"
  Sys.setenv(TERN_API_KEY = a_key)

  expect_identical(get_key(), a_key)
})

test_that("Key retrieval throws errors when a key does not exist", {
  Sys.setenv(TERN_API_KEY = "")

  expect_error(get_key())
})
