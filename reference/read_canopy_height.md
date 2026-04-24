# Read Canopy Height from TERN

Read the OzTreeMap Canopy Height composite Cloud Optimised GeoTIFF (COG)
from TERN. This product provides a nationwide canopy height map at 30 m
resolution derived from Landsat imagery.

## Usage

``` r
read_canopy_height(api_key = get_key(), max_tries = 3L, initial_delay = 1L)
```

## Arguments

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
object of the national OzTreeMap canopy height composite.

## Details

This is a single static product — no date or collection arguments are
required.

This is a convenience wrapper around `read_tern("CANOPY")`; see
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for full details and additional datasets.

## References

<https://portal.tern.org.au/metadata/TERN/36c98155-c137-44b8-b4e0-6a3e824bbfba>

## See also

Other COGs:
[`read_aet()`](https://aagi-aus.github.io/nert/reference/read_aet.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
r <- read_canopy_height()
autoplot(r)
}
```
