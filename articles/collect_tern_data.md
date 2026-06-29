# collect_tern_data() for bulk TERN dataset collection

The
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
function provides a simple way to extract values from one or more TERN
datasets over multiple locations and dates. And unlike the individual
dataset functions
([`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
etc) which return `SpatRaster` objects, this function returns an
analysis-ready `data.table` object with the extracted point data values.

## Basic usage of collect_tern_data()

As an example, we can use
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
to extract all of the SMIPS soil moisture datasets for a single location
across multiple dates:

``` r

library(nert)

dt <- collect_tern_data(
  date_range = seq(as.Date("2024-01-01"), as.Date("2024-01-04"), by = "day"),
  lon = 138.6,
  lat = -34.9,
  datasets = "SMIPS",
  verbose = TRUE
)
#> ── Datasets to Collect ────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>     Alias            ID                                                             Layer Temporal Resolution
#>    <char>        <char>                                                            <char>   <char>     <char>
#> 1:  SMIPS TERN/d1995ee8 Collection: totalbucket, SMindex, bucket1, bucket2, deepD, runoff    Daily       1 km
#>                                      Description
#>                                           <char>
#> 1: Soil Moisture Integration & Prediction System
#> Collecting 1 dataset at 1 location over 4 dates
#> SMIPS totalbucket 2024-01-01
#> SMIPS totalbucket 2024-01-02
#> SMIPS totalbucket 2024-01-03
#> ...
#> ...
#> SMIPS runoff 2024-01-02
#> SMIPS runoff 2024-01-03
#> SMIPS runoff 2024-01-04
#> Collected 4 rows x 9 columns
head(dt)
#>          date   lon   lat SMIPS_totalbucket SMIPS_SMindex SMIPS_bucket1 SMIPS_bucket2 SMIPS_deepD SMIPS_runoff
#>        <Date> <num> <num>             <num>         <num>         <num>         <num>       <num>        <num>
#> 1: 2024-01-01 138.6 -34.9          18.54933     0.1870453      3.394019      15.15531   0.9680446            0
#> 2: 2024-01-02 138.6 -34.9          18.46742     0.1862194      4.307706      14.15972   0.9044515            0
#> 3: 2024-01-03 138.6 -34.9          15.73218     0.1586381      2.443130      13.28905   0.8488376            0
#> 4: 2024-01-04 138.6 -34.9          14.46397     0.1458499      2.101511      12.36246   0.7896519            0
```

When `verbose = TRUE` (default), a list of the datasets that will be
collected is generated in the output, together with progress messages as
the data points are downloaded.

By default,
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
extracts *all available dataset variants* unless you specify a smaller
subset. For instance, in the above code, we collect all of the available
SMIPS datasets: `"totalbucket"`, `"SMindex"`, `"bucket1"`, `"bucket2"`,
`"deepD"`, and `"runoff"`. Extracting the other datasets works
similarly. If we use
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
to download data for the SLGA available water capacity dataset `"AWC"`,
by default it will download the data for all available depths, as well
as all three statistics (the estimated value `EV`, as well as the 95%
confidence interval limits `05` and `95`):

``` r

dt <- collect_tern_data(
  dates = c("2020-01-01"),
  lon = 138.6,
  lat = -34.9,
  datasets = "AWC",
  verbose = FALSE
)
names(dt)
#>  [1] "date"           "lon"            "lat"            "AWC_EV_000_005" "AWC_EV_005_015" "AWC_EV_015_030" "AWC_EV_030_060"
#>  [8] "AWC_EV_060_100" "AWC_EV_100_200" "AWC_05_000_005" "AWC_05_005_015" "AWC_05_015_030" "AWC_05_030_060" "AWC_05_060_100"
#> [15] "AWC_05_100_200" "AWC_95_000_005" "AWC_95_005_015" "AWC_95_015_030" "AWC_95_030_060" "AWC_95_060_100" "AWC_95_100_200"
```

This ensures that, by default, you get the most comprehensive data for
each dataset. The arguments for
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
can always be used to specify variants where desired. For example, if we
only wanted the estimated value `EV` at 0-5cm and 5-15cm (i.e., depths
`000_005` and `005_015`), we can specify those with the `stat` and
`depth` arguments:

``` r

dt <- collect_tern_data(
  dates = c("2020-01-01"),
  lon = 138.6,
  lat = -34.9,
  datasets = "AWC",
  stat = "EV",
  depth = c("000_005", "005_015"),
  verbose = FALSE
)
names(dt)
#> [1] "date"           "lon"            "lat"            "AWC_EV_000_005" "AWC_EV_005_015"
```

## Efficiently download data points at multiple spatial locations

You can use
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
to extract point values for multiple spatial locations, each provided by
a longitude/latitude pair. The function will perform the bulk download
across spatial locations efficiently, making streaming data from the
fetched COGs *only once*, regardless of the number of locations you have
requested.

For example, the below R code extracts SMIPS `"SMindex"` data and canopy
height information across three locations and a range of dates. The
output `data.table` will contain one row per location/date combination.

``` r

dt_multi <- collect_tern_data(
  lon = c(138.6, 139.5, 140.1),
  lat = c(-34.9, -35.2, -34.5),
  date_range = c("2024-01-01", "2024-01-05"),
  datasets = c("SMIPS", "CANOPY"),
  smips_collection = "SMindex",
  verbose = FALSE
)
head(dt_multi)
#>          date   lon   lat SMIPS_SMindex CANOPY
#>        <Date> <num> <num>         <num>  <num>
#> 1: 2024-01-01 138.6 -34.9    0.18704529      9
#> 2: 2024-01-01 139.5 -35.2    0.18135567      0
#> 3: 2024-01-01 140.1 -34.5    0.02390325      6
#> 4: 2024-01-02 138.6 -34.9    0.18621944      9
#> 5: 2024-01-02 139.5 -35.2    0.16365331      0
#> 6: 2024-01-02 140.1 -34.5    0.02078163      6
```

For convenience, you can also provide the longitude and latitude
coordinates as columns `lon`, `lat` inside a `data.frame`. You can then
pass this to the `xy` argument in the
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
call:

``` r

locations <- data.frame(
  lon = c(138.6, 139.5, 140.1),
  lat = c(-34.9, -35.2, -34.5)
)

dt_xy <- collect_tern_data(
  xy = locations,
  date_range = "2024-01-15",
  datasets = c("ASC"),
  asc_collection = "EV",
  verbose = FALSE
)
dt_xy
#>          date   lon   lat          ASC_EV
#>        <Date> <num> <num>          <char>
#> 1: 2024-01-15 138.6 -34.9     2 - Sodosol
#> 2: 2024-01-15 139.5 -35.2     7 - Tenosol
#> 3: 2024-01-15 140.1 -34.5 12 - Calcarasol
```

## Graceful handling of failed dataset fetches

If the download for one of the datasets fails (e.g., due to a network
error), that column will simply contain `NA` for the affected rows. The
function will then continue downloading the other datasets as normal.
That is, download failures are handled gracefully: a download error for
one of the datasets does not stop the entire call.

You can specify `na.rm = TRUE` in the
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
call, which will remove rows where all of the dataset columns were `NA`.
