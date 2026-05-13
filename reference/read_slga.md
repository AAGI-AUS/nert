# Read SLGA Soil Attributes from TERN

Read Soil and Landscape Grid of Australia (SLGA) Cloud Optimised GeoTIFF
(COG) files from TERN. Eight soil attributes are available as static 90
m national products, each with six standard depth layers and two
statistics (estimated value or confidence interval).

## Usage

``` r
read_slga(
  attribute,
  depth = "000_005",
  collection = "EV",
  api_key = get_key(),
  max_tries = NULL,
  initial_delay = NULL
)
```

## Arguments

- attribute:

  One of `"AWC"`, `"CLY"`, `"SND"`, `"SLT"`, `"BDW"`, `"PHC"`, `"PHW"`,
  or `"NTO"`.

- depth:

  One of `"000_005"` (default), `"005_015"`, `"015_030"`, `"030_060"`,
  `"060_100"`, or `"100_200"`.

- collection:

  One of `"EV"` (estimated value, default) or `"CI"` (confidence
  interval).

- api_key:

  A `character` string containing your TERN API key. Defaults to
  automatic detection via
  [`get_key()`](https://aagi-aus.github.io/nert/reference/get_key.md).

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
object of the national SLGA mosaic for the requested attribute, depth,
and statistic.

## Supported attributes

- `"AWC"`:

  Available Water Capacity (mm)

- `"CLY"`:

  Clay content (percent)

- `"SND"`:

  Sand content (percent)

- `"SLT"`:

  Silt content (percent)

- `"BDW"`:

  Bulk Density whole earth (g/cm3)

- `"PHC"`:

  pH (CaCl2)

- `"PHW"`:

  pH (water)

- `"NTO"`:

  Total Nitrogen (percent)

## Depth layers

Six standard GlobalSoilMap depth intervals are available (values in cm):

|                                |
|--------------------------------|
| `"000_005"` — 0–5 cm (default) |
| `"005_015"` — 5–15 cm          |
| `"015_030"` — 15–30 cm         |
| `"030_060"` — 30–60 cm         |
| `"060_100"` — 60–100 cm        |
| `"100_200"` — 100–200 cm       |
|                                |

This is a convenience wrapper around `read_tern(<attribute>, ...)`; see
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for full details and additional datasets.

## References

AWC:
<https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/482301c2-2837-4b0b-bf95-4883a04e5ff7>

SLGA: <https://esoil.io/TERNLandscapes/Public/Pages/SLGA/>

## See also

Other COGs:
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
# Read clay content at 0-5 cm depth
r <- read_slga("CLY")
autoplot(r)

# Read available water capacity at 15-30 cm
r_awc <- read_slga("AWC", depth = "015_030")

# Read pH (CaCl2) confidence interval at 30-60 cm
r_phc <- read_slga("PHC", depth = "030_060", collection = "CI")
}
```
