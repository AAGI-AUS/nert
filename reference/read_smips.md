# Read SMIPS COGs from TERN

Read Soil Moisture Integration and Prediction System (SMIPS) Cloud
Optimised Geotiff (COG) files from TERN in your R session.

## Usage

``` r
read_smips(
  day,
  collection = "totalbucket",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- day:

  A date to query, *e.g.*, `day = "2017-12-31"` or
  `day = as.Date("2017-12-01")`, both `Character` and `Date` classes are
  accepted.

- collection:

  A character vector of the “SMIPS” data collection to be queried:

  - SMindex: the SMIPS Soil Moisture Index (*i.e.*, a number between 0
    and 1 that indicates how full the SMIPS bucket moisture store is
    relative to its 90 cm capacity),

  - totalbucket: an estimate of the *volumetric soil moisture (in mm)
    from the SMIPS bucket moisture store*, Defaults to “totalbucket”.
    Multiple `collections` are supported, *e.g.*,
    `collection = c("SMindex", "totalbucket")`.

- api_key:

  A `character` string containing your API key, a random string provided
  to you by TERN, for the request. Defaults to automatically detecting
  your key from your local .Renviron, .Rprofile or similar.
  Alternatively, you may directly provide your key as a string here or
  use functionality like that from
  [keyring](https://CRAN.R-project.org/package=keyring). If nothing is
  provided, you will be prompted on how to set up your R session so that
  it is auto-detected and a browser window will open at the TERN website
  for you to request a key.

- max_tries:

  An integer `Integer` with the number of times to retry a failed
  download before emitting an error message. Defaults to 3.

- initial_delay:

  An `Integer` with the number of seconds to delay before retrying the
  download. This increases as the tries increment. Defaults to 1.

## Value

A
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object.

## References

<https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>
and
<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>

## See also

Other COGs:
[`extract_aet()`](https://aagi-aus.github.io/nert/reference/extract_aet.md),
[`read_aet()`](https://aagi-aus.github.io/nert/reference/read_aet.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md)

## Examples

``` r
if (FALSE) { # interactive()

r <- read_smips("2024-01-01")

# `tidyterra::autoplot` is re-exported for convenience
autoplot(r)
}
```
