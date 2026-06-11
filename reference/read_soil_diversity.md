# Read Soil Beta Diversity from TERN

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for retrieving the v1.0 datasets for soil bacteria and soil fungi Beta
Diversity from the TERN Data Portal. The Beta Diversity datasets were
constructed using Digital Soil Mapping techniques together with Biome of
Australia Soil Environments (BASE) DNA sequences, and provide Non-metric
MultiDimensional Scaling (NMDS) axes for soil bacteria and fungi at 90m
X 90m spatial resolution across Australia.

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
object of the requested Beta Diversity NMDS axis.

## References

Dobarco, M., Wadoux, A. & Xue, P. (2024). Soil and Landscape Grid
National Soil Attribute Maps - Soil Bacteria and Fungi Beta Diversity
(3" resolution) - Release 1. Version 1.0. Terrestrial Ecosystem Research
Network. (Dataset).
[doi:10.25919/4x7n-y874](https://doi.org/10.25919/4x7n-y874) .

TERN Soil Beta Diversity Point-of-truth metadata URL:
<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4a428d52-dda6-4097-8dd9-d3ec63973029>

## See also

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
