# Read ASC COGs from TERN

Read Australian Soil Classification (ASC) Cloud Optimised Geotiff (COG)
files from TERN in your R session. The data are Australian Soil
Classification Soil Order classes with quantified estimates of mapping
reliability at a 90 m resolution. You can access the reliability map
using the `confusion_index` argument.

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

  A `Boolean` value indicating whether to read the Confusion Index
  (`TRUE`) or the estimated ASC value (`FALSE`). Defaults to `FALSE`
  reading the ASC values.

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

<https://portal.tern.org.au/metadata/TERN/15728dba-b49c-4da5-9073-13d8abe67d7c>

## See also

Other COGs:
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()

r <- read_asc()
r
}
```
