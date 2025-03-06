test_that("A valid url part is created", {
  date_ <- as.Date("2020-01-01")

  # different collections
  expect_identical(
    .make_smips_url("totalbucket", date_),
    "smips_totalbucket_mm_20200101.tif"
  )
  expect_identical(
    .make_smips_url("SMindex", date_),
    "smips_smi_perc_20200101.tif"
  )
  expect_identical(
    .make_smips_url("bucket1", date_),
    "smips_bucket1_mm_20200101.tif"
  )
  expect_identical(
    .make_smips_url("bucket2", date_),
    "smips_bucket2_mm_20200101.tif"
  )
  expect_identical(
    .make_smips_url("deepD", date_),
    "smips_deepD_mm_20200101.tif"
  )

  # different date
  expect_identical(
    .make_smips_url("runoff", as.Date("2020-01-02")),
    "smips_runoff_mm_20200102.tif"
  )
})

test_that("An invalid collection throws an error", {
  valid_collections <- c(
    "totalbucket",
    "SMindex",
    "bucket1",
    "bucket2",
    "deepD",
    "runoff"
  )
  valid_collections_str <- paste(
    valid_collections[seq_along(valid_collections) - 1],
    collapse = '", "'
  )
  valid_collections_str <- paste0(
    '"',
    valid_collections_str,
    '", "',
    tail(valid_collections, 1),
    '"'
  )

  # TODO: check error message
  error_msg <- paste0(
    "`.collection` must be one of ",
    valid_collections_str,
    ', not "asdf".'
  )
  expect_error(.make_smips_url("asdf", as.Date("2020-01-01")))
})
