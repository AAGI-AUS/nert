# Collect TERN Data Over Time and Space

Extract values from one or more TERN datasets at given location(s) over
a given set or range of dates. Returns a `data.table` with one row per
date/location, and one column per dataset requested. (Note that static
datasets are repeated across all dates for consistency.)

## Usage

``` r
collect_tern_data(
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
)
```

## Arguments

- date_range:

  A `Date` vector or `character` vector of length 2,
  `[start_date, end_date]`, indicating the start and end date which
  should be used for the TERN dataset retrieval. (If a vector of length
  greater than 2 is given, this parameter works exactly as `dates`
  does.) Omit if specifying exact dates via the `dates` argument
  instead.

- dates:

  A `Date` vector or `character` vector, indicating the exact set of
  dates for which TERN datasets should be retrieved. Takes precedence
  over `date_range` if supplied.

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

  A `character` vector of dataset aliases to collect. (Default=All
  datasets.) Options: `"SMIPS"`, `"ASC"`, `"AET"`, `"AWC"`, `"CLY"`,
  `"SND"`, `"SLT"`, `"BDW"`, `"PHC"`, `"PHW"`, `"NTO"`, `"AVP"`,
  `"PTO"`, `"CEC"`, `"ECE"`, `"DUL"`, `"L15"`, `"SOILDIV"`, `"CANOPY"`,
  `"PHENOLOGY"`. Use `NULL` (default) or `"all"` to specify retrieval of
  all available datasets.

- depth:

  *For SLGA datasets.* A `character` vector containing the depth
  interval(s) for the SLGA soil attributes to collect. (Default=All
  depths.) Options: `"000_005"`, `"005_015"`, `"015_030"`, `"030_060"`,
  `"060_100"`, `"100_200"`. Use `NULL` (default) or `"all"` to specify
  retrieval of all available depths. This parameter is ignored for
  non-SLGA datasets.

- stat:

  *For SLGA datasets.* A `character` vector containing the statistic to
  retrieve for the SLGA datasets. (Default=All statistics.) Options:
  `"EV"` (estimated value), `"05"` (lower percentile limit for the 95%
  confidence interval), `"95"` (upper percentile limit for the 95%
  confidence interval). Use `NULL` (default) or `"all"` to specify
  retrieval of all statistics. This parameter is ignored for non-SLGA
  datasets.

- smips_collection:

  *For SMIPS datasets.* A `character` vector containing the SMIPS
  datasets to be retrieved. (Default=All SMIPS datasets.) Options:
  `"totalbucket"`, `"SMindex"`, `"bucket1"`, `"bucket2"`, `"deepD"`,
  `"runoff"`. Use `NULL` (default) or `"all"` to specify retrieval of
  all SMIPS datasets. This parameter is ignored for non-SMIPS datasets.

- asc_collection:

  *For ASC datasets.* A `character` vector specifying the Australian
  Soil Classification Map datasets to be retrieved. (Default=All ASC
  datasets.) Options: `"EV"` (estimated soil order), `"CI"` (confusion
  index). Use `NULL` (default) or `"all"` to specify retrieval of all
  ASC datasets.

- aet_collection:

  *For AET datasets.* A `character` vector specifying the Actual
  Evapotranspiration datasets to be retrieved. (Default=All AET
  datasets.) Options: `"ETa"`, `"pixel_qa"` (quality assurance flags).
  Use `NULL` (default) or `"all"` to specify retrieval of all AET
  datasets. This parameter is ignored for non-AET datasets.

- soildiv_collection:

  *For SOILDIV datasets.* A `character` vector specifying the beta soil
  diversity NMDS axes to be retrieved. (Default=All axes/datasets.)
  Options: `"Bacteria_NMDS1"`, `"Bacteria_NMDS2"`, `"Bacteria_NMDS3"`,
  `"Fungi_NMDS1"`, `"Fungi_NMDS2"`, `"Fungi_NMDS3"`. Use `NULL`
  (default) or `"all"` to specify retrieval of all SOILDIV
  axes/datasets.

- phenology_collection:

  *For PHENOLOGY datasets.* A `character` vector specifying the
  phenology datasets to be retrieved. (Default=All PHENOLOGY datasets.)
  Options: `"SGS"`, `"PGS"`, `"EGS"`, `"LGS"`, `"EVI1"`, `"EVI2"`,
  `"EVIP"`, `"EVII"`, `"SGS_month"`, `"PGS_month"`, `"EGS_month"`. Use
  `NULL` (default) or `"all"` to specify retrieval of all PHENOLOGY
  datasets.

- api_key:

  A `character` string containing your TERN API key. Defaults to
  automatic detection from your `.Renviron` or `.Rprofile`. See
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md)
  for setup.

- max_tries:

  Maximum number of download retries before an error is raised.
  Default=`NULL`, in which case the maximum retry number is resolved
  from the option `nert.max_tries` if that option exists. (Defaults to 3
  retries if `nert.max_tries` has not been set.)

- initial_delay:

  Initial retry delay in seconds (doubles with each attempt).
  Default=`NULL`, in which case the initial delay is resolved from the
  option `nert.initial_delay` if that option exists. (Defaults to a 1
  second initial delay if `nert.initial_delay` has not been set.)

- verbose:

  Logical. If `TRUE`, print progress messages. (Default=TRUE.)

- na.rm:

  Logical. If `TRUE`, drop rows where all dataset columns are `NA`.
  (Default=FALSE).

## Value

A `data.table` with the following columns:

- `date`: `Date`.

- `lon`, `lat`: spatial coordinates (always included; constant when a
  single location is requested).

- One column per dataset requested. These dataset columns are named with
  their alias as the prefix (e.g., `SMIPS`, `AWC`, `SOILDIV`), followed
  by any variant information (e.g., depth, statistic, dataset name)
  after an underscore. For example, `SMIPS_totalbucket` for the SMIPS
  "totalbucket" dataset, `CLY_05_000_005` for the lower (05) percentile
  limit of the soil clay at 0-5cm depth, and so on.

## Details

**Failure handling.** Note that if a COG fetch fails (i.e., no
successful download after `max_tries`), the corresponding column(s) will
be set as `NA` for the affected rows, and a
[`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html)
warning is emitted.

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
