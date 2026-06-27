# Read TERN COG Datasets

A unified interface for reading Cloud Optimised GeoTIFF (COG) data from
the TERN Data Portal. This function effectively dispatches to
dataset-specific handlers based on the dataset requested (e.g., SMIPS,
SLGA, AET, and so on), and passes any additional arguments through
`...`. The returned object is a
[terra::SpatRaster](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
that can be plotted, cropped, or extracted with standard terra or
tidyterra workflows.

## Usage

``` r
read_tern(
  dataset_id = NULL,
  ...,
  api_key = NULL,
  max_tries = NULL,
  initial_delay = NULL
)
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
object for the requested dataset.

## Dataset aliases

In addition to full TERN portal keys and 8-character prefixes,
`read_tern()` accepts short human-readable aliases (case-insensitive):

|               |                 |                                              |
|---------------|-----------------|----------------------------------------------|
| **Alias**     | **Dataset ID**  | **Description**                              |
| `"SMIPS"`     | `TERN/d1995ee8` | Daily soil moisture (~1 km)                  |
| `"ASC"`       | `TERN/15728dba` | Australian Soil Classification (90 m)        |
| `"AET"`       | `TERN/9fefa68b` | Monthly evapotranspiration via CMRSET (30 m) |
| `"AWC"`       | `TERN/482301c2` | Available Water Capacity (90 m)              |
| `"CLY"`       | `TERN/f95dc442` | Clay content (90 m)                          |
| `"SND"`       | `TERN/4224ddff` | Sand content (90 m)                          |
| `"SLT"`       | `TERN/11375f04` | Silt content (90 m)                          |
| `"BDW"`       | `TERN/95978aec` | Bulk density whole earth (90 m)              |
| `"PHC"`       | `TERN/258afc98` | pH CaCl2 (90 m)                              |
| `"PHW"`       | `TERN/c37439a5` | pH water (90 m)                              |
| `"NTO"`       | `TERN/e9484508` | Total Nitrogen (90 m)                        |
| `"AVP"`       | `TERN/c6ef289b` | Available Phosphorus (90 m)                  |
| `"PTO"`       | `TERN/be382e63` | Total Phosphorus (90 m)                      |
| `"CEC"`       | `TERN/5b4b2991` | Cation Exchange Capacity (90 m)              |
| `"ECE"`       | `TERN/0d27cf8b` | Effective Cation Exchange Capacity (90 m)    |
| `"DUL"`       | `TERN/de9ddc12` | Drained Upper Limit water content (90 m)     |
| `"L15"`       | `TERN/4443f5df` | 15 Bar Lower Limit water content (90 m)      |
| `"SOILDIV"`   | `TERN/4a428d52` | Soil Beta Diversity (90 m)                   |
| `"CANOPY"`    | `TERN/36c98155` | Canopy Height (30 m)                         |
| `"PHENOLOGY"` | `TERN/2bb0c81a` | Land Surface Phenology (500 m)               |

Convenience wrappers
[`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
[`read_aet()`](https://aagi-aus.github.io/nert/reference/read_aet.md),
[`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
[`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
[`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
and
[`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md)
are also provided for simplified access to each dataset.

## SMIPS — daily soil moisture (`"SMIPS"`)

- `date`:

  Required. A single day to query, *e.g.* `"2024-01-15"` or
  `as.Date("2024-01-15")`. Both `character` and `Date` classes are
  accepted.

- `collection`:

  One of `"totalbucket"` (default), `"SMindex"`, `"bucket1"`,
  `"bucket2"`, `"deepD"`, or `"runoff"`.

Data availability: from 2005-01-01 to today. (Updated regularly.)

## ASC – Australian Soil Classification (`"ASC"`)

- `collection`:

  One of `"EV"` (estimated soil order class, default) or `"CI"`
  (confusion index – a measure of the classification uncertainty).

## AET – Actual Evapotranspiration/CMRSET (`"AET"`)

- `date`:

  Required. A month to query, *e.g.* `"2023-06-01"` or
  `as.Date("2023-06-01")`. Both `character` and `Date` classes are
  accepted. The value is snapped to the first of the month.

- `collection`:

  One of `"ETa"` (primary AET band in mm/month, default) or `"pixel_qa"`
  (quality assurance attributes).

Data availability: 1987-05-01 onward, monthly.

## SLGA soil attributes (`"AWC"`, `"CLY"`, etc.)

14 SLGA (Soil and Landscape Grid of Australia) soil attributes are
available as static 90 m products, each with six standard depth layers
and three statistics:

- `depth`:

  One of `"000_005"` (default), `"005_015"`, `"015_030"`, `"030_060"`,
  `"060_100"`, or `"100_200"` (cm).

- `collection`:

  One of `"EV"` (estimated value, default), `"05"` (lower percentile
  limit for the 95% confidence interval) or `"95"` (upper percentile
  limit for the confidence interval).

Supported attributes (use as the `dataset_id` alias):

- `"AWC"`:

  Available Water Capacity (percent)

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

- `"AVP"`:

  Available Phosphorus (mg/kg)

- `"PTO"`:

  Total Phosphorus (percent)

- `"CEC"`:

  Cation Exchange Capacity (meq/100g)

- `"ECE"`:

  Effective Cation Exchange Capacity (meq/100g)

- `"DUL"`:

  Drained Upper Limit volumetric water content (percent)

- `"L15"`:

  15 Bar Lower Limit volumetric water content (percent)

## Soil Beta Diversity (`"SOILDIV"`)

- `collection`:

  One of `"Bacteria"` (default) or `"Fungi"`.

- `axis`:

  NMDS axis: `1` (default), `2`, or `3`.

## Canopy Height (`"CANOPY"`)

Single static 30 m X 30 m best-pick canopy height model composite, from
the OzTreeMap project. No function arguments required.

## Land Surface Phenology (`"PHENOLOGY"`)

- `year`:

  Required. An integer year (2003–2018).

- `season`:

  Season number: `1` (default) or `2`.

- `collection`:

  Phenology metric — one of `"SGS"` (Start of Growing Season, default),
  `"PGS"` (Peak of Growing Season), `"EGS"` (End of Growing Season),
  `"LGS"` (Length of Growing Season), `"EVI1"` (Minimum EVI before
  peak), `"EVI2"` (Minimum EVI after peak), `"EVIP"` (EVI at Peak of
  Growing Season), `"EVII"` (Integral of EVI under growing season
  curve), `"SGS_month"` (Start of Growing Season, monthly resolution),
  `"PGS_month"` (Peak of the Growing Season, monthly resolution),
  `"EGS_month"` (End of Growing Season, monthly resolution).

## Datasets not accessible

The following datasets are tracked in the TERN catalogue but cannot be
accessed via COG HTTP range requests:

- `TERN/0997cb3c` — Seasonal Fractional Cover (Landsat)

- `TERN/fe9d86e1` — Seasonal Ground Cover (Landsat)

Datasets with integration level L2 or higher (e.g.\\ AusEFlux via
THREDDS/OPeNDAP, GEE-based products, site-level API streams) cannot be
read via simple COG HTTP range requests and are outside the current
scope of nert.

## Package options

nert reads two package-level options on every call. Both are set to
package defaults at load time and may be overridden globally (e.g. in
`.Rprofile`) without changing any individual call:

- `nert.max_tries`:

  Default maximum number of download retries. Default `3L`.

- `nert.initial_delay`:

  Default initial retry delay in seconds (doubles each attempt). Default
  `1L`.

Per-call values supplied via the `max_tries` or `initial_delay`
arguments always override the option. Example:


      options(nert.max_tries = 5L, nert.initial_delay = 2L)

## References

- **SMIPS: Daily volumetric soil moisture**:

  Stenson, M., Searle, R., Malone, B., Sommer, A., Renzullo, L. & Di, H.
  (2021): Australia wide daily volumetric soil moisture estimates.
  Version 1.0. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25901/b020-nm39](https://doi.org/10.25901/b020-nm39) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>

- **ASC: Australian Soil Classification Map**:

  Searle, R. (2021). Australian Soil Classification Map. Version 1.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25901/edyr-wg85](https://doi.org/10.25901/edyr-wg85) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/15728dba-b49c-4da5-9073-13d8abe67d7c>

- **AET: Actual Evapotranspiration using the CMRSET algorithm**:

  McVicar, T., Vleeshouwer, J., Van Niel, T., Guerschman, J. &
  Peña-Arancibia, J. (2022). Actual Evapotranspiration for Australia
  using CMRSET algorithm. Version 1.0. Terrestrial Ecosystem Research
  Network. (Dataset).
  [doi:10.25901/gg27-ck96](https://doi.org/10.25901/gg27-ck96) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/9fefa68b-dbed-4c20-88db-a9429fb4ba97>

- **AWC: SLGA Attribute - Available Volumetric Water Capacity**:

  Searle, R., Nimalka Somarathna, P. & Malone, B. (2023). Soil and
  Landscape Grid National Soil Attribute Maps - Available Volumetric
  Water Capacity (Percent) (3 arc second resolution) Version 2. Version
  2.0. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/4jwj-na34](https://doi.org/10.25919/4jwj-na34) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/482301c2-b9a1-4345-b142-815f9b37890a>

- **CLY: SLGA Attribute - Clay content**:

  Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
  Attribute Maps - Clay (3" resolution) - Release 2. Version 2.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/hc4s-3130](https://doi.org/10.25919/hc4s-3130) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/f95dc442-013b-4fad-b31f-91ba86fbe7f5>

- **SND: SLGA Attribute - Sand content**:

  Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
  Attribute Maps - Sand (3" resolution) - Release 2. Version 2.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/rjmy-pa10](https://doi.org/10.25919/rjmy-pa10) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4224ddff-5fb4-4170-b5ea-c0c500599700>

- **SLT: SLGA Attribute - Silt content**:

  Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
  Attribute Maps - Silt (3" resolution) - Release 2. Version 2.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/2ew1-0w57](https://doi.org/10.25919/2ew1-0w57) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/11375f04-b5cd-46a7-bcac-0e83fcb58605>

- **BDW: SLGA Attribute - Bulk Density (Whole Earth)**:

  Malone, B. (2023). Soil and Landscape Grid National Soil Attribute
  Maps - Bulk Density - Whole Earth - Release 2. Version 2. Terrestrial
  Ecosystem Research Network. (Dataset).
  [doi:10.25919/gxyn-pd07](https://doi.org/10.25919/gxyn-pd07) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/95978aec-6ba8-446b-a721-2b875d9f61a8>

- **PHC: SLGA Attribute - pH (of 1:5 soil/0.01M CaCl2 extract)**:

  Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
  Attribute Maps - pH - Calcium Chloride (3" resolution) - Release 2.
  Version 2. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/7320-hw30](https://doi.org/10.25919/7320-hw30) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/258afc98-7407-4781-b241-cb0293b4b8aa>

- **PHW: SLGA Attribute - pH (of 1:5 soil water solution)**:

  Malone, B. (2022). Soil and Landscape Grid National Soil Attribute
  Maps - pH (Water) (3" resolution) - Release 1. Version 1.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/37z2-0q10](https://doi.org/10.25919/37z2-0q10) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/c37439a5-e622-44ab-9c24-bfd632d8203c>

- **NTO: SLGA Attribute - Total nitrogen**:

  Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
  Attribute Maps - Total Nitrogen (3" resolution) - Release 2.
  Version 2. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/pm2n-ww12](https://doi.org/10.25919/pm2n-ww12) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/e9484508-c705-4c23-9195-f26d64b9d4f1>

- **AVP: SLGA Attribute - Available phosphorus**:

  Zund, P. (2022). Soil and Landscape Grid National Soil Attribute
  Maps - Available Phosphorus (3" resolution) - Release 1. Version 1.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/6qzh-b979](https://doi.org/10.25919/6qzh-b979) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/c6ef289b-1ca8-4e53-b8b4-aa97e4706c63>

- **PTO: SLGA Attribute - Total phosphorus**:

  Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
  Attribute Maps - Total Phosphorus (3" resolution) - Release 2.
  Version 2. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/7j78-md43](https://doi.org/10.25919/7j78-md43) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/be382e63-5ff6-40a9-930f-c84655a5bd87>

- **CEC: SLGA Attribute - Cation exchange capacity**:

  Malone, B. (2024). Soil and Landscape Grid National Soil Attribute
  Maps - Cation Exchange Capacity (3" resolution) - Release 1. Version
  1.0. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/pkva-gf85](https://doi.org/10.25919/pkva-gf85) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/5b4b2991-bfa6-41df-be33-7009a5d0a5b0>

- **ECE: SLGA Attribute - Effective cation exchange capacity**:

  Viscarra Rossel, R., Chen, C., Grundy, M., Searle, R., Clifford, D.,
  Odgers, N., Holmes, K., Griffin, T., Liddicoat, C. & Kidd, D. (2014).
  Soil and Landscape Grid National Soil Attribute Maps - Effective
  Cation Exchange Capacity (3" resolution) - Release 1. Version 1.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.4225/08/546F091C11777](https://doi.org/10.4225/08/546F091C11777)
  .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/0d27cf8b-6627-4f33-8398-1b525bc1a210>

- **DUL: SLGA Attribute - Drained upper limit volumetric water
  content**:

  Searle, R. & Nimalka Somarathna, P. (2022). Soil and Landscape Grid
  National Soil Attribute Maps - Drained Upper Limit Volumetric Water
  Content (Percent) (3 arc second resolution) Version 1. Version 1.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/jnvd-3a26](https://doi.org/10.25919/jnvd-3a26) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/de9ddc12-b8e4-4ff2-99c4-390227a848aa>

- **L15: SLGA Attribute - 15 bar lower limit volumetric water content**:

  Searle, R. & Nimalka Somarathna, P. (2022). Soil and Landscape Grid
  National Soil Attribute Maps - 15 Bar Lower Limit Volumetric Water
  Content (Percent) (3 arc second resolution) Version 1. Version 1.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/awp8-nv68](https://doi.org/10.25919/awp8-nv68) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4443f5df-a0b2-4352-b44b-83f7feb1e27d>

- **SOILDIV: Soil Bacteria and Soil Fungi Beta Diversity**:

  Dobarco, M., Wadoux, A. & Xue, P. (2024). Soil and Landscape Grid
  National Soil Attribute Maps - Soil Bacteria and Fungi Beta Diversity
  (3" resolution) - Release 1. Version 1.0. Terrestrial Ecosystem
  Research Network. (Dataset).
  [doi:10.25919/4x7n-y874](https://doi.org/10.25919/4x7n-y874) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4a428d52-dda6-4097-8dd9-d3ec63973029>

- **CANOPY: OzTreeMap Best-Pick Canopy Height Model**:

  Pucino, N., McVicar, T., Levick, S. & Albert van Dijk (2025).
  Australia-Wide 30 m Machine Learning-Derived Canopy Height Models
  Composites: Best Pick and Median. Version 1. Terrestrial Ecosystem
  Research Network. (Dataset).
  [doi:10.25901/xqv7-jk46](https://doi.org/10.25901/xqv7-jk46) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/36c98155-39c8-4eec-9070-a978933f3fa3>

- **PHENOLOGY: Australian Land Surface Phenology**:

  Xie, Q. & Huete, A. (2024). Australian land surface phenology dataset
  at 500m resolution. Version 1.0. Terrestrial Ecosystem Research
  Network. (Dataset). URL:
  <https://portal.tern.org.au/metadata/2bb0c81a-41a9-434c-b87a-db0301cb52fb>.  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/2bb0c81a-41a9-434c-b87a-db0301cb52fb>

## Examples

``` r
if (FALSE) { # interactive()
# Using aliases (recommended)
r <- read_tern("SMIPS", date = "2024-01-15")
r_asc <- read_tern("ASC")
autoplot(r_asc)

# SLGA soil attributes
r_clay <- read_tern("CLY", depth = "000_005")
r_awc_upper  <- read_tern("AWC", depth = "015_030", collection = "95")
r_awc_lower  <- read_tern("AWC", depth = "015_030", collection = "05")

# Soil Beta Diversity
r_bact <- read_tern("SOILDIV", collection = "Bacteria", axis = 1)

# Canopy Height
r_ch <- read_tern("CANOPY")

# Land Surface Phenology
r_phen <- read_tern("PHENOLOGY", year = 2018, collection = "SGS")

# Full TERN dataset IDs also work
r2 <- read_tern("TERN/d1995ee8", date = "2024-01-15")
}
```
