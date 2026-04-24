# Read Land Surface Phenology from TERN

Read Australian Land Surface Phenology Cloud Optimised GeoTIFF (COG)
files from TERN. This product provides phenological metrics derived from
MODIS MYD13A1 imagery at 500 m resolution. Data are available for years
2003–2018, with up to two growing seasons per year.

## Usage

``` r
read_phenology(
  year,
  season = 1L,
  collection = "SGS",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- year:

  An integer year (2003–2018).

- season:

  Season number: `1` (default) or `2`.

- collection:

  Phenology metric abbreviation. One of `"SGS"` (default), `"PGS"`,
  `"EGS"`, `"LGS"`, `"SOS"`, `"POS"`, `"EOS"`, `"LOS"`, `"ROG"`, or
  `"ROS"`.

- api_key:

  A `character` string containing your TERN API key. Defaults to
  automatic detection via
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md).

- max_tries:

  An `integer` giving the maximum number of download retries. Defaults
  to `3`.

- initial_delay:

  An `integer` giving the initial retry delay in seconds (doubles with
  each attempt). Defaults to `1`.

## Value

A
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object of the national phenology mosaic for the requested year, season,
and metric.

## Phenology metrics

Ten phenological metrics are available (use as the `collection`
argument):

- `"SGS"`:

  Start of Growing Season (default).

- `"PGS"`:

  Peak of Growing Season.

- `"EGS"`:

  End of Growing Season.

- `"LGS"`:

  Length of Growing Season.

- `"SOS"`:

  Start of Season.

- `"POS"`:

  Peak of Season.

- `"EOS"`:

  End of Season.

- `"LOS"`:

  Length of Season.

- `"ROG"`:

  Rate of Greening.

- `"ROS"`:

  Rate of Senescence.

This is a convenience wrapper around `read_tern("PHENOLOGY", ...)`; see
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for full details and additional datasets.

## References

<https://portal.tern.org.au/metadata/TERN/2bb0c81a-5a09-4a0e-bd86-5cd2be8def26>

## See also

Other COGs:
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
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

# Rate of Greening
r_rog <- read_phenology(year = 2010, collection = "ROG")
}
```
