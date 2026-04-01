# Read SLGA Soil and Landscape Grid of Australia Attributes

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for Soil and Landscape Grid of Australia (SLGA) soil attribute products
at 90 m resolution. Access any of 8 soil properties (Available Water
Capacity, Clay, Sand, Silt, Bulk Density, pH CaCl2, pH water, Total
Nitrogen) at 6 standard depth intervals (0-5, 5-15, 15-30, 30-60,
60-100, 100-200 cm), with optional confidence intervals.

## Usage

``` r
read_slga(
  collection,
  depth = "000_005",
  stat = "EV",
  api_key = NULL,
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- collection:

  Soil attribute code. One of: `"AWC"` (Available Volumetric Water
  Capacity), `"CLY"` (Clay), `"SND"` (Sand), `"SLT"` (Silt), `"BDW"`
  (Bulk Density), `"PHC"` (pH CaCl2), `"PHW"` (pH water), or `"NTO"`
  (Total Nitrogen). Required.

- depth:

  Depth interval (default `"000_005"` = 0-5 cm). Options: `"000_005"`,
  `"005_015"`, `"015_030"`, `"030_060"`, `"060_100"`, `"100_200"`. Use
  `"all"` to return all 6 depths stacked as a multi-layer SpatRaster.

- stat:

  Statistic. One of `"EV"` (estimate, default) or `"CI"` (confidence
  interval).

- api_key:

  A `character` string containing your TERN API key. Defaults to
  automatic detection from your `.Renviron` or `.Rprofile`. See
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md)
  for setup.

- max_tries:

  An `integer` giving the maximum number of download retries before an
  error is raised. Defaults to `3`.

- initial_delay:

  An `integer` giving the initial retry delay in seconds (doubles with
  each attempt). Defaults to `1`.

## Value

A
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object. Single depth: one layer. When `depth = "all"`: a 6-layer raster
with names (`"{collection}_000_005"`, etc.).

## References

SLGA portal: <https://www.tern.org.au/landscapes/slga/>

Viscarra Rossel, R. A., et al. (2015). Soil and Landscape Grid of
Australia. *Soil Research*, 53(8), 835-844.

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md),
[`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md)

## Examples

``` r
if (FALSE) { # interactive()
# Available Water Capacity at 0-5 cm (default depth)
r_awc <- read_slga("AWC")
autoplot(r_awc)

# Clay at specific depth (15-30 cm)
r_clay_30 <- read_slga("CLY", depth = "015_030")

# Clay at deep layer (100-200 cm)
r_clay_deep <- read_slga("CLY", depth = "100_200")

# Available Water Capacity, all 6 depths stacked
r_awc_all <- read_slga("AWC", depth = "all")
names(r_awc_all)
# [1] "AWC_000_005" "AWC_005_015" "AWC_015_030" "AWC_030_060" "AWC_060_100" "AWC_100_200"

# Sand content with confidence intervals
r_sand_ci <- read_slga("SND", depth = "005_015", stat = "CI")

# pH (water) estimate
r_phw <- read_slga("PHW", stat = "EV")

# Bulk Density at all depths
r_bdw_all <- read_slga("BDW", depth = "all", stat = "EV")
}
```
