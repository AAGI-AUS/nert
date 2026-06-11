# Read SLGA Soil Attributes from TERN

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for retrieving various Soil and Landscape Grid of Australia (SLGA)
datasets from the TERN Data Portal. 14 soil attributes are available at
90m X 90m spatial resolution across Australia, each with six standard
depth layers (0-5cm, 5-15cm, 15-30cm, 30-60cm, 60-100cm, 100-200cm) and
three statistics (estimated value, and the lower (05) and upper (95)
percentile limits for the confidence interval).

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
  `"NTO"`, `"AVP"`, `"PTO"`, `"CEC"`, `"ECE"`, `"DUL"`, or `"L15"`.

- depth:

  One of `"000_005"` (default), `"005_015"`, `"015_030"`, `"030_060"`,
  `"060_100"`, or `"100_200"`.

- collection:

  One of `"EV"` (estimated value, default), `"05"` (lower percentile
  limit for the 95% confidence interval) or `"95"` (upper percentile
  limit for the confidence interval).

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
object of the requested SLGA soil attribute.

## Supported soil attributes

- `"AWC"`:

  Available Water Capacity (%)

- `"CLY"`:

  Clay content (%)

- `"SND"`:

  Sand content (%)

- `"SLT"`:

  Silt content (%)

- `"BDW"`:

  Bulk Density (Whole Earth) (g/cm3)

- `"PHC"`:

  pH (of 1:5 soil/0.01M CaCl2 extract)

- `"PHW"`:

  pH (of 1:5 soil water solution)

- `"NTO"`:

  Total Nitrogen (%)

- `"AVP"`:

  Available soil Phosphorus (mg/kg)

- `"PTO"`:

  Total soil Phosphorus (%)

- `"CEC"`:

  Cation Exchange Capacity (meq/100g)

- `"ECE"`:

  Effective Cation Exchange Capacity (meq/100g)

- `"DUL"`:

  Drained Upper Limit volumetric water content (%)

- `"L15"`:

  15 Bar Lower Limit volumetric water content (%)

## References

- **AWC: Available Volumetric Water Capacity**:

  Searle, R., Nimalka Somarathna, P. & Malone, B. (2023). Soil and
  Landscape Grid National Soil Attribute Maps - Available Volumetric
  Water Capacity (Percent) (3 arc second resolution) Version 2. Version
  2.0. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/4jwj-na34](https://doi.org/10.25919/4jwj-na34) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/482301c2-b9a1-4345-b142-815f9b37890a>

- **CLY: Clay content**:

  Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
  Attribute Maps - Clay (3" resolution) - Release 2. Version 2.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/hc4s-3130](https://doi.org/10.25919/hc4s-3130) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/f95dc442-013b-4fad-b31f-91ba86fbe7f5>

- **SND: Sand content**:

  Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
  Attribute Maps - Sand (3" resolution) - Release 2. Version 2.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/rjmy-pa10](https://doi.org/10.25919/rjmy-pa10) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4224ddff-5fb4-4170-b5ea-c0c500599700>

- **SLT: Silt content**:

  Malone, B. & Searle, R. (2022). Soil and Landscape Grid National Soil
  Attribute Maps - Silt (3" resolution) - Release 2. Version 2.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/2ew1-0w57](https://doi.org/10.25919/2ew1-0w57) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/11375f04-b5cd-46a7-bcac-0e83fcb58605>

- **BDW: Bulk Density (Whole Earth)**:

  Malone, B. (2023). Soil and Landscape Grid National Soil Attribute
  Maps - Bulk Density - Whole Earth - Release 2. Version 2. Terrestrial
  Ecosystem Research Network. (Dataset).
  [doi:10.25919/gxyn-pd07](https://doi.org/10.25919/gxyn-pd07) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/95978aec-6ba8-446b-a721-2b875d9f61a8>

- **PHC: pH (of 1:5 soil/0.01M CaCl2 extract)**:

  Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
  Attribute Maps - pH - Calcium Chloride (3" resolution) - Release 2.
  Version 2. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/7320-hw30](https://doi.org/10.25919/7320-hw30) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/258afc98-7407-4781-b241-cb0293b4b8aa>

- **PHW: pH (of 1:5 soil water solution)**:

  Malone, B. (2022). Soil and Landscape Grid National Soil Attribute
  Maps - pH (Water) (3" resolution) - Release 1. Version 1.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/37z2-0q10](https://doi.org/10.25919/37z2-0q10) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/c37439a5-e622-44ab-9c24-bfd632d8203c>

- **NTO: Total nitrogen**:

  Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
  Attribute Maps - Total Nitrogen (3" resolution) - Release 2.
  Version 2. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/pm2n-ww12](https://doi.org/10.25919/pm2n-ww12) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/e9484508-c705-4c23-9195-f26d64b9d4f1>

- **AVP: Available phosphorus**:

  Zund, P. (2022). Soil and Landscape Grid National Soil Attribute
  Maps - Available Phosphorus (3" resolution) - Release 1. Version 1.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/6qzh-b979](https://doi.org/10.25919/6qzh-b979) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/c6ef289b-1ca8-4e53-b8b4-aa97e4706c63>

- **PTO: Total phosphorus**:

  Malone, B. & Searle, R. (2024). Soil and Landscape Grid National Soil
  Attribute Maps - Total Phosphorus (3" resolution) - Release 2.
  Version 2. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/7j78-md43](https://doi.org/10.25919/7j78-md43) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/be382e63-5ff6-40a9-930f-c84655a5bd87>

- **CEC: Cation exchange capacity**:

  Malone, B. (2024). Soil and Landscape Grid National Soil Attribute
  Maps - Cation Exchange Capacity (3" resolution) - Release 1. Version
  1.0. Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/pkva-gf85](https://doi.org/10.25919/pkva-gf85) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/5b4b2991-bfa6-41df-be33-7009a5d0a5b0>

- **ECE: Effective cation exchange capacity**:

  Viscarra Rossel, R., Chen, C., Grundy, M., Searle, R., Clifford, D.,
  Odgers, N., Holmes, K., Griffin, T., Liddicoat, C. & Kidd, D. (2014).
  Soil and Landscape Grid National Soil Attribute Maps - Effective
  Cation Exchange Capacity (3" resolution) - Release 1. Version 1.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.4225/08/546F091C11777](https://doi.org/10.4225/08/546F091C11777)
  .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/0d27cf8b-6627-4f33-8398-1b525bc1a210>

- **DUL: Drained upper limit volumetric water content**:

  Searle, R. & Nimalka Somarathna, P. (2022). Soil and Landscape Grid
  National Soil Attribute Maps - Drained Upper Limit Volumetric Water
  Content (Percent) (3 arc second resolution) Version 1. Version 1.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/jnvd-3a26](https://doi.org/10.25919/jnvd-3a26) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/de9ddc12-b8e4-4ff2-99c4-390227a848aa>

- **L15: 15 bar lower limit volumetric water content**:

  Searle, R. & Nimalka Somarathna, P. (2022). Soil and Landscape Grid
  National Soil Attribute Maps - 15 Bar Lower Limit Volumetric Water
  Content (Percent) (3 arc second resolution) Version 1. Version 1.0.
  Terrestrial Ecosystem Research Network. (Dataset).
  [doi:10.25919/awp8-nv68](https://doi.org/10.25919/awp8-nv68) .  
    
  TERN Point-of-truth metadata URL:
  <https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/4443f5df-a0b2-4352-b44b-83f7feb1e27d>

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)

## Examples

``` r
if (FALSE) { # interactive()
# Read clay content at 0-5 cm depth (default depth)
r <- read_slga("CLY")
autoplot(r)

# Read available water capacity at 15-30 cm
r_awc <- read_slga("AWC", depth = "015_030")

# Read pH (CaCl2) confidence interval at 30-60 cm
r_phc_low <- read_slga("PHC", depth = "030_060", collection = "05")
r_phc_up <- read_slga("PHC", depth = "030_060", collection = "95")
}
```
