# Read Soil Beta Diversity from TERN

Read Soil Beta Diversity Cloud Optimised GeoTIFF (COG) files from TERN.
This product provides Non-metric Multidimensional Scaling (NMDS) axes
1–3 for soil Bacteria and Fungi communities across Australia at 90 m
resolution.

## Usage

``` r
read_soil_diversity(
  collection = "Bacteria",
  axis = 1L,
  api_key = get_key(),
  max_tries = NULL,
  initial_delay = NULL
)
```

## Arguments

- collection:

  One of `"Bacteria"` (default) or `"Fungi"`.

- axis:

  NMDS axis number: `1` (default), `2`, or `3`.

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
object of the national Soil Beta Diversity mosaic for the requested
organism and NMDS axis.

## Collections

- `"Bacteria"`:

  Bacterial community beta diversity (default).

- `"Fungi"`:

  Fungal community beta diversity.

This is a static product (no date argument required).

This is a convenience wrapper around `read_tern("SOILDIV", ...)`; see
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for full details and additional datasets.

## References

<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4a428d52-d15c-4bfc-8a67-80697f8c0aa0>

## See also

Other COGs:
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
# Read bacterial diversity NMDS axis 1
r <- read_soil_diversity()
autoplot(r)

# Read fungal diversity NMDS axis 2
r_f2 <- read_soil_diversity(collection = "Fungi", axis = 2)
autoplot(r_f2)
}
```
