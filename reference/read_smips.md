# Read SMIPS Soil Moisture Data from TERN

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for retrieving the SMIPS v1.0 daily soil moisture data from the TERN
Data Portal. SMIPS provides soil moisture estimates at roughly 1km X 1km
spatial resolution across Australia, updated approximately daily on the
TERN server. The earliest available raster depends on the collection:
the `"totalbucket"` and `"SMindex"` collections are archived from 2005,
while the four bucket-level collections (`"bucket1"`, `"bucket2"`,
`"deepD"`, `"runoff"`) are available from 1st January 2015.

## Usage

``` r
read_smips(
  date,
  collection = "totalbucket",
  api_key = NULL,
  max_tries = NULL,
  initial_delay = NULL
)
```

## Arguments

- date:

  A day to download (Date or character, e.g. `"2024-01-15"` or
  `as.Date("2024-01-15")`).

- collection:

  SMIPS collection variant (default `"totalbucket"`). Options:

  `"totalbucket"`

  :   **Soil moisture of the 0-90cm two-bucket store** (mm). An estimate
      of the volumetric soil moisture of the complete 0-90cm SMIPS
      two-bucket soil moisture store.

  `"SMindex"`

  :   **Soil moisture index, 0-1**. A unitless index between 0.0 and
      1.0, approximating how full the complete SMIPS 0-90cm soil
      moisture two-bucket store is.

  `"bucket1"`

  :   **Soil moisture in the upper 0-10cm bucket** (mm). An estimate of
      the volumetric soil moisture of the upper 0-10cm soil bucket.

  `"bucket2"`

  :   **Soil moisture in the lower 10-90cm bucket** (mm). An estimate of
      the volumetric soil moisture of the lower 10-90cm soil bucket.

  `"deepD"`

  :   **Drainage between two buckets** (mm). An estimate of the drainage
      from the upper 0-10cm soil bucket through to the lower 10-90cm
      bucket.

  `"runoff"`

  :   **Runoff/overtopping moisture loss** (mm). An estimate of the
      moisture lost from the top 0-10cm bucket due to runoff or
      overtopping.

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
object of the requested SMIPS collection.

## References

Stenson, M., Searle, R., Malone, B., Sommer, A., Renzullo, L. & Di, H.
(2021): Australia wide daily volumetric soil moisture estimates. Version
1.0. Terrestrial Ecosystem Research Network. (Dataset).
[doi:10.25901/b020-nm39](https://doi.org/10.25901/b020-nm39) .

TERN SMIPS Point-of-truth metadata URL:
<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
# Total volumetric soil moisture across both buckets (default)
r <- read_smips("2024-01-15")
autoplot(r)

# Soil moisture index (0-1)
r_smi <- read_smips("2024-01-15", collection = "SMindex")

# Upper soil bucket
r_bucket1 <- read_smips("2024-01-15", collection = "bucket1")

# Lower soil bucket
r_bucket2 <- read_smips("2024-01-15", collection = "bucket2")

# Drainage between upper and lower buckets
r_deep <- read_smips("2024-01-15", collection = "deepD")

# Top bucket runoff
r_runoff <- read_smips("2024-01-15", collection = "runoff")
}
```
