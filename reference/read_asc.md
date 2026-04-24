# Read ASC Soil Classification from TERN

Read Australian Soil Classification (ASC) Cloud Optimised GeoTIFF (COG)
files from TERN in your R session. The data are Australian Soil
Classification Soil Order classes with quantified estimates of mapping
reliability at a 90 m resolution.

## Usage

``` r
read_asc(
  confusion_index = FALSE,
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
)
```

## Source

- ASC Data:

  <https://data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/ASC_EV_C_P_AU_TRN_N.cog.tif>

- Confusion Index:

  <https://data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/ASC_CI_C_P_AU_TRN_N.cog.tif>

## Arguments

- confusion_index:

  A `logical` value indicating whether to read the Confusion Index
  (`TRUE`) or the estimated ASC value (`FALSE`). Defaults to `FALSE`.

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
object of the national ASC mosaic.

## Details

Two collection layers are available:

- `"EV"`:

  Estimated soil order class (default).

- `"CI"`:

  Confusion index — a measure of mapping reliability.

This is a static product (no date argument required).

This is a convenience wrapper; you can also call `read_tern("ASC")` —
see
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for the unified interface and additional datasets.

## References

<https://portal.tern.org.au/metadata/TERN/15728dba-b49c-4da5-9073-13d8abe67d7c>

## See also

Other COGs:
[`read_aet()`](https://aagi-aus.github.io/nert/reference/read_aet.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
# Read estimated ASC soil order class
r <- read_asc()
autoplot(r)

# Read confusion index (mapping reliability)
r_ci <- read_asc(confusion_index = TRUE)
autoplot(r_ci)
}
```
