


.make_smips_url <- function(.collection, .day) {
  url_date <- gsub("-", "", .day)

  approved_collections <- c("totalbucket",
                            "SMindex",
                            "bucket1",
                            "bucket2",
                            "deepD",
                            "runnoff")
  collection <- rlang::arg_match(.collection, approved_collections)

  .check_collection_agreement(.collection = .collection, .day = .day)

  collection_url <- data.table::fcase(
    collection == "totalbucket",
    paste0("smips_totalbucket_mm_", url_date, ".tif"),
    collection == "SMindex",
    paste0("smips_smi_perc_", url_date, ".tif"),
    collection == "bucket1",
    paste0("smips_bucket1_mm_", url_date, ".tif"),
    collection == "bucket2",
    paste0("smips_bucket2_mm_", url_date, ".tif"),
    collection == "deepD",
    paste0("smips_deepD_mm_", url_date, ".tif"),
    collection == "runoff",
    paste0("smips_runoff_mm_", url_date, ".tif")
  )
}


.check_collection_agreement <- function(.collection, .day) {
  .this_year <- lubridate::year(lubridate::today())
  .last_week <- lubridate::today() - 7
  .url_year <- lubridate::year(.day)

  if (.collection == "totalbucket" &&
      .url_year < 2005 ||
      .day > .last_week) {
    cli::cli_abort("The data are not available before 2005 and past {.last_week}")
  }
}
