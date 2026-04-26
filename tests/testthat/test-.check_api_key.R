# For now, the only problematic character seems to be "/", but
# update the below test(s) if we discover any other HTML-unsafe
# characters in the TERN API keys.
test_that("All / characters are replaced with the HTML-safe %2f", {
  a_key <- "abc/123//def"
  expect_identical(.check_api_key(a_key), "abc%2f123%2f%2fdef")
})
