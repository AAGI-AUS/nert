test_that("An error is raised when the API key is the example string", {
  # multiple dates
  expect_error(
    .check_not_example_api_key("your_api_key"),
    "You have copied the example code and not provided a proper API key.
    An API key may be requested from TERN to access this resource. Please
    see the help file for {.fn get_key} for more information."
  )
})
