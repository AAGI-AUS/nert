# Read AET Monthly Evapotranspiration from TERN

Read monthly Actual Evapotranspiration (AET) Cloud Optimised GeoTIFF
(COG) files from TERN. This product is derived from the CMRSET (CSIRO
MODIS Reflectance-based Scaling EvapoTranspiration) algorithm applied to
Landsat imagery, providing Australia-wide monthly actual
evapotranspiration estimates.

## Usage

``` r
read_aet(
  date,
  collection = "ETa",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- date:

  A single date identifying the month to query, e.g.\\ `"2023-06-01"` or
  `as.Date("2023-06-01")`. Both `character` and `Date` classes are
  accepted.

- collection:

  One of `"ETa"` (default) or `"pixel_qa"`.

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
object of the national AET/CMRSET mosaic for the requested month and
collection.

## Details

Two collection layers are available:

- `"ETa"`:

  Actual evapotranspiration in mm per month (default).

- `"pixel_qa"`:

  Quality assurance flags for each pixel.

Data are available from 2000-02-01 onwards. The supplied date is snapped
to the first of the month internally.

This is a convenience wrapper around `read_tern("AET", ...)`; see
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for full details and additional datasets.

## References

<https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>

DOI: [doi:10.25901/gg27-ck96](https://doi.org/10.25901/gg27-ck96)

## See also

Other COGs:
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
# Read monthly actual evapotranspiration
r <- read_aet(date = "2023-06-01")
autoplot(r)

# Read quality assurance layer
r_qa <- read_aet(date = "2023-06-01", collection = "pixel_qa")

# Summer month
r_jan <- read_aet(date = "2024-01-01")
autoplot(r_jan)
}
```
