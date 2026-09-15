fake_backend <- function(get, keyrings = TRUE) {
  list(
    has_keyring_support = function() keyrings,
    get = get
  )
}

test_that("get_key returns a key when one exists", {
  testthat::local_mocked_bindings(
    default_backend = function(...) {
      fake_backend(get = function(...) "some_api_key")
    },
    .package = "keyring"
  )

  expect_identical(
    get_key(),
    "some_api_key"
  )
})

test_that("get_key falls back to .set_tern_key when no key exists", {
  testthat::local_mocked_bindings(
    default_backend = function(...) {
      fake_backend(get = function(...) stop("password not found"))
    },
    .package = "keyring"
  )

  testthat::local_mocked_bindings(
    .set_tern_key = function(...) {
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
    default_backend = function(...) fake_backend(get = function(...) "abc/123"),
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

test_that("get_key reports a missing keyring package as a missing package", {
  testthat::local_mocked_bindings(
    is_installed = function(pkg, ...) !identical(pkg, "keyring"),
    .package = "rlang"
  )

  expect_error(
    get_key(),
    class = "nert_no_keyring_package"
  )
})

test_that("get_key reads the default store when the named keyring is empty", {
  testthat::local_mocked_bindings(
    default_backend = function(...) {
      fake_backend(get = function(service, username = NULL, keyring = NULL) {
        if (!is.null(keyring)) {
          stop("password not found")
        }

        "default_store_key"
      })
    },
    .package = "keyring"
  )

  expect_identical(
    get_key(),
    "default_store_key"
  )
})

test_that("get_key is silent when the env backend is set explicitly", {
  withr::local_options(keyring_backend = NULL)
  withr::local_envvar(R_KEYRING_BACKEND = "env", TERN_API_KEY = "env_key")

  expect_silent(key <- get_key())
  expect_identical(key, "env_key")
})

test_that("get_key warns once when keyring falls back to the env backend", {
  testthat::local_mocked_bindings(
    default_backend = function(...) {
      warning(
        "Selecting 'env' backend. Secrets are stored in environment variables"
      )
      fake_backend(get = function(...) "env_key", keyrings = FALSE)
    },
    .package = "keyring"
  )

  warnings <- character()
  key <- withCallingHandlers(
    get_key(),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  expect_length(warnings, 1L)
  expect_identical(key, "env_key")
})

test_that(".read_tern_key skips a named keyring the backend cannot provide", {
  called <- FALSE

  backend <- fake_backend(
    get = function(...) {
      called <<- TRUE
      "unreachable_key"
    },
    keyrings = FALSE
  )

  skipped <- .read_tern_key(backend, keyring = "nert")

  expect_identical(skipped$key, "")
  expect_identical(skipped$report, character())
  expect_false(called)
})

test_that("get_key names what each credential store reported", {
  testthat::local_mocked_bindings(
    default_backend = function(...) {
      fake_backend(get = function(...) stop("User interaction is not allowed."))
    },
    .package = "keyring"
  )

  expect_error(
    get_key(),
    "User interaction is not allowed",
    class = "nert_no_key"
  )
})

test_that("a store that cannot be read is not reported as an absent key", {
  testthat::local_mocked_bindings(
    default_backend = function(...) {
      fake_backend(get = function(...) stop("The nert keychain is locked."))
    },
    .package = "keyring"
  )

  reported <- tryCatch(get_key(), error = function(e) conditionMessage(e))

  expect_match(reported, "locked")
})

test_that("get_key reports a keyring backend that cannot be selected", {
  testthat::local_mocked_bindings(
    default_backend = function(...) stop("Unknown keyring backend: vault"),
    .package = "keyring"
  )

  expect_error(
    get_key(),
    "Unknown keyring backend",
    class = "nert_no_key"
  )
})
