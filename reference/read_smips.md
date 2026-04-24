# Read SMIPS Daily Soil Moisture from TERN

Read daily Soil Moisture Information from Pedotransfer functions and
Satellite data (SMIPS) Cloud Optimised GeoTIFF (COG) files from TERN.
SMIPS provides Australia-wide volumetric soil moisture estimates at
approximately 1 km (0.01 degree) resolution, derived from a combination
of satellite observations and pedotransfer modelling.

## Usage

``` r
read_smips(
  date,
  collection = "totalbucket",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- date:

  A single date to query, e.g.\\ `"2024-01-15"` or
  `as.Date("2024-01-15")`. Both `character` and `Date` classes are
  accepted.

- collection:

  One of `"totalbucket"` (default), `"SMindex"`, `"bucket1"`,
  `"bucket2"`, `"deepD"`, or `"runoff"`.

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
object of the national SMIPS mosaic for the requested day and
collection.

## Details

Six collection layers are available:

- `"totalbucket"`:

  Total column soil moisture (0–90 cm) in mm (default).

- `"SMindex"`:

  Soil moisture index expressed as a percentage.

- `"bucket1"`:

  Upper layer moisture (0–10 cm) in mm.

- `"bucket2"`:

  Lower layer moisture (10–90 cm) in mm.

- `"deepD"`:

  Deep drainage flux in mm.

- `"runoff"`:

  Surface runoff in mm.

Data are available from 2015-11-20 (`totalbucket` from 2005) to
approximately 7 days before today.

This is a convenience wrapper around `read_tern("SMIPS", ...)`; see
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for full details and additional datasets.

## References

<https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>

## See also

Other COGs:
[`read_aet()`](https://aagi-aus.github.io/nert/reference/read_aet.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
# Read total bucket soil moisture for a specific day
r <- read_smips(date = "2024-01-15")
autoplot(r)

# Read soil moisture index
r_smi <- read_smips(date = "2024-01-15", collection = "SMindex")

# Upper layer moisture only
r_b1 <- read_smips(date = "2024-06-01", collection = "bucket1")
}
```
