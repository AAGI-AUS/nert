# Offline tests for the convenience wrappers around read_tern().
# These cover the alias-table contract used by every wrapper, without
# touching the network or requiring a TERN API key.

test_that(".tern_dispatch_id resolves every documented alias", {
  aliases <- c(
    "SMIPS",
    "ASC",
    "AET",
    "AWC",
    "CLY",
    "SND",
    "SLT",
    "BDW",
    "PHC",
    "PHW",
    "NTO",
    "SOILDIV",
    "CANOPY",
    "PHENOLOGY"
  )
  for (a in aliases) {
    out <- .tern_dispatch_id(a)
    expect_type(out, "character")
    expect_true(nzchar(out))
  }
})

test_that(".tern_dispatch_id is case-insensitive on aliases", {
  expect_identical(.tern_dispatch_id("smips"), .tern_dispatch_id("SMIPS"))
  expect_identical(.tern_dispatch_id("AwC"), .tern_dispatch_id("AWC"))
})

test_that(".tern_dispatch_id is consistent with the .tern_aliases table", {
  # Every key in .tern_aliases must round-trip via dispatcher
  ks <- names(nert:::.tern_aliases)
  for (k in ks) {
    expect_identical(
      .tern_dispatch_id(k),
      nert:::.tern_aliases[[k]]
    )
  }
})

test_that("read_tern errors informatively for an unsupported alias", {
  err <- tryCatch(
    read_tern("TERN/unknown999"),
    error = function(e) conditionMessage(e)
  )
  # Error message must mention the package's supported aliases
  expect_match(err, "SMIPS", fixed = TRUE)
})
