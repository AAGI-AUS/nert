#' Collect TERN Data Over Time and Space
#'
#' Extract values from one or more TERN datasets at given location(s) over a
#' date range. Supports single or multiple coordinates. Returns a data.table
#' with one row per date per location and one column per dataset.
#' Static datasets are repeated across all dates.
#'
#' @param date_range A \code{Date} vector or character vector of dates
#'   (e.g. \code{seq(as.Date("2024-01-01"), as.Date("2024-01-31"), by = "day")})
#'   OR a length-2 vector giving start and end dates
#'   (e.g. \code{c("2024-01-01", "2024-01-31")}).
#' @param lon Longitude(s) (WGS84, EPSG:4326). Either:
#'   - A single numeric value (scalar)
#'   - A numeric vector (multiple coordinates, same length as \code{lat})
#'   - Omitted if using \code{xy} notation
#' @param lat Latitude(s) (WGS84, EPSG:4326). Either:
#'   - A single numeric value (scalar)
#'   - A numeric vector (multiple coordinates, same length as \code{lon})
#'   - Omitted if using \code{xy} notation
#' @param xy Optional: A \code{data.frame}, \code{data.table}, or \code{matrix}
#'   with coordinate columns. Column names should be \code{x} and \code{y} or
#'   \code{lon} and \code{lat}. If provided, \code{lon} and \code{lat} are ignored.
#'   Use \code{NULL} (default) for lon/lat parameters.
#' @param datasets A \code{character} vector of dataset aliases to collect.
#'   Default: all 14 datasets (SMIPS, ASC, AET, AWC, CLY, SND, SLT, BDW, PHC,
#'   PHW, NTO, SOILDIV, CANOPY, PHENOLOGY).
#'   Use \code{NULL} or \code{"all"} for all datasets.
#' @param depth For SLGA datasets: depth interval (default \code{"all"}).
#'   Options: \code{"000_005"}, \code{"005_015"}, \code{"015_030"}, \code{"030_060"},
#'   \code{"060_100"}, \code{"100_200"}, or \code{"all"} for all 6 depths.
#'   Ignored for non-SLGA datasets.
#' @param stat For SLGA datasets: \code{"EV"} (estimate, default) or
#'   \code{"CI"} (confidence interval). Ignored for non-SLGA datasets.
#' @param smips_collection For SMIPS dataset: collection type (default \code{"all"}).
#'   Options: \code{"totalbucket"} (total soil moisture, full active layer),
#'   \code{"SMindex"} (soil moisture index, 0-100%),
#'   \code{"bucket1"} (top soil layer), \code{"bucket2"} (second soil layer),
#'   \code{"deepD"} (deep soil layer), \code{"runoff"} (surface runoff),
#'   or \code{"all"} to collect all 6 SMIPS variants as separate columns.
#'   Ignored for non-SMIPS datasets.
#' @param api_key TERN API key. Default: \code{get_key()}.
#' @param verbose Logical. If \code{TRUE}, print progress messages.
#' @param na.rm Logical. If \code{TRUE}, remove rows with all NA values.
#'
#' @returns
#' A \code{data.table} with columns:
#' - \code{date}: Date
#' - \code{lon}, \code{lat}: Coordinates (if multiple locations)
#' - One column per dataset, named by alias (e.g. \code{SMIPS}, \code{AWC})
#'
#' @details
#' **Single location:** Returns N rows (one per date) x K columns (datasets).
#'
#' **Multiple locations:** Returns (N x M) rows (dates x locations) x (K+2)
#' columns (date + lon + lat + datasets).
#'
#' **Time-series datasets** (SMIPS, AET): Values extracted for each date.
#'   - SMIPS may have multiple layers (bands) from the COG; all layers are extracted
#'     as separate columns (e.g., \code{SMIPS_band_1}, \code{SMIPS_band_2}, ...).
#'   - AET typically returns a single layer per date.
#'
#' **Static datasets** (SLGA, ASC, SOILDIV, CANOPY, PHENOLOGY): Values repeated
#'   across all dates.
#'   - SLGA datasets with \code{depth = "all"} expand to 6 columns (one per depth).
#'   - Other static datasets typically return single-layer values as one column.
#'   - When multi-layer datasets are detected, each layer becomes a separate column
#'     (named by layer name from the COG).
#'
#' **ASC data type:** Australian Soil Classification (ASC) returns character values
#'   (soil order descriptions) instead of numeric codes.
#'
#' If a request fails (e.g. no internet, API error), that dataset column
#' will contain \code{NA} for the affected rows.
#'
#' @examplesIf interactive()
#' # Single location
#' dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-05"), by = "day")
#' d_t <- collect_tern_data(
#'   date_range = dates,
#'   lon = 138.6,
#'   lat = -34.9,
#'   datasets = c("SMIPS", "CLY")
#' )
#' head(d_t)
#'
#' # Multiple locations (vectors)
#' d_t_multi <- collect_tern_data(
#'   lon = c(138.6, 139.5),
#'   lat = c(-34.9, -35.5),
#'   date_range = dates,
#'   datasets = c("SMIPS", "CANOPY")
#' )
#' head(d_t_multi)
#'
#' # Using xy notation (data.frame)
#' xy <- data.frame(lon = c(138.6, 139.5), lat = c(-34.9, -35.5))
#' d_t_xy <- collect_tern_data(
#'   xy = xy,
#'   date_range = dates,
#'   datasets = "CLY"
#' )
#'
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
  # -- Parse coordinates --------------------------------------------------------
  coords <- .parse_coordinates(lon, lat, xy)
  coords_df <- coords$coords_df
  multi_location <- coords$multi_location

  if (verbose && multi_location) {
    cli::cli_inform("Processing {nrow(coords_df)} location(s)")
  }

  # -- Parse date range ---------------------------------------------------------
  if (length(date_range) == 2L && !inherits(date_range, "Date")) {
    dates <- seq(
      as.Date(date_range[1L]),
      as.Date(date_range[2L]),
      by = "day"
    )
  } else {
    dates <- as.Date(date_range)
  }

  if (length(dates) == 0L) {
    cli::cli_abort("No valid dates in {.arg date_range}.")
  }

  # -- Parse datasets -----------------------------------------------------------
  if (is.null(datasets) || identical(datasets, "all")) {
    datasets <- c(
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
  }
  datasets <- toupper(trimws(datasets))
  datasets <- unique(datasets)

  if (length(datasets) == 0L) {
    cli::cli_abort("No datasets specified.")
  }

  # Check for unsupported datasets
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
    "SOILDIV",
    "CANOPY",
    "PHENOLOGY"
  )
  unsupported <- setdiff(datasets, all_aliases)
  if (length(unsupported) > 0L) {
    cli::cli_warn(
      "Unknown datasets ignored: {.val {unsupported}}. ",
      "Supported: {.val {all_aliases}}"
    )
    datasets <- intersect(datasets, all_aliases)
  }

  # -- Display dataset information table (if verbose) --------------------------
  if (verbose) {
    .print_datasets_table(datasets, depth, smips_collection, stat)
  }

  # -- Extract for each location ------------------------------------------------
  if (verbose) {
    cli::cli_inform(
      "Collecting {length(datasets)} dataset(s) over {length(dates)} date(s)"
    )
  }

  all_results <- list()

  for (i in seq_len(nrow(coords_df))) {
    lon_i <- coords_df$lon[i]
    lat_i <- coords_df$lat[i]

    if (verbose && multi_location) {
      cli::cli_inform("  Location {i}/{nrow(coords_df)}: ({lon_i}, {lat_i})")
    }

    d_t_i <- .collect_single_location(
      lon_i,
      lat_i,
      dates,
      datasets,
      depth,
      stat,
      smips_collection,
      api_key,
      verbose
    )

    if (multi_location) {
      d_t_i[, "lon" := lon_i]
      d_t_i[, "lat" := lat_i]
    }

    all_results[[i]] <- d_t_i
  }

  # -- Combine results ----------------------------------------------------------
  if (multi_location) {
    d_t <- data.table::rbindlist(all_results)
    # Preserve all columns except reorder date/lon/lat first
    data_cols <- setdiff(names(d_t), c("date", "lon", "lat"))
    col_order <- c("date", "lon", "lat", data_cols)
    d_t <- d_t[, col_order, with = FALSE]
  } else {
    d_t <- all_results[[1L]]
  }

  if (na.rm) {
    # Remove rows where all dataset columns are NA
    # Identify data columns (not date/lon/lat)
    data_cols <- setdiff(names(d_t), c("date", "lon", "lat"))
    if (length(data_cols) > 0) {
      na_counts <- rowSums(is.na(d_t[, data_cols, with = FALSE]))
      d_t <- d_t[na_counts < length(data_cols)]
    }
  }

  if (verbose) {
    cli::cli_inform("Collected {nrow(d_t)} rows x {ncol(d_t)} columns")
  }

  return(d_t)
}

# -----------------------------------------------------------------------------
# Helper: Parse coordinate input
# -----------------------------------------------------------------------------
.parse_coordinates <- function(lon, lat, xy) {
  if (!is.null(xy)) {
    # xy notation: data.frame/matrix with x/y or lon/lat columns
    if (is.matrix(xy)) {
      xy <- as.data.frame(xy)
    }
    if (!is.data.frame(xy) && !is.data.table(xy)) {
      cli::cli_abort("{.arg xy} must be a data.frame, data.table, or matrix.")
    }

    # Identify coordinate columns
    if ("lon" %in% names(xy) && "lat" %in% names(xy)) {
      coords_df <- data.table::as.data.table(xy[, c("lon", "lat")])
    } else if ("x" %in% names(xy) && "y" %in% names(xy)) {
      coords_df <- data.table::as.data.table(xy[, c("x", "y")])
      data.table::setnames(coords_df, c("x", "y"), c("lon", "lat"))
    } else {
      cli::cli_abort(
        "{.arg xy} must have columns {.val lon}/{.val lat} or {.val x}/{.val y}."
      )
    }

    multi_location <- nrow(coords_df) > 1L
  } else if (!is.null(lon) && !is.null(lat)) {
    # lon/lat notation
    if (length(lon) == 1L && length(lat) == 1L) {
      # Single location
      .validate_single_coord(lon, lat)
      coords_df <- data.table::data.table(lon = lon, lat = lat)
      multi_location <- FALSE
    } else {
      # Multiple locations
      if (length(lon) != length(lat)) {
        cli::cli_abort("{.arg lon} and {.arg lat} must have equal length.")
      }
      coords_df <- data.table::data.table(lon = lon, lat = lat)

      # Validate all coordinates
      for (i in seq_len(nrow(coords_df))) {
        .validate_single_coord(coords_df$lon[i], coords_df$lat[i])
      }

      multi_location <- nrow(coords_df) > 1L
    }
  } else {
    cli::cli_abort(
      "You must provide either {.arg lon}/{.arg lat} or {.arg xy}."
    )
  }

  list(coords_df = coords_df, multi_location = multi_location)
}

# -----------------------------------------------------------------------------
# Helper: Validate single coordinate
# -----------------------------------------------------------------------------
.validate_single_coord <- function(lon, lat) {
  if (!is.numeric(lon) || !is.numeric(lat)) {
    cli::cli_abort("Coordinates must be numeric.")
  }
  if (lon < -180 || lon > 180 || lat < -90 || lat > 90) {
    cli::cli_abort(
      "Coordinate out of bounds: lon must be -180..180, lat -90..90. ",
      "Got: lon={lon}, lat={lat}"
    )
  }
}

# -----------------------------------------------------------------------------
# Helper: Collect data for single location
# -----------------------------------------------------------------------------
.collect_single_location <- function(
  lon,
  lat,
  dates,
  datasets,
  depth,
  stat,
  smips_collection,
  api_key,
  verbose
) {
  # Define dataset types
  time_series_datasets <- c("SMIPS", "AET")
  static_datasets <- c(
    "ASC",
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

  ts_datasets <- intersect(datasets, time_series_datasets)
  st_datasets <- intersect(datasets, static_datasets)

  # Create point for extraction
  pt <- terra::vect(
    matrix(c(lon, lat), ncol = 2),
    type = "points",
    crs = "EPSG:4326"
  )

  results_list <- list()
  dataset_cols <- list() # Track actual columns created per dataset

  # Time-series: loop over dates
  for (ds in ts_datasets) {
    if (verbose) {
      cli::cli_inform("    {ds}...")
    }

    # Handle SMIPS "all" collections specially
    if (ds == "SMIPS" && smips_collection == "all") {
      # Extract all 6 SMIPS collections
      smips_variants <- c(
        "totalbucket",
        "SMindex",
        "bucket1",
        "bucket2",
        "deepD",
        "runoff"
      )
      smips_cols <- character(0)

      for (variant in smips_variants) {
        col_name <- paste0("SMIPS_", variant)
        results_list[[col_name]] <- rep(NA_real_, length(dates))
        smips_cols <- c(smips_cols, col_name)
      }
      dataset_cols[[ds]] <- smips_cols

      # Extract all variants for all dates
      for (i in seq_along(dates)) {
        for (variant in smips_variants) {
          tryCatch(
            {
              r <- suppressWarnings(
                read_tern(
                  ds,
                  date = dates[i],
                  collection = variant,
                  api_key = api_key
                )
              )
              extracted <- suppressWarnings(terra::extract(r, pt))
              if (
                !is.null(extracted) &&
                  is.data.frame(extracted) &&
                  ncol(extracted) >= 2
              ) {
                col_name <- paste0("SMIPS_", variant)
                results_list[[col_name]][i] <- as.numeric(extracted[[2]][1])
              }
            },
            error = function(e) {
              cli::cli_warn(c(
                "Failed to fetch {.val {ds}} variant {.val {variant}} for date {.val {format(dates[i], '%Y-%m-%d')}}.",
                "x" = "{conditionMessage(e)}"
              ))
            }
          )
        }
      }
    } else {
      # Standard single-collection handling (SMIPS with specific collection or AET)
      # Initialize: extract first date to determine layer structure
      first_r <- NULL
      layer_names <- NULL
      n_layers <- 1

      tryCatch(
        {
          if (ds == "SMIPS") {
            first_r <- suppressWarnings(
              read_tern(
                ds,
                date = dates[1],
                collection = smips_collection,
                api_key = api_key
              )
            )
          } else {
            first_r <- suppressWarnings(read_tern(
              ds,
              date = dates[1],
              api_key = api_key
            ))
          }
          layer_names <- names(first_r)
          n_layers <- terra::nlyr(first_r)
        },
        error = function(e) {
          cli::cli_warn(c(
            "Failed to determine layer structure for {.val {ds}} (first date {.val {format(dates[1], '%Y-%m-%d')}}).",
            "i" = "Subsequent dates for this dataset will be skipped.",
            "x" = "{conditionMessage(e)}"
          ))
        }
      )

      # Create column structure based on detected layers
      if (n_layers > 1 && !is.null(layer_names)) {
        # Multi-layer time-series: create matrix for each layer
        layer_cols <- character(0)
        for (j in seq_along(layer_names)) {
          col_name <- layer_names[j]
          # Add SMIPS_ prefix for single SMIPS collections
          if (ds == "SMIPS") {
            col_name <- paste0("SMIPS_", col_name)
          }
          results_list[[col_name]] <- rep(NA_real_, length(dates))
          layer_cols <- c(layer_cols, col_name)
        }
        dataset_cols[[ds]] <- layer_cols
      } else {
        # Single-layer time-series
        # Add SMIPS_ prefix for single SMIPS collections
        col_name <- if (ds == "SMIPS") {
          paste0("SMIPS_", smips_collection)
        } else {
          ds
        }
        results_list[[col_name]] <- rep(NA_real_, length(dates))
        dataset_cols[[ds]] <- col_name
      }

      # Extract values for all dates
      for (i in seq_along(dates)) {
        tryCatch(
          {
            if (ds == "SMIPS") {
              r <- suppressWarnings(
                read_tern(
                  ds,
                  date = dates[i],
                  collection = smips_collection,
                  api_key = api_key
                )
              )
            } else {
              r <- suppressWarnings(read_tern(
                ds,
                date = dates[i],
                api_key = api_key
              ))
            }
            extracted <- suppressWarnings(terra::extract(r, pt))
            if (
              !is.null(extracted) &&
                is.data.frame(extracted) &&
                ncol(extracted) >= 2
            ) {
              data_cols <- extracted[, -1, drop = FALSE]

              # Handle multiple layers
              if (n_layers > 1 && !is.null(layer_names)) {
                for (j in seq_along(layer_names)) {
                  col_name <- layer_names[j]
                  # Add SMIPS_ prefix for single SMIPS collections
                  if (ds == "SMIPS") {
                    col_name <- paste0("SMIPS_", col_name)
                  }
                  results_list[[col_name]][i] <- as.numeric(data_cols[[j]][1])
                }
              } else {
                # Single layer - add SMIPS_ prefix for single SMIPS collections
                col_name <- if (ds == "SMIPS") {
                  paste0("SMIPS_", smips_collection)
                } else {
                  ds
                }
                results_list[[col_name]][i] <- as.numeric(data_cols[[1]][1])
              }
            }
          },
          error = function(e) {
            cli::cli_warn(c(
              "Failed to fetch {.val {ds}} for date {.val {format(dates[i], '%Y-%m-%d')}}.",
              "x" = "{conditionMessage(e)}"
            ))
          }
        )
      }
    }
  }

  # Static: extract once, replicate across all dates
  slga_aliases <- c("AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO")
  slga_depths  <- c("000_005", "005_015", "015_030",
                    "030_060", "060_100", "100_200")
  for (ds in st_datasets) {
    if (verbose) {
      cli::cli_inform("    {ds} (static)...")
    }

    # SLGA + depth = "all": loop over the six GlobalSoilMap depth intervals,
    # producing one column per (dataset, depth) named e.g. AWC_000_005.
    # The single-depth SLGA case falls through to the standard handler below.
    if (ds %in% slga_aliases && depth == "all") {
      layer_cols <- character(0L)
      for (d in slga_depths) {
        col_name <- paste0(ds, "_", d)
        col_vals <- rep(NA_real_, length(dates))
        tryCatch(
          {
            r <- suppressWarnings(read_tern(
              ds, depth = d, collection = stat, api_key = api_key
            ))
            extracted <- suppressWarnings(terra::extract(r, pt))
            if (!is.null(extracted) && is.data.frame(extracted) &&
                ncol(extracted) >= 2L) {
              val <- as.numeric(extracted[, -1L, drop = FALSE][[1L]][1L])
              col_vals[] <- val
            }
          },
          error = function(e) {
            cli::cli_warn(c(
              "Failed to fetch SLGA {.val {ds}} at depth {.val {d}}.",
              "i" = "Column {.val {col_name}} will contain {.code NA}.",
              "x" = "{conditionMessage(e)}"
            ))
          }
        )
        results_list[[col_name]] <- col_vals
        layer_cols <- c(layer_cols, col_name)
      }
      dataset_cols[[ds]] <- layer_cols
      next
    }

    tryCatch(
      {
        if (ds %in% slga_aliases) {
          r <- suppressWarnings(
            read_tern(ds, depth = depth, collection = stat, api_key = api_key)
          )
        } else if (ds == "PHENOLOGY") {
          # Phenology requires year (2003-2018), use year from first date
          phen_year <- as.integer(format(dates[1], "%Y"))
          phen_year <- max(2003L, min(2018L, phen_year))
          r <- suppressWarnings(
            read_tern(ds, year = phen_year, api_key = api_key)
          )
        } else {
          r <- suppressWarnings(read_tern(ds, api_key = api_key))
        }

        extracted <- suppressWarnings(terra::extract(r, pt))
        if (
          !is.null(extracted) &&
            is.data.frame(extracted) &&
            ncol(extracted) >= 2
        ) {
          # Get data columns (all except ID column, which is always first)
          data_cols <- extracted[, -1, drop = FALSE]

          # Get layer names from raster
          layer_names <- names(r)

          # Handle multiple layers
          if (
            ncol(data_cols) > 1 &&
              !is.null(layer_names) &&
              length(layer_names) > 1
          ) {
            # Multi-layer dataset: create separate columns for each layer
            layer_cols <- character(0)
            for (j in seq_along(layer_names)) {
              col_name <- layer_names[j]
              col_vals <- rep(data_cols[[j]][1], length(dates))
              # For ASC, ensure character type
              if (ds == "ASC") {
                col_vals <- as.character(col_vals)
              } else {
                col_vals <- as.numeric(col_vals)
              }
              results_list[[col_name]] <- col_vals
              layer_cols <- c(layer_cols, col_name)
            }
            dataset_cols[[ds]] <- layer_cols
          } else {
            # Single-layer dataset: create one column
            col_vals <- rep(NA_real_, length(dates))
            val <- data_cols[[1]][1]
            # For ASC, ensure character type
            if (ds == "ASC") {
              val <- as.character(val)
              col_vals <- rep(val, length(dates))
            } else {
              col_vals[] <- as.numeric(val)
            }
            results_list[[ds]] <- col_vals
            dataset_cols[[ds]] <- ds
          }
        }
      },
      error = function(e) {
        cli::cli_warn(c(
          "Failed to fetch static dataset {.val {ds}}.",
          "i" = "Column will be missing from the result.",
          "x" = "{conditionMessage(e)}"
        ))
      }
    )
  }

  # Build output data.table
  d_t <- data.table::as.data.table(results_list)
  d_t[, "date" := dates]

  # Reorder: date first, then datasets in order of request (including all layer columns)
  col_order <- c("date")
  for (ds in datasets) {
    if (ds %in% names(dataset_cols)) {
      col_order <- c(col_order, dataset_cols[[ds]])
    }
  }
  # Keep only columns that exist in d_t
  col_order <- intersect(col_order, names(d_t))
  d_t <- d_t[, col_order, with = FALSE]

  return(d_t)
}

# -----------------------------------------------------------------------------
# Helper: Print datasets information table
# -----------------------------------------------------------------------------
.print_datasets_table <- function(datasets, depth, smips_collection, stat) {
  # Dataset metadata
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
      description = "Actual Evapotranspiration (CMRSET)"
    ),
    AWC = list(
      id = "TERN/482301c2",
      temporal = "Static",
      resolution = "90 m",
      description = "Available Water Capacity (SLGA)"
    ),
    CLY = list(
      id = "TERN/slga_cly",
      temporal = "Static",
      resolution = "90 m",
      description = "Clay content % (SLGA)"
    ),
    SND = list(
      id = "TERN/slga_snd",
      temporal = "Static",
      resolution = "90 m",
      description = "Sand content % (SLGA)"
    ),
    SLT = list(
      id = "TERN/slga_slt",
      temporal = "Static",
      resolution = "90 m",
      description = "Silt content % (SLGA)"
    ),
    BDW = list(
      id = "TERN/slga_bdw",
      temporal = "Static",
      resolution = "90 m",
      description = "Bulk Density whole soil (SLGA)"
    ),
    PHC = list(
      id = "TERN/slga_phc",
      temporal = "Static",
      resolution = "90 m",
      description = "pH (CaCl2) soil acidity (SLGA)"
    ),
    PHW = list(
      id = "TERN/slga_phw",
      temporal = "Static",
      resolution = "90 m",
      description = "pH (water) soil acidity (SLGA)"
    ),
    NTO = list(
      id = "TERN/slga_nto",
      temporal = "Static",
      resolution = "90 m",
      description = "Total Nitrogen % weight (SLGA)"
    ),
    SOILDIV = list(
      id = "TERN/4a428d52",
      temporal = "Static",
      resolution = "90 m",
      description = "Soil Beta Diversity (NMDS ordination)"
    ),
    CANOPY = list(
      id = "TERN/36c98155",
      temporal = "Static",
      resolution = "30 m",
      description = "Canopy Height composite (OzTreeMap)"
    ),
    PHENOLOGY = list(
      id = "TERN/2bb0c81a",
      temporal = "Annual",
      resolution = "500 m",
      description = "Land Surface Phenology (MODIS, 2003-2018)"
    )
  )

  # Build layer information
  layers_info <- character(length(datasets))
  for (i in seq_along(datasets)) {
    ds <- datasets[i]
    if (ds %in% c("AWC", "CLY", "SND", "SLT", "BDW", "PHC", "PHW", "NTO")) {
      if (depth == "all") {
        layers_info[i] <- "6 depths"
      } else {
        layers_info[i] <- paste0("Depth ", depth)
      }
    } else if (ds == "SMIPS") {
      if (smips_collection == "all") {
        layers_info[i] <- "6 variants"
      } else {
        layers_info[i] <- smips_collection
      }
    } else {
      layers_info[i] <- "Single"
    }
  }

  # Create data table
  tbl <- data.table::data.table(
    Alias = datasets,
    ID = vapply(
      datasets,
      function(x) dataset_info[[x]]$id,
      character(1L)
    ),
    Layer = layers_info,
    Temporal = vapply(
      datasets,
      function(x) dataset_info[[x]]$temporal,
      character(1L)
    ),
    Resolution = vapply(
      datasets,
      function(x) dataset_info[[x]]$resolution,
      character(1L)
    ),
    Description = vapply(
      datasets,
      function(x) dataset_info[[x]]$description,
      character(1L)
    )
  )

  # Print with cli
  cat("\n")
  cli::cli_rule("Datasets to Collect")
  print(tbl, nrows = Inf)
  cat("\n")
}
