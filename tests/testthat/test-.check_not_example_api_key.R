test_that("An error is raised when the API key is the example string", {
  # multiple dates
  expect_error(.check_not_example_api_key("your_api_key"))
})
