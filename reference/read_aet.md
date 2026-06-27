# Read CMRSET Actual Evapotranspiration Data from TERN

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for retrieving the CMRSET actual evapotranspiration data (v2.2) from the
TERN Data Portal. This dataset provides monthly estimates of actual ET
(mm/month) at 30 m resolution from May 1987 onwards, using the CSIRO
MODIS Reflectance-based Scaling Evapotranspiration (CMRSET) algorithm
that combines potential evapotranspiration data from the Bureau of
Meteorology together with satellite image data provided by MODIS, VIIRS,
Landsat and Sentinel-2.

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
  `"pixel_qa"` (quality assurance attributes).

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
object of the requested evapotranspiration collection.

## References

McVicar, T., Vleeshouwer, J., Van Niel, T., Guerschman, J. &
Peña-Arancibia, J. (2022). Actual Evapotranspiration for Australia using
CMRSET algorithm. Version 1.0. Terrestrial Ecosystem Research Network.
(Dataset). [doi:10.25901/gg27-ck96](https://doi.org/10.25901/gg27-ck96)
.

TERM CMRSET Actual Evapotranspiration Point-of-truth metadata URL:
<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/9fefa68b-dbed-4c20-88db-a9429fb4ba97>

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

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

# ET from May 1987 (earliest available)
r_early <- read_aet("1987-05-01")

# Current/recent ET (within last month)
r_recent <- read_aet(Sys.Date())
}
```
