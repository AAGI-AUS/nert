test_that("show_datasets() has one complete row per dataset", {
  d <- show_datasets()
  expect_s3_class(d, "data.frame")
  expect_named(d, c("alias", "id", "temporal", "resolution", "description"))
  expect_setequal(d$alias, names(.tern_aliases))
  expect_false(anyNA(d))
  expect_true(all(nzchar(as.matrix(d))))
})

test_that("each listed id reaches the same dataset as its alias", {
  d <- show_datasets()
  for (i in seq_len(nrow(d))) {
    expect_identical(.tern_dispatch_id(d$id[i]), .tern_dispatch_id(d$alias[i]))
  }
})
