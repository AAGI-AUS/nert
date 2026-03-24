# Read AET COGs from TERN

Read Actual Evapotranspiration (AET) using the CMRSET algorithm Cloud
Optimised Geotiff (COG) files from TERN in your R session.

## Usage

``` r
read_aet(
  month,
  collection = "ETa",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- month:

  A month to query, *e.g.,* `month = "2023-01-01"` or
  `month = as.Date("2023-01-01")`. Both `Character` and `Date` classes
  are accepted. The value is snapped to the first of the month
  internally.

- collection:

  A `character` string of the AET data collection to be queried:

  - `"ETa"`: the primary AET band (mm/month),

  - `"pixel_qa"`: the quality assurance flag band. Defaults to `"ETa"`.

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

  An `Integer` with the number of times to retry a failed download
  before emitting an error message. Defaults to 3.

- initial_delay:

  An `Integer` with the number of seconds to delay before retrying the
  download. This increases as the tries increment. Defaults to 1.

## Value

A
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object of the national mosaic for the requested month.

## References

TERN portal:
<https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>

DOI: <https://dx.doi.org/10.25901/gg27-ck96>

## See also

Other COGs:
[`extract_aet()`](https://aagi-aus.github.io/nert/reference/extract_aet.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md)

## Examples

``` r
if (FALSE) { # interactive()

r <- read_aet(month = "2023-01-01")

# `tidyterra::autoplot` is re-exported for convenience
autoplot(r)
}
```
