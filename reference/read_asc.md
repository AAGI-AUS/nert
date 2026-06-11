# Read Australian Soil Classification (ASC) Data from TERN

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for retrieving Australian Soil Classification (ASC) soil order classes
from the TERN Data Portal. The ASC dataset provides a comprehensive map
at 90m X 90m spatial resolution across Australia, mapping each spatial
pixel to one of 14 soil order classes using a Random Forest classifier.
The dataset also provides a confusion index raster that estimates the
uncertainty (between 0.0 and 1.0) associated with the classification.

## Usage

``` r
read_asc(
  collection = "EV",
  api_key = get_key(),
  max_tries = NULL,
  initial_delay = NULL
)
```

## Arguments

- collection:

  The ASC dataset collection variant (default `"EV"`). Options:

  `"EV"`

  :   **(Estimated) Soil Order Class** (character). The estimated ASC
      soil order class. Each pixel of the raster maps to one of 14 soil
      order classes: Vertosol, Sodosol, Dermosol, Chromosol, Ferrosol,
      Kurosol, Tenosol, Kandosol, Hydrosol, Podosol, Rudosol,
      Calcarasol, Organosol, Anthroposol.

  `"CI"`

  :   **Confusion Index** (0-1). A unitless index between 0.0 and 1.0,
      approximating the uncertainty of the Random Forest classification
      for the soil order at each pixel. (A higher value of the confusion
      index means that the classification at that pixel is more
      uncertain.)

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
object containing the soil order classes (or the values of the confusion
index).

## References

Searle, R. (2021). Australian Soil Classification Map. Version 1.
Terrestrial Ecosystem Research Network. (Dataset).
[doi:10.25901/edyr-wg85](https://doi.org/10.25901/edyr-wg85) .

TERN ASC Point-of-truth metadata URL:
<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/15728dba-b49c-4da5-9073-13d8abe67d7c>

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
# Australian Soil Classification (soil orders as character)
r_asc <- read_asc()
autoplot(r_asc)

# Confusion Index (uncertainty of the classification, higher=more uncertain)
r_ci <- read_asc(collection = "CI")
autoplot(r_ci)
}
```
