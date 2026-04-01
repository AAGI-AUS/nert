# Read Land Surface Phenology Data (MODIS)

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for Land Surface Phenology derived from MODIS NDVI (TERN/2bb0c81a).
Provides annual Start and End of Growing Season for years 2003-2018 at
500 m resolution (static, non-updated product).

## Usage

``` r
read_phenology(
  metric = "SGS",
  year = 2018,
  season = 1,
  api_key = NULL,
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- metric:

  Phenology metric. One of:

  `"SGS"`

  :   Start of Growing Season (default)

  `"EGS"`

  :   End of Growing Season

- year:

  Year (2003-2018, default 2018).

- season:

  Season number (default 1). For most Australian regions, season 1 is
  the primary growing season. Additional seasons may be available for
  select regions.

- api_key:

  A `character` string containing your TERN API key. Defaults to
  automatic detection from your `.Renviron` or `.Rprofile`. See
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md)
  for setup.

- max_tries:

  An `integer` giving the maximum number of download retries before an
  error is raised. Defaults to `3`.

- initial_delay:

  An `integer` giving the initial retry delay in seconds (doubles with
  each attempt). Defaults to `1`.

## Value

A
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object (single layer). Pixel values represent day-of-year for the
specified metric (e.g., 100 = ~April 10 in a non-leap year).

## References

TERN portal: <https://portal.tern.org.au/metadata/TERN/2bb0c81a>

Hill et al. (2017). Land surface phenology and seasonality using
Functional Data Analysis. *Remote Sensing of Environment*, 203, 49-60.

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md)

## Examples

``` r
if (FALSE) { # interactive()
# Start of Growing Season (default: 2018, season 1)
r_sgs_2018 <- read_phenology()
autoplot(r_sgs_2018)

# End of Growing Season, 2018
r_egs_2018 <- read_phenology(metric = "EGS", year = 2018)

# Start of Growing Season, 2015
r_sgs_2015 <- read_phenology(metric = "SGS", year = 2015)

# Start of Growing Season, 2003 (earliest year)
r_sgs_2003 <- read_phenology(metric = "SGS", year = 2003)

# End of Growing Season, 2010, season 2 (if available)
r_egs_s2 <- read_phenology(metric = "EGS", year = 2010, season = 2)
}
```
