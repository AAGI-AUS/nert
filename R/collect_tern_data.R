#' Collect TERN Data Over Time and Space
#'
#' Extract values from one or more TERN datasets at given location(s) over a
#' date range. Returns a `data.table` with one row per (date, location) and
#' one column per dataset layer.  Static datasets are repeated across all
#' dates.
#'
#' @param date_range A `Date` vector or character vector of dates
#'   (e.g.\ `seq(as.Date("2024-01-01"), as.Date("2024-01-31"), by = "day")`)
#'   OR a length-2 vector giving start and end dates
#'   (e.g.\ `c("2024-01-01", "2024-01-31")`).
#' @param lon Longitude(s) (WGS84, EPSG:4326).  Numeric scalar or vector
#'   (same length as `lat`).  Omit if using `xy` notation.
#' @param lat Latitude(s) (WGS84, EPSG:4326).  Numeric scalar or vector
#'   (same length as `lon`).  Omit if using `xy` notation.
#' @param xy Optional: a `data.frame`, `data.table`, or `matrix` with
#'   coordinate columns named `lon`/`lat` or `x`/`y`.  Takes precedence
#'   over `lon`/`lat` when supplied.
#' @param datasets `character` vector of dataset aliases to collect.
#'   Default: all 14 datasets (SMIPS, ASC, AET, AWC, CLY, SND, SLT, BDW,
#'   PHC, PHW, NTO, SOILDIV, CANOPY, PHENOLOGY).  Use `NULL` or `"all"`
#'   for all datasets.
#' @param depth For SLGA datasets: depth interval (default `"all"`).
#'   Options: `"000_005"`, `"005_015"`, `"015_030"`, `"030_060"`,
#'   `"060_100"`, `"100_200"`, or `"all"` for all six GlobalSoilMap depths.
#'   Ignored for non-SLGA datasets.
#' @param stat For SLGA datasets: `"EV"` (estimate, default) or `"CI"`
#'   (confidence interval).  Ignored for non-SLGA datasets.
#' @param smips_collection For SMIPS: `"all"` (default, all six variants),
#'   `"totalbucket"`, `"SMindex"`, `"bucket1"`, `"bucket2"`, `"deepD"`,
#'   or `"runoff"`.  Ignored for non-SMIPS datasets.
#' @param api_key TERN API key.  Default: `get_key()`.
#' @param verbose Logical.  If `TRUE`, print progress messages.
#' @param na.rm Logical.  If `TRUE`, drop rows where all dataset columns
#'   are `NA`.
#'
#' @returns
#' A `data.table` with columns:
#' - `date`: `Date`.
#' - `lon`, `lat`: coordinates (always included; constant when a single
#'   location is requested).
#' - One column per dataset layer.  See **Details** for naming.
#'
#' @details
#' **Vectorised extraction.**  For each unique COG required (a
#' (dataset, date, variant, depth) tuple), the function opens the COG
#' **once** and calls [terra::extract()] **once** with all requested
#' coordinates as a single `SpatVector`.  Returning M locations × N dates
#' across K work items therefore costs K COG opens and K extract calls,
#' not M × K.  Time-series datasets contribute one work item per date;
#' static datasets contribute one work item total (the value is replicated
#' across the date axis at output assembly time).
#'
#' **Column naming.**
#' - SMIPS with `smips_collection = "all"`: six columns named
#'   `SMIPS_totalbucket`, `SMIPS_SMindex`, `SMIPS_bucket1`, `SMIPS_bucket2`,
#'   `SMIPS_deepD`, `SMIPS_runoff`.
#' - SMIPS with a single collection: one column `SMIPS_<collection>`.
#' - SLGA with `depth = "all"`: six columns per dataset (e.g.\
#'   `AWC_000_005` ... `AWC_100_200`).
#' - SLGA with a single depth: one column named for the dataset alias.
#' - AET: one column `AET`.
#' - ASC: one column `ASC` (character soil-order class).
#' - CANOPY, SOILDIV, PHENOLOGY: one column each named for the alias.
#'
#' **Failure handling.**  If a work item's COG fetch or extract fails, the
#' corresponding column(s) remain `NA` for the affected rows and a
#' `cli::cli_warn()` identifies the dataset/date/error.  The output schema
#' (column count and names) is fixed at planning time and is invariant
#' under per-COG failure.
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
#' @autoglobal
#' @export
collect_tern_data <- function(
  date_range,
  lon = NULL,
  lat = NULL,
  xy = NULL,
  datasets = NULL,
  depth = "all",
  stat = "EV",
  smips_collection = "all",
  api_key = NULL,
  verbose = TRUE,
  na.rm = FALSE
) {
  coords_df <- .parse_coordinates(lon, lat, xy)
  n_loc     <- nrow(coords_df)

  dates <- .parse_date_range(date_range)
  n_dt  <- length(dates)

  datasets <- .normalise_datasets(datasets)

  if (verbose) {
    .print_datasets_table(datasets, depth, smips_collection, stat)
    cli::cli_inform(
      "Collecting {length(datasets)} dataset{?s} at {n_loc} \\
       location{?s} over {n_dt} date{?s}"
    )
  }

  pts <- terra::vect(
    as.matrix(coords_df[, c("lon", "lat")]),
    type = "points",
    crs  = "EPSG:4326"
  )

  work_items <- .build_work_items(
    datasets, dates, depth, stat, smips_collection
  )

  n_rows <- n_dt * n_loc
  out    <- data.table::data.table(
    date = rep(dates, each = n_loc),
    lon  = rep(coords_df$lon, times = n_dt),
    lat  = rep(coords_df$lat, times = n_dt)
  )

  for (wi in work_items) {
    for (col in wi$cols) {
      out[, (col) := if (identical(wi$type, "character")) {
        NA_character_
      } else {
        NA_real_
      }]
    }
  }

  for (wi in work_items) {
    if (verbose) {
      cli::cli_inform("  {.field {wi$label}}")
    }
    .fill_work_item(out, wi, pts, n_dt, n_loc, api_key)
  }

  data_cols <- setdiff(names(out), c("date", "lon", "lat"))

  if (na.rm && length(data_cols) > 0L) {
    keep <- vapply(seq_len(nrow(out)), function(i) {
      any(!is.na(unlist(out[i, data_cols, with = FALSE])))
    }, logical(1L))
    out <- out[keep]
  }

  if (verbose) {
    cli::cli_inform(
      "Collected {nrow(out)} row{?s} x {ncol(out)} column{?s}"
    )
  }

  out[]
}

# -----------------------------------------------------------------------------
# Coordinate / date / dataset parsers
# -----------------------------------------------------------------------------

#' Normalise coordinate input
#'
#' @param lon Longitude(s).
#' @param lat Latitude(s).
#' @param xy Optional data.frame/matrix with lon/lat or x/y columns.
#' @returns A 2-column `data.table` with columns `lon`, `lat`.
#' @autoglobal
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
  if (any(coords$lon < -180 | coords$lon > 180 |
            coords$lat < -90  | coords$lat > 90)) {
    cli::cli_abort(
      "Coordinate out of bounds: lon in [-180, 180], lat in [-90, 90]."
    )
  }
  coords
}

#' Normalise a date_range argument
#'
#' Accepts a length-2 character/Date vector as a [start, end] range and any
#' longer vector as the explicit set of dates.
#'
#' @param date_range User-supplied date range.
#' @returns A `Date` vector.
#' @autoglobal
#' @dev
.parse_date_range <- function(date_range) {
  bad <- function() cli::cli_abort("No valid dates in {.arg date_range}.")
  dates <- tryCatch({
    if (length(date_range) == 2L && !inherits(date_range, "Date")) {
      seq(
        as.Date(date_range[1L]),
        as.Date(date_range[2L]),
        by = "day"
      )
    } else {
      as.Date(date_range)
    }
  }, error = function(e) bad())
  if (length(dates) == 0L || any(is.na(dates))) bad()
  dates
}

#' Resolve the `datasets` argument to a clean alias vector
#'
#' @param datasets User-supplied aliases (or `NULL`/`"all"`).
#' @returns A character vector of recognised aliases (deduplicated, order
#'   preserved).
#' @autoglobal
#' @dev
.normalise_datasets <- function(datasets) {
  all_aliases <- c(
    "SMIPS", "ASC", "AET",
    "AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO",
    "SOILDIV", "CANOPY", "PHENOLOGY"
  )
  if (is.null(datasets) ||
        (length(datasets) == 1L && identical(datasets, "all"))) {
    return(all_aliases)
  }
  datasets <- unique(toupper(trimws(as.character(datasets))))
  if (length(datasets) == 0L) {
    cli::cli_abort("No datasets specified.")
  }
  unsupported <- setdiff(datasets, all_aliases)
  if (length(unsupported) > 0L) {
    cli::cli_warn(
      c(
        "!" = "Unknown datasets ignored: {.val {unsupported}}.",
        "i" = "Supported aliases: {.val {all_aliases}}."
      )
    )
    datasets <- intersect(datasets, all_aliases)
  }
  if (length(datasets) == 0L) {
    cli::cli_abort("No supported datasets remained after filtering.")
  }
  datasets
}

# -----------------------------------------------------------------------------
# Work-item planner: one item per COG fetch
# -----------------------------------------------------------------------------

#' Plan the list of COG fetches
#'
#' A *work item* is one COG-shaped request: a tuple of
#' `(dataset, date_idx, variant, depth)`.  Each item maps to exactly one
#' `read_tern()` + `terra::extract()` round-trip and produces one or more
#' columns in the output table.
#'
#' For time-series datasets (SMIPS, AET) we emit one work item per
#' (date, variant); for SLGA `depth = "all"` we emit one work item per
#' depth interval; for static datasets we emit a single work item whose
#' value is replicated across the date axis (`date_idx = NA_integer_`).
#'
#' @param datasets Normalised alias vector.
#' @param dates Resolved `Date` vector.
#' @param depth SLGA depth selector.
#' @param stat SLGA stat selector (`"EV"` or `"CI"`).
#' @param smips_collection SMIPS collection selector.
#' @returns A list of work-item lists.
#' @autoglobal
#' @dev
.build_work_items <- function(datasets, dates, depth, stat, smips_collection) {
  slga_aliases <- c("AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO")
  slga_depths  <- c("000_005", "005_015", "015_030",
                    "030_060", "060_100", "100_200")
  smips_variants <- c("totalbucket", "SMindex", "bucket1",
                      "bucket2", "deepD", "runoff")

  items <- list()

  for (ds in datasets) {
    if (ds == "SMIPS") {
      variants <- if (smips_collection == "all") {
        smips_variants
      } else {
        smips_collection
      }
      for (v in variants) {
        col <- paste0("SMIPS_", v)
        for (i in seq_along(dates)) {
          items[[length(items) + 1L]] <- list(
            ds       = "SMIPS",
            type     = "numeric",
            cols     = col,
            date_idx = i,
            args     = list(date = dates[i], collection = v),
            label    = sprintf("SMIPS %s %s", v, format(dates[i], "%Y-%m-%d"))
          )
        }
      }
    } else if (ds == "AET") {
      for (i in seq_along(dates)) {
        items[[length(items) + 1L]] <- list(
          ds       = "AET",
          type     = "numeric",
          cols     = "AET",
          date_idx = i,
          args     = list(date = dates[i]),
          label    = sprintf("AET %s", format(dates[i], "%Y-%m-%d"))
        )
      }
    } else if (ds %in% slga_aliases) {
      depths <- if (depth == "all") slga_depths else depth
      for (d in depths) {
        col <- if (depth == "all") paste0(ds, "_", d) else ds
        items[[length(items) + 1L]] <- list(
          ds       = ds,
          type     = "numeric",
          cols     = col,
          date_idx = NA_integer_,
          args     = list(depth = d, collection = stat),
          label    = sprintf("%s depth %s (static)", ds, d)
        )
      }
    } else if (ds == "ASC") {
      items[[length(items) + 1L]] <- list(
        ds       = "ASC",
        type     = "character",
        cols     = "ASC",
        date_idx = NA_integer_,
        args     = list(),
        label    = "ASC (static)"
      )
    } else if (ds == "PHENOLOGY") {
      phen_year <- as.integer(format(dates[1L], "%Y"))
      phen_year <- max(2003L, min(2018L, phen_year))
      items[[length(items) + 1L]] <- list(
        ds       = "PHENOLOGY",
        type     = "numeric",
        cols     = "PHENOLOGY",
        date_idx = NA_integer_,
        args     = list(year = phen_year),
        label    = sprintf("PHENOLOGY year %d (static)", phen_year)
      )
    } else {
      items[[length(items) + 1L]] <- list(
        ds       = ds,
        type     = "numeric",
        cols     = ds,
        date_idx = NA_integer_,
        args     = list(),
        label    = sprintf("%s (static)", ds)
      )
    }
  }

  items
}

# -----------------------------------------------------------------------------
# Per-COG extractor: one read_tern + one terra::extract per work item
# -----------------------------------------------------------------------------

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
#' @returns `invisible(NULL)`.
#' @autoglobal
#' @dev
.fill_work_item <- function(out, wi, pts, n_dt, n_loc, api_key) {
  r <- tryCatch(
    suppressWarnings(
      do.call(read_tern, c(list(wi$ds), wi$args, list(api_key = api_key)))
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
  v    <- vals[[1L]]
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
    row_end   <- wi$date_idx * n_loc
    out[seq.int(row_start, row_end), (wi$cols[1L]) := v]
  }

  invisible(NULL)
}

# -----------------------------------------------------------------------------
# Pretty datasets-table for verbose output
# -----------------------------------------------------------------------------

#' Print the user-facing datasets-table summarising what will be fetched.
#'
#' @param datasets Normalised alias vector.
#' @param depth SLGA depth selector.
#' @param smips_collection SMIPS collection selector.
#' @param stat SLGA stat selector.
#' @returns `invisible(NULL)` — called for side effects.
#' @autoglobal
#' @dev
.print_datasets_table <- function(datasets, depth, smips_collection, stat) {
  dataset_info <- list(
    SMIPS     = list(id = "TERN/d1995ee8", temporal = "Daily",
                     resolution = "1 km",
                     description = "Soil Moisture Integration & Prediction System"),
    ASC       = list(id = "TERN/15728dba", temporal = "Static",
                     resolution = "90 m",
                     description = "Australian Soil Classification (soil order)"),
    AET       = list(id = "TERN/9fefa68b", temporal = "Monthly",
                     resolution = "30 m",
                     description = "Actual Evapotranspiration (CMRSET)"),
    AWC       = list(id = "TERN/482301c2", temporal = "Static",
                     resolution = "90 m",
                     description = "Available Water Capacity (SLGA)"),
    CLY       = list(id = "TERN/slga_cly", temporal = "Static",
                     resolution = "90 m",
                     description = "Clay content % (SLGA)"),
    SND       = list(id = "TERN/slga_snd", temporal = "Static",
                     resolution = "90 m",
                     description = "Sand content % (SLGA)"),
    SLT       = list(id = "TERN/slga_slt", temporal = "Static",
                     resolution = "90 m",
                     description = "Silt content % (SLGA)"),
    BDW       = list(id = "TERN/slga_bdw", temporal = "Static",
                     resolution = "90 m",
                     description = "Bulk Density whole soil (SLGA)"),
    PHC       = list(id = "TERN/slga_phc", temporal = "Static",
                     resolution = "90 m",
                     description = "pH (CaCl2) soil acidity (SLGA)"),
    PHW       = list(id = "TERN/slga_phw", temporal = "Static",
                     resolution = "90 m",
                     description = "pH (water) soil acidity (SLGA)"),
    NTO       = list(id = "TERN/slga_nto", temporal = "Static",
                     resolution = "90 m",
                     description = "Total Nitrogen % weight (SLGA)"),
    SOILDIV   = list(id = "TERN/4a428d52", temporal = "Static",
                     resolution = "90 m",
                     description = "Soil Beta Diversity (NMDS ordination)"),
    CANOPY    = list(id = "TERN/36c98155", temporal = "Static",
                     resolution = "30 m",
                     description = "Canopy Height composite (OzTreeMap)"),
    PHENOLOGY = list(id = "TERN/2bb0c81a", temporal = "Annual",
                     resolution = "500 m",
                     description = "Land Surface Phenology (MODIS, 2003-2018)")
  )

  layers_info <- vapply(datasets, function(ds) {
    if (ds %in% c("AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO")) {
      if (depth == "all") "6 depths" else paste0("Depth ", depth)
    } else if (ds == "SMIPS") {
      if (smips_collection == "all") "6 variants" else smips_collection
    } else {
      "Single"
    }
  }, character(1L))

  tbl <- data.table::data.table(
    Alias       = datasets,
    ID          = vapply(datasets, function(x) dataset_info[[x]]$id,
                         character(1L)),
    Layer       = layers_info,
    Temporal    = vapply(datasets, function(x) dataset_info[[x]]$temporal,
                         character(1L)),
    Resolution  = vapply(datasets, function(x) dataset_info[[x]]$resolution,
                         character(1L)),
    Description = vapply(datasets, function(x) dataset_info[[x]]$description,
                         character(1L))
  )

  cat("\n")
  cli::cli_rule("Datasets to Collect")
  print(tbl, nrows = Inf)
  cat("\n")

  invisible(NULL)
}
