#' Collect TERN Data Over Time and Space
#'
#' Extract values from one or more TERN datasets at given location(s) over a
#' given set or range of dates. Returns a `data.table` with one row per
#' date/location, and one column per dataset requested. (Note that static
#' datasets are repeated across all dates for consistency.)
#'
#' @param date_range A `Date` vector or `character` vector of length 2,
#'   `[start_date, end_date]`, indicating the start and end date which
#'   should be used for the TERN dataset retrieval. (If a vector of length
#'   greater than 2 is given, this parameter works exactly as `dates` does.)
#'   Omit if specifying exact dates via the `dates` argument instead.
#' @param dates A `Date` vector or `character` vector, indicating the
#'   exact set of dates for which TERN datasets should be retrieved. Takes
#'   precedence over `date_range` if supplied.
#' @param lon Longitude(s) (WGS84, EPSG:4326).  Numeric scalar or vector
#'   (same length as `lat`).  Omit if using `xy` notation.
#' @param lat Latitude(s) (WGS84, EPSG:4326).  Numeric scalar or vector
#'   (same length as `lon`).  Omit if using `xy` notation.
#' @param xy Optional: a `data.frame`, `data.table`, or `matrix` with
#'   coordinate columns named `lon`/`lat` or `x`/`y`.  Takes precedence
#'   over `lon`/`lat` when supplied.
#' @param datasets A `character` vector of dataset aliases to collect.
#'   (Default=All datasets.) Options: `"SMIPS"`, `"ASC"`, `"AET"`, `"AWC"`,
#'   `"CLY"`, `"SND"`, `"SLT"`, `"BDW"`, `"PHC"`, `"PHW"`, `"NTO"`, `"AVP"`,
#'   `"PTO"`, `"CEC"`, `"ECE"`, `"DUL"`, `"L15"`, `"SOILDIV"`, `"CANOPY"`,
#'   `"PHENOLOGY"`. Use `NULL` (default) or `"all"` to specify retrieval
#'   of all available datasets.
#' @param depth *For SLGA datasets.* A `character` vector containing the
#'   depth interval(s) for the SLGA soil attributes to collect.
#'   (Default=All depths.) Options: `"000_005"`, `"005_015"`, `"015_030"`,
#'   `"030_060"`, `"060_100"`, `"100_200"`. Use `NULL` (default) or `"all"`
#'   to specify retrieval of all available depths. This parameter is ignored
#'   for non-SLGA datasets.
#' @param stat *For SLGA datasets.* A `character` vector containing the
#'   statistic to retrieve for the SLGA datasets. (Default=All statistics.)
#'   Options: `"EV"` (estimated value), `"05"` (lower, 5th-percentile
#'   bound), `"95"` (upper, 95th-percentile bound); the `05` and `95`
#'   layers together span a 90% interval. Use `NULL` (default) or `"all"` to specify
#'   retrieval of all statistics. This parameter is ignored for non-SLGA
#'   datasets.
#' @param smips_collection *For SMIPS datasets.* A `character` vector
#'   containing the SMIPS datasets to be retrieved. (Default=All SMIPS
#'   datasets.) Options: `"totalbucket"`, `"SMindex"`, `"bucket1"`,
#'   `"bucket2"`, `"deepD"`, `"runoff"`. Use `NULL` (default) or `"all"` to
#'   specify retrieval of all SMIPS datasets. This parameter is ignored for
#'   non-SMIPS datasets.
#' @param asc_collection *For ASC datasets.* A `character` vector specifying
#'   the Australian Soil Classification Map datasets to be retrieved.
#'   (Default=All ASC datasets.) Options: `"EV"` (estimated soil order),
#'   `"CI"` (confusion index). Use `NULL` (default) or `"all"` to specify
#'   retrieval of all ASC datasets.
#' @param aet_collection *For AET datasets.* A `character` vector specifying
#'   the Actual Evapotranspiration datasets to be retrieved. (Default=All
#'   AET datasets.) Options: `"ETa"`, `"pixel_qa"` (quality assurance flags).
#'   Use `NULL` (default) or `"all"` to specify retrieval of all AET datasets.
#'   This parameter is ignored for non-AET datasets.
#' @param soildiv_collection *For SOILDIV datasets.* A `character` vector
#'   specifying the beta soil diversity NMDS axes to be retrieved.
#'   (Default=All axes/datasets.) Options: `"Bacteria_NMDS1"`,
#'   `"Bacteria_NMDS2"`, `"Bacteria_NMDS3"`, `"Fungi_NMDS1"`, `"Fungi_NMDS2"`,
#'   `"Fungi_NMDS3"`. Use `NULL` (default) or `"all"` to specify retrieval
#'   of all SOILDIV axes/datasets.
#' @param phenology_collection *For PHENOLOGY datasets.* A `character` vector
#'   specifying the phenology datasets to be retrieved. (Default=All
#'   PHENOLOGY datasets.) Options: `"SGS"`, `"PGS"`, `"EGS"`, `"LGS"`,
#'   `"EVI1"`, `"EVI2"`, `"EVIP"`, `"EVII"`, `"SGS_month"`, `"PGS_month"`,
#'   `"EGS_month"`. Use `NULL` (default) or `"all"` to specify retrieval of
#'   all PHENOLOGY datasets.
#' @param api_key A `character` string containing your \acronym{TERN}
#'   \acronym{API} key. Defaults to automatic detection from your
#'   `.Renviron` or `.Rprofile`.  See [get_key()] for setup.
#' @param max_tries Maximum number of download retries before an error is
#'   raised. Default=`NULL`, in which case the maximum retry number is
#'   resolved from the option `nert.max_tries` if that option exists.
#'   (Defaults to 3 retries if `nert.max_tries` has not been set.)
#' @param initial_delay Initial retry delay in seconds (doubles with each
#'   attempt). Default=`NULL`, in which case the initial delay is
#'   resolved from the option `nert.initial_delay` if that option exists.
#'   (Defaults to a 1 second initial delay if `nert.initial_delay` has
#'   not been set.)
#' @param verbose Logical.  If `TRUE`, print progress messages. (Default=TRUE.)
#' @param na.rm Logical.  If `TRUE`, drop rows where all dataset columns
#'   are `NA`. (Default=FALSE).
#'
#' @returns
#' A `data.table` with the following columns:
#' - `date`: `Date`.
#' - `lon`, `lat`: spatial coordinates (always included; constant when a single
#'   location is requested).
#' - One column per dataset requested. These dataset columns are named
#'   with their alias as the prefix (e.g., `SMIPS`, `AWC`, `SOILDIV`),
#'   followed by any variant information (e.g., depth, statistic, dataset
#'   name) after an underscore. For example, `SMIPS_totalbucket` for
#'   the SMIPS "totalbucket" dataset, `CLY_05_000_005` for the lower (05)
#'   percentile limit of the soil clay at 0-5cm depth, and so on.
#'
#' @details
#' **Failure handling.** Note that if a COG fetch fails (i.e., no
#' successful download after `max_tries`), the corresponding column(s)
#' will be set as `NA` for the affected rows, and a `cli::cli_warn()`
#' warning is emitted.
#'
#' @examplesIf interactive()
#' # Single location, single dataset
#' dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-05"), by = "day")
#' d_t <- collect_tern_data(
#'   date_range = dates,
#'   lon = 138.6,
#'   lat = -34.9,
#'   datasets = c("SMIPS", "CLY")
#' )
#' head(d_t)
#'
#' # Multiple locations (vectorised across points within each COG)
#' d_t_multi <- collect_tern_data(
#'   lon = c(138.6, 139.5),
#'   lat = c(-34.9, -35.5),
#'   date_range = dates,
#'   datasets = c("SMIPS", "CANOPY")
#' )
#'
#' # xy data.frame notation
#' xy <- data.frame(lon = c(138.6, 139.5), lat = c(-34.9, -35.5))
#' d_t_xy <- collect_tern_data(
#'   xy = xy,
#'   date_range = dates,
#'   datasets = "CLY"
#' )
#'
#'
#' @export
collect_tern_data <- function(
  date_range,
  dates,
  lon = NULL,
  lat = NULL,
  xy = NULL,
  datasets = NULL,
  depth = NULL,
  stat = NULL,
  smips_collection = NULL,
  asc_collection = NULL,
  aet_collection = NULL,
  soildiv_collection = NULL,
  phenology_collection = NULL,
  api_key = NULL,
  max_tries = NULL,
  initial_delay = NULL,
  verbose = TRUE,
  na.rm = FALSE
) {
  if (missing(dates) && missing(date_range)) {
    cli::cli_abort(
      "At least one of {.arg dates} or {.arg date_range} must be supplied."
    )
  }

  # The dates argument takes precedence over date_range if both supplied
  if (missing(dates)) {
    dates <- .parse_date_range(date_range)
  } else {
    dates <- as.Date(dates)
  }
  n_dt <- length(dates)

  coords_df <- .parse_coordinates(lon, lat, xy)
  n_loc <- nrow(coords_df)
  pts <- terra::vect(
    as.matrix(coords_df[, c("lon", "lat")]),
    type = "points",
    crs = "EPSG:4326"
  )

  # Normalise user-supplied datasets and dataset collections
  datasets <- .normalise_datasets(datasets)
  depth <- .normalise_depth(depth)
  stat <- .normalise_stat(stat)
  smips_collection <- .normalise_smips_collection(smips_collection)
  asc_collection <- .normalise_asc_collection(asc_collection)
  aet_collection <- .normalise_aet_collection(aet_collection)
  soildiv_collection <- .normalise_soildiv_collection(soildiv_collection)
  phenology_collection <- .normalise_phen_collection(phenology_collection)

  if (verbose) {
    .print_datasets_table(
      datasets,
      depth,
      stat,
      smips_collection,
      asc_collection,
      aet_collection,
      soildiv_collection,
      phenology_collection
    )
    cli::cli_inform(
      "Collecting {length(datasets)} dataset{?s} at {n_loc} \\
       location{?s} over {n_dt} date{?s}"
    )
  }

  work_items <- .build_work_items(
    datasets,
    dates,
    depth,
    stat,
    smips_collection,
    asc_collection,
    aet_collection,
    soildiv_collection,
    phenology_collection
  )

  out <- data.table::data.table(
    date = rep(dates, each = n_loc),
    lon = rep(coords_df$lon, times = n_dt),
    lat = rep(coords_df$lat, times = n_dt)
  )

  for (wi in work_items) {
    for (col in wi$cols) {
      out[,
        (col) := if (identical(wi$type, "character")) {
          NA_character_
        } else {
          NA_real_
        }
      ]
    }
  }

  for (wi in work_items) {
    if (verbose) {
      cli::cli_inform("  {.field {wi$label}}")
    }
    .fill_work_item(
      out,
      wi,
      pts,
      n_dt,
      n_loc,
      api_key,
      max_tries,
      initial_delay
    )
  }

  data_cols <- setdiff(names(out), c("date", "lon", "lat"))

  if (na.rm && length(data_cols) > 0L) {
    keep <- vapply(
      seq_len(nrow(out)),
      function(i) {
        !all(is.na(unlist(out[i, data_cols, with = FALSE])))
      },
      logical(1L)
    )
    out <- out[keep]
  }

  if (verbose) {
    cli::cli_inform("Collected {nrow(out)} row{?s} x {ncol(out)} column{?s}")
  }

  return(out[])
}


#' Normalise coordinate input
#'
#' @param lon Longitude(s).
#' @param lat Latitude(s).
#' @param xy Optional data.frame/matrix with lon/lat or x/y columns.
#' @returns A 2-column `data.table` with columns `lon`, `lat`.
#'
#' @dev
.parse_coordinates <- function(lon, lat, xy) {
  if (!is.null(xy)) {
    if (is.matrix(xy)) {
      xy <- as.data.frame(xy)
    }
    if (!is.data.frame(xy) && !data.table::is.data.table(xy)) {
      cli::cli_abort(
        "{.arg xy} must be a {.cls data.frame}, {.cls data.table}, \\
         or {.cls matrix}."
      )
    }
    if (all(c("lon", "lat") %in% names(xy))) {
      coords <- data.table::data.table(lon = xy[["lon"]], lat = xy[["lat"]])
    } else if (all(c("x", "y") %in% names(xy))) {
      coords <- data.table::data.table(lon = xy[["x"]], lat = xy[["y"]])
    } else {
      cli::cli_abort(
        "{.arg xy} must have columns {.val lon}/{.val lat} or \\
         {.val x}/{.val y}."
      )
    }
  } else if (!is.null(lon) && !is.null(lat)) {
    if (length(lon) != length(lat)) {
      cli::cli_abort("{.arg lon} and {.arg lat} must have equal length.")
    }
    coords <- data.table::data.table(lon = lon, lat = lat)
  } else {
    cli::cli_abort(
      "You must provide either {.arg lon}/{.arg lat} or {.arg xy}."
    )
  }

  if (!is.numeric(coords$lon) || !is.numeric(coords$lat)) {
    cli::cli_abort("Coordinates must be numeric.")
  }
  if (any(is.na(coords$lon) | is.na(coords$lat))) {
    cli::cli_abort("Coordinates must not be {.code NA}.")
  }

  # Based on measured spatial extent for available TERN dataset rasters
  # Last measured: 28/06/2026.
  if (
    any(
      coords$lon < 90 | coords$lon > 180 | coords$lat < -51 | coords$lat > -8
    )
  ) {
    cli::cli_abort(
      "Coordinate out of bounds: for TERN rasters, lon in [90, 180], lat in [-51, -8]."
    )
  }
  return(coords)
}


#' Normalise a date_range argument
#'
#' If a `Date` vector or `character` vector of length 2 is given, parses
#' into a contiguous range of dates. If a vector of length greater than 2
#' is given, this function does nothing (besides the date conversion).
#'
#' @param date_range A `Date` vector or `character` vector containing the
#'   date range supplied by the user.
#' @returns A `Date` vector.
#'
#' @dev
.parse_date_range <- function(date_range) {
  if (!inherits(date_range, "character") && !inherits(date_range, "Date")) {
    return(
      cli::cli_abort(
        "{.arg date_range} must be a {.cls Date} or {.cls character} vector."
      )
    )
  }
  if (length(date_range) == 0 || anyNA(date_range)) {
    return(cli::cli_abort("{.arg date_range} must contain valid dates."))
  }

  if (length(date_range) == 2) {
    start <- as.Date(date_range[1])
    end <- as.Date(date_range[2])
    if (start > end) {
      cli::cli_abort(
        "{.arg date_range} start {.val {start}} must not be after its end \\
         {.val {end}}."
      )
    }
    dates <- seq(start, end, by = "day")
  } else {
    dates <- as.Date(date_range)
  }
  return(dates)
}


#' Helper function: resolve the given `character` vector to its valid elements
#'
#' @param vec A `character` vector (of user-supplied elements, e.g., dataset
#'   names, variants), or `NULL`/`"all"`.
#' @param valid_elements A `character` vector containing the valid
#'   elements against which the `given_vec` vector should be compared.
#' @param info A `character` string that describes the elements
#'   in `given_vec` (so that errors/warnings are more informative).
#' @returns A `character` vector of valid elements (de-duplicated,
#'   order preserved).
#' @dev
.normalise_vector_elements <- function(vec, valid_elements, info) {
  if (is.null(vec) || (length(vec) == 1 && identical(vec, "all"))) {
    return(valid_elements)
  }

  vec <- unique(trimws(as.character(vec)))
  if (length(vec) == 0) {
    cli::cli_abort("No {info} specified.")
  }
  invalid_elements <- setdiff(vec, valid_elements)
  if (length(invalid_elements) > 0) {
    cli::cli_warn(
      c(
        "!" = "Invalid {info} ignored: {.val {invalid_elements}}.",
        "i" = "Valid {info}: {.val {valid_elements}}."
      )
    )
    vec <- intersect(vec, valid_elements)
  }
  if (length(vec) == 0) {
    cli::cli_abort("No valid {info} remained after filtering.")
  }
  return(vec)
}


#' Resolve the `datasets` argument to a clean alias vector
#'
#' @param datasets User-supplied aliases (or `NULL`/`"all"`).
#' @returns A `character` vector of recognised aliases (de-duplicated,
#'   order preserved).
#' @dev
.normalise_datasets <- function(datasets) {
  all_aliases <- c(
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
    "AVP",
    "PTO",
    "CEC",
    "ECE",
    "DUL",
    "L15",
    "SOILDIV",
    "CANOPY",
    "PHENOLOGY"
  )
  info <- "dataset aliases"
  return(.normalise_vector_elements(datasets, all_aliases, info))
}


#' Resolve the 'depth' argument to a clean vector
#'
#' @param depth User-supplied soil depths (or `NULL`/`"all"`).
#' @returns A `character` vector of valid soil depths (de-duplicated,
#'   order preserved).
#' @dev
.normalise_depth <- function(depth) {
  valid_depths <- c(
    "000_005",
    "005_015",
    "015_030",
    "030_060",
    "060_100",
    "100_200"
  )
  info <- "SLGA soil depths"
  return(.normalise_vector_elements(depth, valid_depths, info))
}


#' Resolve the 'stat' argument to a clean vector
#'
#' @param stat User-supplied statistics for SLGA datasets (or `NULL`/`"all"`).
#' @returns A `character` vector of valid statistics (de-duplicated, order
#'   preserved).
#' @dev
.normalise_stat <- function(stat) {
  valid_stats <- c("EV", "05", "95")
  info <- "SLGA statistics"
  return(.normalise_vector_elements(stat, valid_stats, info))
}


#' Resolve the 'smips_collection' argument to a clean vector
#'
#' @param smips_collection User-supplied vector of SMIPS datasets to
#'   collect (or `NULL`/`"all"`).
#' @returns A `character` vector of valid SMIPS datasets (de-duplicated,
#'   order preserved).
#' @dev
.normalise_smips_collection <- function(smips_collection) {
  valid_smips <- c(
    "totalbucket",
    "SMindex",
    "bucket1",
    "bucket2",
    "deepD",
    "runoff"
  )
  info <- "SMIPS datasets"
  return(.normalise_vector_elements(smips_collection, valid_smips, info))
}


#' Resolve the 'asc_collection' argument to a clean vector
#'
#' @param asc_collection User-supplied vector of ASC datasets to collect
#'   (or `NULL`/`"all"`).
#' @returns A `character` vector of valid ASC datasets (de-duplicated,
#'   order preserved).
#' @dev
.normalise_asc_collection <- function(asc_collection) {
  valid_asc <- c("EV", "CI")
  info <- "ASC datasets"
  return(.normalise_vector_elements(asc_collection, valid_asc, info))
}


#' Resolve the 'aet_collection' argument to a clean vector
#'
#' @param aet_collection User-supplied vector of AET datasets to
#'   collect (or `NULL`/`"all"`).
#' @returns A `character` vector of valid AET datasets (de-duplicated,
#'   order preserved).
#' @dev
.normalise_aet_collection <- function(aet_collection) {
  valid_aet <- c("ETa", "pixel_qa")
  info <- "AET datasets"
  return(.normalise_vector_elements(aet_collection, valid_aet, info))
}


#' Resolve the 'soildiv_collection' argument to a clean vector
#'
#' @param soildiv_collection User-supplied vector of SOILDIV datasets
#'   to collect (or `NULL`/`"all"`).
#' @returns A `character` vector of valid SOILDIV datasets (de-duplicated,
#'   order preserved).
#' @dev
.normalise_soildiv_collection <- function(soildiv_collection) {
  valid_soildiv <- c(
    "Bacteria_NMDS1",
    "Bacteria_NMDS2",
    "Bacteria_NMDS3",
    "Fungi_NMDS1",
    "Fungi_NMDS2",
    "Fungi_NMDS3"
  )
  info <- "SOILDIV datasets"
  return(.normalise_vector_elements(soildiv_collection, valid_soildiv, info))
}


#' Resolve the 'phenology_collection' argument to a clean vector
#'
#' @param phenology_collection User-supplied vector of PHENOLOGY datasets
#'   to collect (or `NULL`/`"all"`).
#' @returns A `character` vector of valid PHENOLOGY datasets (de-duplicated,
#'   order preserved).
#' @dev
.normalise_phen_collection <- function(phenology_collection) {
  valid_phenology <- c(
    "SGS",
    "PGS",
    "EGS",
    "LGS",
    "EVI1",
    "EVI2",
    "EVIP",
    "EVII",
    "SGS_month",
    "PGS_month",
    "EGS_month"
  )
  info <- "PHENOLOGY datasets"
  return(
    .normalise_vector_elements(phenology_collection, valid_phenology, info)
  )
}


#' Plan the list of COG fetches
#'
#' A *work item* is one COG-shaped request: a tuple of
#' `(dataset, date_idx, variant, depth)`.  Each item maps to exactly one
#' `read_tern()` + `terra::extract()` round-trip and produces one or more
#' columns in the output table.
#'
#' For time-series datasets (SMIPS, AET) we emit one work item per
#' (date, variant); for PHENOLOGY datasets we emit two work items per
#' (date, variant), one for each season; for SLGA datasets we emit one work
#' item per (depth, variant) combination. For temporally-static datasets,
#' the item values are replicated across the date axis (`date_idx = NA_integer_`).
#'
#' @param datasets Normalised alias vector.
#' @param dates Resolved `Date` vector.
#' @param depth SLGA depth selector.
#' @param stat SLGA stat selector.
#' @param smips_collection SMIPS collection selector.
#' @param asc_collection ASC collection selector.
#' @param aet_collection AET collection selector.
#' @param soildiv_collection SOILDIV collection selector.
#' @param phenology_collection PHENOLOGY collection selector.
#' @returns A list of work-item lists.
#'
#' @dev
#'
.build_work_items <- function(
  datasets,
  dates,
  depth,
  stat,
  smips_collection,
  asc_collection,
  aet_collection,
  soildiv_collection,
  phenology_collection
) {
  slga_aliases <- c(
    "AWC",
    "CLY",
    "SND",
    "SLT",
    "BDW",
    "PHC",
    "PHW",
    "NTO",
    "AVP",
    "PTO",
    "CEC",
    "ECE",
    "DUL",
    "L15"
  )

  items <- list()
  for (ds in datasets) {
    if (ds == "SMIPS") {
      for (v in smips_collection) {
        for (i in seq_along(dates)) {
          items[[length(items) + 1]] <- list(
            ds = ds,
            type = "numeric",
            cols = paste(ds, v, sep = "_"),
            date_idx = i,
            args = list(date = dates[i], collection = v),
            label = sprintf("%s %s %s", ds, v, format(dates[i], "%Y-%m-%d"))
          )
        }
      }
    } else if (ds == "ASC") {
      for (v in asc_collection) {
        items[[length(items) + 1]] <- list(
          ds = ds,
          type = ifelse(v == "EV", "character", "numeric"),
          cols = paste(ds, v, sep = "_"),
          date_idx = NA_integer_,
          args = list(collection = v),
          label = sprintf("%s %s (static)", ds, v)
        )
      }
    } else if (ds == "AET") {
      for (v in aet_collection) {
        for (i in seq_along(dates)) {
          items[[length(items) + 1]] <- list(
            ds = ds,
            type = "numeric",
            cols = paste(ds, v, sep = "_"),
            date_idx = i,
            args = list(date = dates[i], collection = v),
            label = sprintf("%s %s %s", ds, v, format(dates[i], "%Y-%m-%d"))
          )
        }
      }
    } else if (ds %in% slga_aliases) {
      for (v in stat) {
        for (d in depth) {
          items[[length(items) + 1]] <- list(
            ds = ds,
            type = "numeric",
            cols = paste(ds, v, d, sep = "_"),
            date_idx = NA_integer_,
            args = list(depth = d, collection = v),
            label = sprintf("%s stat=%s depth=%s (static)", ds, v, d)
          )
        }
      }
    } else if (ds == "SOILDIV") {
      for (v in soildiv_collection) {
        # Split collection into bacteria/fungi and axis
        v_split <- regmatches(v, regexec("(\\w+)_NMDS(\\d+)", v))[[1]]
        v_col <- v_split[2]
        v_axis <- v_split[3]

        items[[length(items) + 1]] <- list(
          ds = ds,
          type = "numeric",
          cols = paste(ds, v, sep = "_"),
          date_idx = NA_integer_,
          args = list(collection = v_col, axis = v_axis),
          label = sprintf("%s %s (static)", ds, v)
        )
      }
    } else if (ds == "PHENOLOGY") {
      for (v in phenology_collection) {
        # Temporally snap to the nearest phenology dataset, and grab
        # both seasons
        phen_year <- as.integer(format(dates[1], "%Y"))
        phen_year <- max(2003, min(2018, phen_year))
        for (phen_season in 1:2) {
          items[[length(items) + 1]] <- list(
            ds = ds,
            type = "numeric",
            cols = paste0(ds, "_", v, "_y", phen_year, "_s", phen_season),
            date_idx = NA_integer_,
            args = list(collection = v, year = phen_year, season = phen_season),
            label = sprintf(
              "PHENOLOGY %s year=%s season=%s",
              v,
              as.character(phen_year),
              as.character(phen_season)
            )
          )
        }
      }
    } else {
      # Catch-all for datasets without variants/args (e.g., CANOPY)
      items[[length(items) + 1]] <- list(
        ds = ds,
        type = "numeric",
        cols = ds,
        date_idx = NA_integer_,
        args = list(),
        label = sprintf("%s (static)", ds)
      )
    }
  }
  return(items)
}


#' Fetch one work item and write its values into the output table by reference.
#'
#' For a time-series work item, exactly one row block (`length(coords)`
#' rows) is filled.  For a static work item, the value is replicated
#' across every date.  Failures leave the predeclared `NA` values
#' untouched and surface as a `cli::cli_warn()` with the underlying error.
#'
#' @param out The output `data.table` (modified in place).
#' @param wi A work item from [.build_work_items()].
#' @param pts A `SpatVector` of points.
#' @param n_dt Number of dates.
#' @param n_loc Number of locations.
#' @param api_key TERN API key.
#' @param max_tries Total number of download retries.
#' @param initial_delay Initial retry delay (in seconds).
#' @dev
.fill_work_item <- function(
  out,
  wi,
  pts,
  n_dt,
  n_loc,
  api_key,
  max_tries,
  initial_delay
) {
  r <- tryCatch(
    suppressWarnings(
      do.call(
        read_tern,
        c(
          list(wi$ds),
          wi$args,
          list(
            api_key = api_key,
            max_tries = max_tries,
            initial_delay = initial_delay
          )
        )
      )
    ),
    error = function(e) {
      cli::cli_warn(
        "Failed to fetch {.field {wi$label}}; column(s) \\
         {.val {wi$cols}} left as {.code NA}.",
        parent = e
      )
      NULL
    }
  )
  if (is.null(r)) {
    return(invisible(NULL))
  }

  ext <- tryCatch(
    suppressWarnings(terra::extract(r, pts)),
    error = function(e) {
      cli::cli_warn(
        "Failed to extract {.field {wi$label}} at requested points.",
        parent = e
      )
      NULL
    }
  )
  if (is.null(ext) || !is.data.frame(ext) || ncol(ext) < 2L) {
    return(invisible(NULL))
  }

  vals <- ext[, -1L, drop = FALSE]
  v <- vals[[1L]]
  if (length(v) != n_loc) {
    cli::cli_warn(
      "Layer length mismatch for {.field {wi$label}}: expected {n_loc} \\
       values, got {length(v)}.  Column(s) left as {.code NA}."
    )
    return(invisible(NULL))
  }
  if (identical(wi$type, "character")) {
    v <- as.character(v)
  } else {
    v <- as.numeric(v)
  }

  if (is.na(wi$date_idx)) {
    out[, (wi$cols[1L]) := rep(v, times = n_dt)]
  } else {
    row_start <- (wi$date_idx - 1L) * n_loc + 1L
    row_end <- wi$date_idx * n_loc
    out[seq.int(row_start, row_end), (wi$cols[1L]) := v]
  }

  return(invisible(NULL))
}


#' Print the user-facing datasets-table summarising what will be fetched.
#'
#' @param datasets Normalised alias vector.
#' @param depth Normalised SLGA depth selector.
#' @param stat Normalised SLGA statistic selector.
#' @param smips_collection Normalised SMIPS collection selector.
#' @param asc_collection Normalised ASC collection selector.
#' @param aet_collection Normalised AET collection selector.
#' @param soildiv_collection Normalised SOILDIV collection selector.
#' @param phenology_collection Normalised PHENOLOGY collection selector.
#' @returns `invisible(NULL)`. This function is called for its side effects.
#' @dev
.print_datasets_table <- function(
  datasets,
  depth,
  stat,
  smips_collection,
  asc_collection,
  aet_collection,
  soildiv_collection,
  phenology_collection
) {
  dataset_info <- list(
    SMIPS = list(
      id = "TERN/d1995ee8",
      temporal = "Daily",
      resolution = "1 km",
      description = "Soil Moisture Integration & Prediction System"
    ),
    ASC = list(
      id = "TERN/15728dba",
      temporal = "Static",
      resolution = "90 m",
      description = "Australian Soil Classification (soil order)"
    ),
    AET = list(
      id = "TERN/9fefa68b",
      temporal = "Monthly",
      resolution = "30 m",
      description = "Actual Evapotranspiration via CMRSET"
    ),
    AWC = list(
      id = "TERN/482301c2",
      temporal = "Static",
      resolution = "90 m",
      description = "Available Water Capacity % (SLGA)"
    ),
    CLY = list(
      id = "TERN/f95dc442",
      temporal = "Static",
      resolution = "90 m",
      description = "Clay content % (SLGA)"
    ),
    SND = list(
      id = "TERN/4224ddff",
      temporal = "Static",
      resolution = "90 m",
      description = "Sand content % (SLGA)"
    ),
    SLT = list(
      id = "TERN/11375f04",
      temporal = "Static",
      resolution = "90 m",
      description = "Silt content % (SLGA)"
    ),
    BDW = list(
      id = "TERN/95978aec",
      temporal = "Static",
      resolution = "90 m",
      description = "Bulk Density whole earth (g/cm3) (SLGA)"
    ),
    PHC = list(
      id = "TERN/258afc98",
      temporal = "Static",
      resolution = "90 m",
      description = "pH (CaCl2) (SLGA)"
    ),
    PHW = list(
      id = "TERN/c37439a5",
      temporal = "Static",
      resolution = "90 m",
      description = "pH (water) (SLGA)"
    ),
    NTO = list(
      id = "TERN/e9484508",
      temporal = "Static",
      resolution = "90 m",
      description = "Total Nitrogen % (SLGA)"
    ),
    AVP = list(
      id = "TERN/c6ef289b",
      temporal = "Static",
      resolution = "90 m",
      description = "Available Phosphorus (mg/kg) (SLGA)"
    ),
    PTO = list(
      id = "TERN/be382e63",
      temporal = "Static",
      resolution = "90 m",
      description = "Total Phosphorus % (SLGA)"
    ),
    CEC = list(
      id = "TERN/5b4b2991",
      temporal = "Static",
      resolution = "90 m",
      description = "Cation Exchange Capacity (meq/100g) (SLGA)"
    ),
    ECE = list(
      id = "TERN/0d27cf8b",
      temporal = "Static",
      resolution = "90 m",
      description = "Effective Cation Exchange Capacity (meq/100g) (SLGA)"
    ),
    DUL = list(
      id = "TERN/de9ddc12",
      temporal = "Static",
      resolution = "90 m",
      description = "Drained upper limit water content % (SLGA)"
    ),
    L15 = list(
      id = "TERN/4443f5df",
      temporal = "Static",
      resolution = "90 m",
      description = "15 bar lower limit water content % (SLGA)"
    ),
    SOILDIV = list(
      id = "TERN/4a428d52",
      temporal = "Static",
      resolution = "90 m",
      description = "Soil Beta Diversity (NMDS components)"
    ),
    CANOPY = list(
      id = "TERN/36c98155",
      temporal = "Static",
      resolution = "30 m",
      description = "Canopy Height best-pick composite (OzTreeMap)"
    ),
    PHENOLOGY = list(
      id = "TERN/2bb0c81a",
      temporal = "Annual",
      resolution = "500 m",
      description = "Land Surface Phenology"
    )
  )

  layers_info <- vapply(
    datasets,
    function(ds) {
      layer <- "Single layer" # Catch-all case

      slga_datasets <- c(
        "AWC",
        "CLY",
        "SND",
        "SLT",
        "BDW",
        "PHC",
        "PHW",
        "NTO",
        "AVP",
        "PTO",
        "CEC",
        "ECE",
        "DUL",
        "L15"
      )
      if (ds %in% slga_datasets) {
        layer <- paste(
          paste0("Statistic: ", paste(stat, collapse = ", ")),
          paste0("Depth: ", paste(depth, collapse = ", ")),
          sep = " | "
        )
      } else if (ds == "SMIPS") {
        layer <- paste0(
          "Collection: ",
          paste(smips_collection, collapse = ", ")
        )
      } else if (ds == "ASC") {
        layer <- paste0("Collection: ", paste(asc_collection, collapse = ", "))
      } else if (ds == "AET") {
        layer <- paste0("Collection: ", paste(aet_collection, collapse = ", "))
      } else if (ds == "SOILDIV") {
        layer <- paste0(
          "Collection: ",
          paste(soildiv_collection, collapse = ", ")
        )
      } else if (ds == "PHENOLOGY") {
        layer <- paste0(
          "Collection: ",
          paste(phenology_collection, collapse = ", ")
        )
      } else if (ds == "CANOPY") {
        layer <- "Collection: Best-pick Canopy Height"
      }
      return(layer)
    },
    character(1L)
  )

  tbl <- data.table::data.table(
    Alias = datasets,
    ID = vapply(
      datasets,
      function(x) {
        return(dataset_info[[x]]$id)
      },
      character(1L)
    ),
    Layer = layers_info,
    Temporal = vapply(
      datasets,
      function(x) {
        return(dataset_info[[x]]$temporal)
      },
      character(1L)
    ),
    Resolution = vapply(
      datasets,
      function(x) {
        return(dataset_info[[x]]$resolution)
      },
      character(1L)
    ),
    Description = vapply(
      datasets,
      function(x) {
        return(dataset_info[[x]]$description)
      },
      character(1L)
    )
  )

  cat("\n")
  cli::cli_rule("Datasets to Collect")
  print(tbl, nrows = Inf)
  cat("\n")

  return(invisible(NULL))
}
