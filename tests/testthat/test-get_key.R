test_that("get_key returns a key when one exists", {
  testthat::local_mocked_bindings(
    key_get = function(...) "some_api_key",
    .package = "keyring"
  )

  expect_identical(
    get_key(),
    "some_api_key"
  )
})

test_that("get_key falls back to .set_tern_key when no key exists", {
  testthat::local_mocked_bindings(
    key_get = function(...) stop("password not found"),
    .package = "keyring"
  )

  testthat::local_mocked_bindings(
    .set_tern_key = function() {
      rlang::abort("No TERN_API_KEY found.")
    },
    .package = "nert"
  )

  expect_error(
    get_key(),
    "No TERN_API_KEY found"
  )
})

test_that("get_key performs no sanitation on problematic characters", {
  testthat::local_mocked_bindings(
    key_get = function(...) "abc/123",
    .package = "keyring"
  )

  expect_identical(
    get_key(),
    "abc/123"
  )
})

test_that(".set_tern_key aborts in non-interactive sessions", {
  testthat::local_mocked_bindings(
    is_interactive = function() FALSE,
    .package = "rlang"
  )

  expect_error(
    .set_tern_key()
  )
})
