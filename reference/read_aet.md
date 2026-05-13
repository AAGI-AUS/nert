# Read CMRSET Actual Evapotranspiration Data

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for TERN/CMRSET evapotranspiration data. Provides monthly estimates of
actual ET (mm/month) at 30 m resolution from February 2000 onwards.

## Usage

``` r
read_aet(
  date,
  collection = "ETa",
  api_key = NULL,
  max_tries = NULL,
  initial_delay = NULL
)
```

## Arguments

- date:

  A month to download (Date or character, e.g. `"2023-06-01"` or
  `as.Date("2023-06-01")`). The value is snapped to the first of the
  month internally. Required.

- collection:

  One of `"ETa"` (actual evapotranspiration in mm/month, default) or
  `"pixel_qa"` (quality assurance flags).

- api_key:

  A `character` string containing your TERN API key. Defaults to
  automatic detection from your `.Renviron` or `.Rprofile`. See
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md)
  for setup.

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
object of the requested ET collection.

## References

CMRSET portal:
<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/9fefa68b-dbed-4c20-88db-a9429fb4ba97>

CMRSET DOI: [doi:10.25901/gg27-ck96](https://doi.org/10.25901/gg27-ck96)

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md),
[`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md)

## Examples

``` r
if (FALSE) { # interactive()
# Actual evapotranspiration (ETa) for June 2023 (mm/month)
r_eta <- read_aet("2023-06-01")
autoplot(r_eta)

# January 2023 ET
r_jan <- read_aet("2023-01-01")

# Quality assurance flags for June 2023
r_qa <- read_aet("2023-06-01", collection = "pixel_qa")

# ET from February 2000 (earliest available)
r_early <- read_aet("2000-02-01")

# Current/recent ET (within last month)
r_recent <- read_aet(Sys.Date())
}
```
