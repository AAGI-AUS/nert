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

  A `character` string identifying the dataset. Accepts a short alias,
  the full TERN portal key (e.g.\\
  `"TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0"`), or the 8-character key
  prefix (e.g.\\ `"TERN/d1995ee8"`). See the **Dataset aliases** section
  for the complete table of supported aliases.

- ...:

  Dataset-specific arguments — `date`, `collection`, etc. See the
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

## Dataset aliases

In addition to full TERN portal keys and 8-character prefixes,
`read_tern()` accepts short human-readable aliases (case-insensitive):

|               |                 |                                       |
|---------------|-----------------|---------------------------------------|
| **Alias**     | **Dataset ID**  | **Description**                       |
| `"SMIPS"`     | `TERN/d1995ee8` | Daily soil moisture (~1 km)           |
| `"ASC"`       | `TERN/15728dba` | Australian Soil Classification (90 m) |
| `"AET"`       | `TERN/9fefa68b` | Monthly evapotranspiration (CMRSET)   |
| `"AWC"`       | `TERN/482301c2` | Available Water Capacity (90 m)       |
| `"CLY"`       | SLGA            | Clay content (90 m)                   |
| `"SND"`       | SLGA            | Sand content (90 m)                   |
| `"SLT"`       | SLGA            | Silt content (90 m)                   |
| `"BDW"`       | SLGA            | Bulk density whole earth (90 m)       |
| `"PHC"`       | SLGA            | pH CaCl2 (90 m)                       |
| `"PHW"`       | SLGA            | pH water (90 m)                       |
| `"NTO"`       | SLGA            | Total Nitrogen (90 m)                 |
| `"SOILDIV"`   | `TERN/4a428d52` | Soil Beta Diversity (90 m)            |
| `"CANOPY"`    | `TERN/36c98155` | Canopy Height (30 m)                  |
| `"PHENOLOGY"` | `TERN/2bb0c81a` | Land Surface Phenology (500 m)        |

Convenience wrappers
[`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_aet()`](https://aagi-aus.github.io/nert/reference/read_aet.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
and
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md)
are also provided for direct access to each dataset.

## SMIPS — daily soil moisture (`"TERN/d1995ee8"`)

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

## SLGA soil attributes (`"AWC"`, `"CLY"`, etc.)

Eight SLGA (Soil and Landscape Grid of Australia) soil attributes are
available as static 90 m products, each with six standard depth layers
and two statistics:

- `depth`:

  One of `"000_005"` (default), `"005_015"`, `"015_030"`, `"030_060"`,
  `"060_100"`, or `"100_200"` (cm).

- `collection`:

  One of `"EV"` (estimated value, default) or `"CI"` (confidence
  interval).

Supported attributes (use as the `dataset_id` alias):

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

Convenience wrapper:
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md).

## Soil Beta Diversity (`"SOILDIV"`, `TERN/4a428d52`)

- `collection`:

  One of `"Bacteria"` (default) or `"Fungi"`.

- `axis`:

  NMDS axis number: `1` (default), `2`, or `3`.

Static 90 m product. Convenience wrapper:
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md).

## Canopy Height (`"CANOPY"`, `TERN/36c98155`)

Single static 30 m composite from the OzTreeMap project. No additional
arguments required. Convenience wrapper:
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md).

## Land Surface Phenology (`"PHENOLOGY"`, `TERN/2bb0c81a`)

- `year`:

  Required. An integer year (2003–2018).

- `season`:

  Season number: `1` (default) or `2`.

- `collection`:

  Phenology metric — one of `"SGS"` (Start of Growing Season, default),
  `"PGS"` (Peak), `"EGS"` (End), `"LGS"` (Length), `"SOS"` (Start of
  Season), `"POS"` (Peak of Season), `"EOS"` (End of Season), `"LOS"`
  (Length of Season), `"ROG"` (Rate of Greening), `"ROS"` (Rate of
  Senescence).

500 m MODIS resolution. Convenience wrapper:
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md).

## Datasets not accessible

The following datasets are tracked in the TERN catalogue but cannot be
accessed via COG HTTP range requests:

- `TERN/0997cb3c` — Seasonal Fractional Cover (Landsat)

- `TERN/fe9d86e1` — Seasonal Ground Cover (Landsat)

Datasets with integration level L2 or higher (e.g.\\ AusEFlux via
THREDDS/OPeNDAP, GEE-based products, site-level API streams) cannot be
read via simple COG HTTP range requests and are outside the current
scope of nert.

## References

SMIPS:
<https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>

ASC:
<https://portal.tern.org.au/metadata/TERN/15728dba-b49c-4da5-9073-13d8abe67d7c>

AET:
<https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>

AWC:
<https://portal.tern.org.au/metadata/TERN/482301c2-2837-4b0b-bf95-4883a04e5ff7>

Soil Beta Diversity:
<https://portal.tern.org.au/metadata/TERN/4a428d52-d15c-4bfc-8a67-80697f8c0aa0>

Canopy Height:
<https://portal.tern.org.au/metadata/TERN/36c98155-c137-44b8-b4e0-6a3e824bbfba>

Land Surface Phenology:
<https://portal.tern.org.au/metadata/TERN/2bb0c81a-5a09-4a0e-bd86-5cd2be8def26>

## See also

Other COGs:
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md)

## Examples

``` r
if (FALSE) { # interactive()
# Using aliases (recommended) ----------------------------------------
r <- read_tern("SMIPS", date = "2024-01-15")
r_asc <- read_tern("ASC")
autoplot(r_asc)

# SLGA soil attributes — depth and collection
r_clay <- read_tern("CLY", depth = "000_005")
r_awc  <- read_tern("AWC", depth = "015_030", collection = "CI")

# Soil Beta Diversity
r_bact <- read_tern("SOILDIV", collection = "Bacteria", axis = 1)

# Canopy Height (single static product)
r_ch <- read_tern("CANOPY")

# Land Surface Phenology
r_phen <- read_tern("PHENOLOGY", year = 2018, collection = "SGS")

# Full TERN keys still work ----------------------------------------
r2 <- read_tern("TERN/d1995ee8", date = "2024-01-15")
}
```
