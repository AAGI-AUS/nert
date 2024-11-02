#' Read COGs from TERN
#'
#' Read Cloud Optimised Geotiff (\acronym{COG}) files from \acronym{TERN} in
#'   your active \R session as a \CRANpkg{data.table} object.
#'
#' @note
#' Currently only Soil Moisture Integration and Prediction System
#'   (\acronym{SMIPS}) v1.0 is supported.
#'
#' @inherit read_cog
#'
#' @family COGs
#' @author Adam H. Sparks \email{adamhsparks@@curtin.edu.au}
#' @examplesIf interactive()
#'
#' r <- read_cog_dt(day = "2024-01-01", api_key = "your_api_key")
#'
#' r
#'
#' @return A [data.table::data.table] object
#' @autoglobal
#' @references <https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
#' @export

read_cog_dt <- function(data = "smips",
                        collection = "totalbucket",
                        day,
                        api_key = get_key()) {
  r <- data.table::setDT(terra::as.data.frame(
    read_cog(
      data = data,
      collection = collection,
      day = day,
      api_key = api_key
    ), xy = TRUE
  ))

  data.table::setnames(r, old = c("x", "y"), new = c("lon", "lat"))
  return(r)
}

#' Check User Input Dates for Validity
#'
#' @param x User entered date value
#' @return Validated date string as a `POSIXct` object.
#' @note This was taken from \CRANpkg{nasapower}.
#' @example .check_date(x)
#' @author Adam H. Sparks \email{adamhsparks@@curtin.edu.au}
#' @keywords Internal
#' @autoglobal
#' @noRd
.check_date <- function(x) {
  tryCatch(
    x <- lubridate::parse_date_time(x,
                                    c(
                                      "Ymd",
                                      "dmY",
                                      "mdY",
                                      "BdY",
                                      "Bdy",
                                      "bdY",
                                      "bdy"
                                    ),
                                    tz = Sys.timezone()),
    warning = function(c) {
      stop(call. = FALSE,
           "\n",
           x,
           " is not in a valid date format. Please enter a valid date format.",
           "\n")
    }
  )
  return(x)
}
