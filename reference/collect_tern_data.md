# Collect TERN Data Over Time and Space

Extract values from one or more TERN datasets at given location(s) over
a date range. Supports single or multiple coordinates. Returns a
data.table with one row per date per location and one column per
dataset. Static datasets are repeated across all dates.

## Usage

``` r
collect_tern_data(
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
)
```

## Arguments

- date_range:

  A `Date` vector or character vector of dates (e.g.
  `seq(as.Date("2024-01-01"), as.Date("2024-01-31"), by = "day")`) OR a
  length-2 vector giving start and end dates (e.g.
  `c("2024-01-01", "2024-01-31")`).

- lon:

  Longitude(s) (WGS84, EPSG:4326). Either:

  - A single numeric value (scalar)

  - A numeric vector (multiple coordinates, same length as `lat`)

  - Omitted if using `xy` notation

- lat:

  Latitude(s) (WGS84, EPSG:4326). Either:

  - A single numeric value (scalar)

  - A numeric vector (multiple coordinates, same length as `lon`)

  - Omitted if using `xy` notation

- xy:

  Optional: A `data.frame`, `data.table`, or `matrix` with coordinate
  columns. Column names should be `x` and `y` or `lon` and `lat`. If
  provided, `lon` and `lat` are ignored. Use `NULL` (default) for
  lon/lat parameters.

- datasets:

  A `character` vector of dataset aliases to collect. Default: all 14
  datasets (SMIPS, ASC, AET, AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO,
  SOILDIV, CANOPY, PHENOLOGY). Use `NULL` or `"all"` for all datasets.

- depth:

  For SLGA datasets: depth interval (default `"all"`). Options:
  `"000_005"`, `"005_015"`, `"015_030"`, `"030_060"`, `"060_100"`,
  `"100_200"`, or `"all"` for all 6 depths. Ignored for non-SLGA
  datasets.

- stat:

  For SLGA datasets: `"EV"` (estimate, default) or `"CI"` (confidence
  interval). Ignored for non-SLGA datasets.

- smips_collection:

  For SMIPS dataset: collection type (default `"all"`). Options:
  `"totalbucket"` (total soil moisture, full active layer), `"SMindex"`
  (soil moisture index, 0-100%), `"bucket1"` (top soil layer),
  `"bucket2"` (second soil layer), `"deepD"` (deep soil layer),
  `"runoff"` (surface runoff), or `"all"` to collect all 6 SMIPS
  variants as separate columns. Ignored for non-SMIPS datasets.

- api_key:

  TERN API key. Default:
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md).

- verbose:

  Logical. If `TRUE`, print progress messages.

- na.rm:

  Logical. If `TRUE`, remove rows with all NA values.

## Value

A `data.table` with columns:

- `date`: Date

- `lon`, `lat`: Coordinates (if multiple locations)

- One column per dataset, named by alias (e.g. `SMIPS`, `AWC`)

## Details

**Single location:** Returns N rows (one per date) x K columns
(datasets).

**Multiple locations:** Returns (N x M) rows (dates x locations) x (K+2)
columns (date + lon + lat + datasets).

**Time-series datasets** (SMIPS, AET): Values extracted for each date.

- SMIPS may have multiple layers (bands) from the COG; all layers are
  extracted as separate columns (e.g., `SMIPS_band_1`, `SMIPS_band_2`,
  ...).

- AET typically returns a single layer per date.

**Static datasets** (SLGA, ASC, SOILDIV, CANOPY, PHENOLOGY): Values
repeated across all dates.

- SLGA datasets with `depth = "all"` expand to 6 columns (one per
  depth).

- Other static datasets typically return single-layer values as one
  column.

- When multi-layer datasets are detected, each layer becomes a separate
  column (named by layer name from the COG).

**ASC data type:** Australian Soil Classification (ASC) returns
character values (soil order descriptions) instead of numeric codes.

If a request fails (e.g. no internet, API error), that dataset column
will contain `NA` for the affected rows.

## Examples

``` r
if (FALSE) { # interactive()
# Single location
dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-05"), by = "day")
d_t <- collect_tern_data(
  date_range = dates,
  lon = 138.6,
  lat = -34.9,
  datasets = c("SMIPS", "CLY")
)
head(d_t)

# Multiple locations (vectors)
d_t_multi <- collect_tern_data(
  lon = c(138.6, 139.5),
  lat = c(-34.9, -35.5),
  date_range = dates,
  datasets = c("SMIPS", "CANOPY")
)
head(d_t_multi)

# Using xy notation (data.frame)
xy <- data.frame(lon = c(138.6, 139.5), lat = c(-34.9, -35.5))
d_t_xy <- collect_tern_data(
  xy = xy,
  date_range = dates,
  datasets = "CLY"
)
}
```
