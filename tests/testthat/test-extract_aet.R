test_that("extract_aet returns a data.table with correct structure", {
  skip_on_cran()
  skip_on_ci()
  skip_if(!nzchar(Sys.getenv("TERN_API_KEY")), "TERN API key not available")
  locs <- list(
    "Corrigin" = c(x = 117.87, y = -32.33),
    "Merredin" = c(x = 118.28, y = -31.48),
    "Tamworth" = c(x = 150.84, y = -31.07)
  )
  tab <- extract_aet(xy = locs, month = "2023-01-01")
  expect_s3_class(tab, "data.table")
  expect_equal(nrow(tab), 3L)
  expect_named(tab, c("location", "x", "y", "aet_ETa_202301"))
  expect_equal(tab$location, c("Corrigin", "Merredin", "Tamworth"))
})

test_that("extract_aet errors with an appropriate message if no month provided", {
  locs <- list("Corrigin" = c(x = 117.87, y = -32.33))
  expect_error(
    extract_aet(xy = locs, api_key = "test_key"),
    "You must provide a month for this request."
  )
})

test_that("extract_aet column name reflects collection and month", {
  skip_on_cran()
  skip_on_ci()
  skip_if(!nzchar(Sys.getenv("TERN_API_KEY")), "TERN API key not available")
  locs <- list("Corrigin" = c(x = 117.87, y = -32.33))
  tab <- extract_aet(xy = locs, month = "2023-06-15", collection = "ETa")
  expect_true("aet_ETa_202306" %in% names(tab))
})
