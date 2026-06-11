# Read Land Surface Phenology from TERN

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for retrieving the Australian land surface phenology dataset (v1.0) from
the TERN Data Portal. This data comprises phenology metrics from two
growing seasons per year between 2003 and 2018 (inclusive), estimated at
500m X 500m spatial resolution across all of Australia using thresholded
MODIS Enhanced Vegetation Index (EVI) imagery.

## Usage

``` r
read_phenology(
  year = NULL,
  season = 1L,
  collection = "SGS",
  api_key = get_key(),
  max_tries = NULL,
  initial_delay = NULL
)
```

## Arguments

- year:

  An integer year (2003–2018).

- season:

  Season number: `1` (default) or `2`.

- collection:

  Phenology metric abbreviation. One of `"SGS"` (default), `"PGS"`,
  `"EGS"`, `"LGS"`, `"EVI1"`, `"EVI2"`, `"EVIP"`, `"EVII"`,
  `"SGS_month"`, `"PGS_month"` or `"EGS_month"`.

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

## Value

A
[terra::SpatRaster](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object of the requested phenology metric.

## Phenology metrics

Eleven phenological metrics are available via the `collection` argument:

- `"SGS"`:

  **Start of Growing Season** (default). A number between -150 and 345
  indicating the start of the growing season (with negative numbers
  meaning the prior year).

- `"PGS"`:

  **Peak of Growing Season**. A number between 9 and 361 indicating the
  day of the year for the peak of the growing season.

- `"EGS"`:

  **End of Growing Season**. A number between 25 and 519 indicating the
  day of the year that marks the end of the growing season, with numbers
  above 365 (or 366 for leap years) meaning the following year.

- `"LGS"`:

  **Length of Growing Season**, measured in days.

- `"EVI1"`:

  **Minimum of EVI before peak**. A unitless index between 0 and 10000
  (i.e., scaled by 10000) for the minimum value of the Enhanced
  Vegetation Index *before* the peak of the growing season.

- `"EVI2"`:

  **Minimum of EVI after peak**. A unitless index between 0 and 10000
  (i.e., scaled by 10000) for the minimum value of the Enhanced
  Vegetation Index *after* the peak of the growing season.

- `"EVIP"`:

  **Peak EVI**. A unitless index between 0 and 10000 (i.e., scaled
  by 10000) for the value of the Enhanced Vegetation Index *at* the peak
  of the growing season.

- `"EVII"`:

  **Integral of the EVI across the season**. The calculated integral of
  the Enhanced Vegetation Index (including the factor of 10000 scaling)
  under the growing season cycle curve.

- `"SGS_month"`:

  **Start of the growing season by month**. A number between 1 and 12,
  indicating the month for the start of the growing season (i.e., the
  `"SGS"` metric but reprocessed to monthly time resolution).

- `"PGS_month"`:

  **Peak of the growing season by month**. A number between 1 and 12,
  indicating the month for the peak of the growing season (i.e., the
  `"PGS"` metric but reprocessed to monthly time resolution).

- `"EGS_month"`:

  **End of the growing season by month**. A number between 1 and 12,
  indicating the month for the end of the growing season (i.e., the
  `"EGS"` metric but reprocessed to monthly time resolution).

## References

Xie, Q. & Huete, A. (2024). Australian land surface phenology dataset at
500m resolution. Version 1.0. Terrestrial Ecosystem Research Network.
(Dataset). URL:
<https://portal.tern.org.au/metadata/2bb0c81a-41a9-434c-b87a-db0301cb52fb>.

TERN Land Surface Phenology Point-of-truth metadata URL:
<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/2bb0c81a-41a9-434c-b87a-db0301cb52fb>

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
# Read Start of Growing Season for 2018, Season 1
r <- read_phenology(year = 2018)
autoplot(r)

# Read End of Growing Season for 2015, Season 2
r_egs <- read_phenology(year = 2015, season = 2, collection = "EGS")
autoplot(r_egs)
}
```
