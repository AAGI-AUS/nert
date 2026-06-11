# Read OzTreeMap Canopy Height Data from TERN

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for retrieving the OzTreeMap Best-Pick Canopy Height model dataset from
the TERN Data Portal. The model estimates the vegetation canopy height
(in metres) at 30m X 30m spatial resolution across Australia, based on
underlying ML-derived vegetation models tuned to variable time periods
between 2007 and 2020.

## Usage

``` r
read_canopy_height(api_key = get_key(), max_tries = NULL, initial_delay = NULL)
```

## Arguments

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
object of the requested vegetation canopy height. Note that the raster
returned by this function uses the Australian Albers (EPSG:3577)
coordinate reference system, not WGS84 (EPSG:4326).

## References

Pucino, N., McVicar, T., Levick, S. & Albert van Dijk (2025).
Australia-Wide 30 m Machine Learning-Derived Canopy Height Models
Composites: Best Pick and Median. Version 1. Terrestrial Ecosystem
Research Network. (Dataset).
[doi:10.25901/xqv7-jk46](https://doi.org/10.25901/xqv7-jk46) .

TERN Canopy Height model Point-of-truth metadata URL:
<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/36c98155-39c8-4eec-9070-a978933f3fa3>

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
r <- read_canopy_height()
autoplot(r)
}
```
