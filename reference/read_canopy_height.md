# Read Canopy Height from TERN

Read the OzTreeMap Canopy Height composite Cloud Optimised GeoTIFF (COG)
from TERN. This product provides a nationwide canopy height map at 30 m
resolution derived from Landsat imagery.

## Usage

``` r
read_canopy_height(api_key = get_key(), max_tries = NULL, initial_delay = NULL)
```

## Arguments

- api_key:

  A `character` string containing your TERN API key. Defaults to
  automatic detection via
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md).

- max_tries:

  Maximum number of download retries before an error is raised. When
  `NULL` (default), resolved from `getOption("nert.max_tries", 3L)`.
  Pass an integer to override for a single call.

- initial_delay:

  Initial retry delay in seconds (doubles with each attempt). When
  `NULL` (default), resolved from `getOption("nert.initial_delay", 1L)`.
  Pass an integer to override for a single call.

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

<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/36c98155-c137-44b8-b4e0-6a3e824bbfba>

## See also

Other COGs:
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
r <- read_canopy_height()
autoplot(r)
}
```
