# Collect TERN Data Over Time and Space

Extract values from one or more TERN datasets at given location(s) over
a date range. Returns a `data.table` with one row per (date, location)
and one column per dataset layer. Static datasets are repeated across
all dates.

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

  A `Date` vector or character vector of dates (e.g.\\
  `seq(as.Date("2024-01-01"), as.Date("2024-01-31"), by = "day")`) OR a
  length-2 vector giving start and end dates (e.g.\\
  `c("2024-01-01", "2024-01-31")`).

- lon:

  Longitude(s) (WGS84, EPSG:4326). Numeric scalar or vector (same length
  as `lat`). Omit if using `xy` notation.

- lat:

  Latitude(s) (WGS84, EPSG:4326). Numeric scalar or vector (same length
  as `lon`). Omit if using `xy` notation.

- xy:

  Optional: a `data.frame`, `data.table`, or `matrix` with coordinate
  columns named `lon`/`lat` or `x`/`y`. Takes precedence over
  `lon`/`lat` when supplied.

- datasets:

  `character` vector of dataset aliases to collect. Default: all 20
  datasets (SMIPS, ASC, AET, AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO,
  AVP, PTO, CEC, ECE, DUL, L15, SOILDIV, CANOPY, PHENOLOGY). Use `NULL`
  or `"all"` for all datasets.

- depth:

  For SLGA datasets: depth interval (default `"all"`). Options:
  `"000_005"`, `"005_015"`, `"015_030"`, `"030_060"`, `"060_100"`,
  `"100_200"`, or `"all"` for all six GlobalSoilMap depths. Ignored for
  non-SLGA datasets.

- stat:

  For SLGA datasets: `"EV"` (estimate, default) or `"CI"` (confidence
  interval). Ignored for non-SLGA datasets.

- smips_collection:

  For SMIPS: `"all"` (default, all six variants), `"totalbucket"`,
  `"SMindex"`, `"bucket1"`, `"bucket2"`, `"deepD"`, or `"runoff"`.
  Ignored for non-SMIPS datasets.

- api_key:

  TERN API key. Default:
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md).

- verbose:

  Logical. If `TRUE`, print progress messages.

- na.rm:

  Logical. If `TRUE`, drop rows where all dataset columns are `NA`.

## Value

A `data.table` with columns:

- `date`: `Date`.

- `lon`, `lat`: coordinates (always included; constant when a single
  location is requested).

- One column per dataset layer. See **Details** for naming.

## Details

**Vectorised extraction.** For each unique COG required (a (dataset,
date, variant, depth) tuple), the function opens the COG **once** and
calls
[`terra::extract()`](https://rspatial.github.io/terra/reference/extract.html)
**once** with all requested coordinates as a single `SpatVector`.
Returning M locations × N dates across K work items therefore costs K
COG opens and K extract calls, not M × K. Time-series datasets
contribute one work item per date; static datasets contribute one work
item total (the value is replicated across the date axis at output
assembly time).

**Column naming.**

- SMIPS with `smips_collection = "all"`: six columns named
  `SMIPS_totalbucket`, `SMIPS_SMindex`, `SMIPS_bucket1`,
  `SMIPS_bucket2`, `SMIPS_deepD`, `SMIPS_runoff`.

- SMIPS with a single collection: one column `SMIPS_<collection>`.

- SLGA with `depth = "all"`: six columns per dataset (e.g.\\
  `AWC_000_005` ... `AWC_100_200`).

- SLGA with a single depth: one column named for the dataset alias.

- AET: one column `AET`.

- ASC: one column `ASC` (character soil-order class).

- CANOPY, SOILDIV, PHENOLOGY: one column each named for the alias.

**Failure handling.** If a work item's COG fetch or extract fails, the
corresponding column(s) remain `NA` for the affected rows and a
[`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html)
identifies the dataset/date/error. The output schema (column count and
names) is fixed at planning time and is invariant under per-COG failure.

## Examples

``` r
if (FALSE) { # interactive()
# Single location, single dataset
dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-05"), by = "day")
d_t <- collect_tern_data(
  date_range = dates,
  lon = 138.6,
  lat = -34.9,
  datasets = c("SMIPS", "CLY")
)
head(d_t)

# Multiple locations (vectorised across points within each COG)
d_t_multi <- collect_tern_data(
  lon = c(138.6, 139.5),
  lat = c(-34.9, -35.5),
  date_range = dates,
  datasets = c("SMIPS", "CANOPY")
)

# xy data.frame notation
xy <- data.frame(lon = c(138.6, 139.5), lat = c(-34.9, -35.5))
d_t_xy <- collect_tern_data(
  xy = xy,
  date_range = dates,
  datasets = "CLY"
)

}
```
