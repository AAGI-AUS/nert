# Extract AET Values at Point Locations

Extract Actual Evapotranspiration (AET) values from the CMRSET algorithm
data at point locations and return a
[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).

## Usage

``` r
extract_aet(
  xy,
  month,
  collection = "ETa",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- xy:

  Point locations in one of three formats:

  - A named list, *e.g.,* `list("Corrigin" = c(x = 117.87, y = -32.33))`

  - A `data.frame` with columns `location`, `x` (longitude), and `y`
    (latitude)

  - An [sf::sf](https://r-spatial.github.io/sf/reference/sf.html) POINT
    object with a `location` column

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
[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html)
with columns `location`, `x`, `y`, and `aet_{collection}_{YYYYMM}`
(*e.g.,* `aet_ETa_202301`).

## References

TERN portal:
<https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>

DOI: <https://dx.doi.org/10.25901/gg27-ck96>

## See also

Other COGs:
[`read_aet()`](https://aagi-aus.github.io/nert/reference/read_aet.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md)

## Examples

``` r
if (FALSE) { # interactive()

locs <- list(
  "Corrigin" = c(x = 117.87, y = -32.33),
  "Merredin" = c(x = 118.28, y = -31.48),
  "Tamworth" = c(x = 150.84, y = -31.07)
)
tab <- extract_aet(xy = locs, month = "2023-01-01")
tab
}
```
