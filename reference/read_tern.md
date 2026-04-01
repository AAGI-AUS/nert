# Read TERN COG Datasets

A unified interface for reading Cloud Optimised GeoTIFF (COG) data from
TERN and related repositories. Dispatches to a dataset-specific handler
based on `dataset_id` and passes any additional arguments through `...`.
The returned object is a
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
that can be plotted, cropped, or extracted with standard terra or
tidyterra workflows.

## Usage

``` r
read_tern(dataset_id, ..., api_key = NULL, max_tries = 3L, initial_delay = 1L)
```

## Arguments

- dataset_id:

  A `character` string identifying the dataset. Accepts the full TERN
  portal key (e.g.\\ `"TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0"`), the
  8-character key prefix (e.g.\\ `"TERN/d1995ee8"`), or a short alias
  (e.g.\\ `"SMIPS"`, `"AWC"`). Currently supported datasets:

  |               |                                                |
  |---------------|------------------------------------------------|
  | **Alias**     | **Dataset**                                    |
  | `"SMIPS"`     | Daily soil moisture (1 km, 2015-present)       |
  | `"ASC"`       | Australian Soil Classification (90 m, static)  |
  | `"AET"`       | Evapotranspiration/CMRSET (30 m, 2000-present) |
  | `"AWC"`       | SLGA Available Water Capacity (90 m, 6 depths) |
  | `"CLY"`       | SLGA Clay content (90 m, 6 depths)             |
  | `"SND"`       | SLGA Sand content (90 m, 6 depths)             |
  | `"SLT"`       | SLGA Silt content (90 m, 6 depths)             |
  | `"BDW"`       | SLGA Bulk Density (90 m, 6 depths)             |
  | `"PHC"`       | SLGA pH (CaCl2) (90 m, 6 depths)               |
  | `"PHW"`       | SLGA pH (water) (90 m, 6 depths)               |
  | `"NTO"`       | SLGA Total Nitrogen (90 m, 6 depths)           |
  | `"SOILDIV"`   | Soil Beta Diversity (90 m, static)             |
  | `"CANOPY"`    | Canopy Height (30 m, static)                   |
  | `"PHENOLOGY"` | Land Surface Phenology (500 m, 2003-2018)      |

- ...:

  Dataset-specific arguments – `date`, `collection`, etc. See the
  relevant section above for each dataset.

- api_key:

  A `character` string containing your TERN API key. Defaults to
  automatic detection from your `.Renviron` or `.Rprofile`. See
  [`get_key`](https://aagi-aus.github.io/nert/reference/get_key.md) for
  setup instructions.

- max_tries:

  An `integer` giving the maximum number of download retries before an
  error is raised. Defaults to `3`.

- initial_delay:

  An `integer` giving the initial retry delay in seconds (doubles with
  each attempt). Defaults to `1`.

## Value

A
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object of the national mosaic for the requested dataset (and, where
applicable, date/collection).

## SMIPS – daily soil moisture (`"TERN/d1995ee8"`)

- `date`:

  Required. A single day to query, *e.g.* `"2024-01-15"` or
  `as.Date("2024-01-15")`. Both `Character` and `Date` classes are
  accepted.

- `collection`:

  One of `"totalbucket"` (default), `"SMindex"`, `"bucket1"`,
  `"bucket2"`, `"deepD"`, or `"runoff"`.

Data availability: 2015-11-20 to approximately 7 days before today.

## ASC – Australian Soil Classification (`"TERN/15728dba"`)

- `collection`:

  One of `"EV"` (estimated soil order class, default) or `"CI"`
  (confusion index – a measure of mapping reliability). No `date`
  argument required; this is a static product.

## AET – Actual Evapotranspiration/CMRSET (`"TERN/9fefa68b"`)

- `date`:

  Required. A month to query, *e.g.* `"2023-06-01"` or
  `as.Date("2023-06-01")`. Both `Character` and `Date` classes are
  accepted. The value is snapped to the first of the month internally.

- `collection`:

  One of `"ETa"` (primary AET band in mm/month, default) or `"pixel_qa"`
  (quality assurance flags).

Data availability: 2000-02-01 onwards.

## SLGA soil attributes – AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO

A family of 8 static soil properties from the Soil and Landscape Grid of
Australia (SLGA), each available at 6 standard depth intervals (0-5,
5-15, 15-30, 30-60, 60-100, 100-200 cm). 90 m resolution.

- `collection`:

  One of `"AWC"` (Available Water Capacity), `"CLY"` (Clay), `"SND"`
  (Sand), `"SLT"` (Silt), `"BDW"` (Bulk Density), `"PHC"` (pH CaCl2),
  `"PHW"` (pH water), or `"NTO"` (Total Nitrogen). Required.

- `depth`:

  Depth interval: `"000_005"` (0-5 cm, default), `"005_015"`,
  `"015_030"`, `"030_060"`, `"060_100"`, or `"100_200"`. Use `"all"` to
  return all 6 depths stacked.

- `stat`:

  One of `"EV"` (estimate, default) or `"CI"` (confidence interval).

Best accessed via
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md).

## SOILDIV – Soil Beta Diversity

Bacteria and Fungi NMDS ordination axes (1-3) from soil surveys. 90 m
resolution, static.

- `kingdom`:

  One of `"Bacteria"` (default) or `"Fungi"`.

- `axis`:

  Axis 1, 2, or 3 (default 1). Use `"all"` for all 6 axes stacked.

Best accessed via
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md).

## CANOPY – Canopy Height 30 m (OzTreeMap)

Composite canopy height model from remote sensing validation. 30 m
resolution; CRS is `EPSG:3577` (projected). Note: extraction at point
locations (in geographic coordinates) requires prior CRS transformation.
No arguments needed beyond `api_key`. Best accessed via
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md).

## PHENOLOGY – Land Surface Phenology (MODIS)

Start or End of Growing Season derived from MODIS NDVI. 500 m
resolution; years 2003-2018.

- `metric`:

  One of `"SGS"` (Start of Growing Season, default) or `"EGS"` (End of
  Growing Season).

- `year`:

  Year from 2003 to 2018 (default 2018).

- `season`:

  Season number (default 1).

Best accessed via
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md).

## Datasets not implemented

The following datasets are inaccessible or require further development:

- `TERN/0997cb3c` – Seasonal Fractional Cover (legacy redirect; COGs not
  accessible via HTTP range request)

- `TERN/fe9d86e1` – Seasonal Ground Cover (same issue)

Datasets with integration level L2 or higher (e.g.\\ AusEFlux via
THREDDS/OPeNDAP, GEE-based products, site-level API streams) cannot be
read via simple COG HTTP range requests and are outside the current
scope of nert.

## References

SMIPS portal:
<https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>

ASC portal:
<https://portal.tern.org.au/metadata/TERN/15728dba-b49c-4da5-9073-13d8abe67d7c>

AET portal:
<https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>

AET DOI: <https://dx.doi.org/10.25901/gg27-ck96>

## See also

Other COGs:
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md)

## Examples

``` r
if (FALSE) { # interactive()
# Using aliases (short form)
r <- read_tern("SMIPS", date = "2024-01-15")
r_asc <- read_tern("ASC")
autoplot(r_asc)

# Or using full TERN keys (old form still works)
r2 <- read_tern("TERN/d1995ee8", date = "2024-01-15")

# SMIPS -- multiple collections
r_smi <- read_tern("SMIPS", date = "2024-01-15", collection = "SMindex")

# ASC -- confusion index
r_ci <- read_tern("ASC", collection = "CI")

# AET -- monthly evapotranspiration
r_aet <- read_tern("AET", date = "2023-06-01")

# SLGA -- available water capacity, depth 5-15 cm
r_awc <- read_tern("AWC", depth = "005_015")

# SLGA -- all depths stacked
r_awc_all <- read_tern("AWC", depth = "all")

# Soil diversity -- Fungi NMDS axis 2
r_fungi <- read_tern("SOILDIV", kingdom = "Fungi", axis = 2)

# Canopy height
r_canopy <- read_tern("CANOPY")

# Phenology -- End of Growing Season, 2018
r_egs <- read_tern("PHENOLOGY", metric = "EGS", year = 2018)
}
```
