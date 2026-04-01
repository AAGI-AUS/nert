test_that("Named list is converted to sf with correct location column", {
  locs <- list(
    "Corrigin" = c(x = 117.87, y = -32.33),
    "Merredin" = c(x = 118.28, y = -31.48)
  )
  result <- .create_sf(locs)
  expect_s3_class(result, "sf")
  expect_identical(nrow(result), 2L)
  expect_identical(result$location, c("Corrigin", "Merredin"))
  expect_identical(sf::st_crs(result)$epsg, 4326L)
})

test_that("Data.frame with location, x, y columns is converted to sf", {
  df <- data.frame(
    location = c("Site1", "Site2"),
    x = c(117.87, 118.28),
    y = c(-32.33, -31.48)
  )
  result <- .create_sf(df)
  expect_s3_class(result, "sf")
  expect_identical(nrow(result), 2L)
  expect_identical(result$location, c("Site1", "Site2"))
  expect_identical(sf::st_crs(result)$epsg, 4326L)
})

test_that("sf POINT object is passed through unchanged", {
  df <- data.frame(
    location = c("Site1", "Site2"),
    x = c(117.87, 118.28),
    y = c(-32.33, -31.48)
  )
  sf_obj <- sf::st_as_sf(df, coords = c("x", "y"), crs = 4326L)
  result <- .create_sf(sf_obj)
  expect_s3_class(result, "sf")
  expect_identical(result$location, c("Site1", "Site2"))
})

test_that("sf object without location column uses row names", {
  df <- data.frame(
    x = c(117.87, 118.28),
    y = c(-32.33, -31.48),
    row.names = c("SiteA", "SiteB")
  )
  sf_obj <- sf::st_as_sf(df, coords = c("x", "y"), crs = 4326L)
  result <- .create_sf(sf_obj)
  expect_true("location" %in% names(result))
})

test_that("Unnamed list throws an informative error", {
  locs <- list(c(x = 117.87, y = -32.33))
  expect_error(.create_sf(locs), "named list")
})

test_that("Data.frame missing required columns throws an informative error", {
  df <- data.frame(lon = c(117.87), lat = c(-32.33))
  expect_error(.create_sf(df), "location")
})

test_that("Unsupported input type throws an informative error", {
  expect_error(.create_sf(matrix(1:4, 2L, 2L)))
})
