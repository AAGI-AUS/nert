# collect_tern_data() — Vectorized Data Collection

## Collecting TERN Data Over Time and Space

The
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
function provides a vectorized interface to extract values from one or
more TERN datasets at given location(s) over a date range. Unlike
individual wrapper functions
([`read_smips()`](https://aagi-aus.github.io/nert/reference/read_smips.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md),
etc.) which return raster objects,
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
returns a **data table** with extracted point values — ideal for
analysis workflows.

### Basic Usage

Extract SMIPS soil moisture for a single location over multiple dates:

``` r
library(nert)

dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-10"), by = "day")

dt <- collect_tern_data(
  lon = 138.6,
  lat = -34.9,
  date_range = dates,
  datasets = "SMIPS",
  verbose = TRUE
)

head(dt)
```

When `verbose = TRUE`, you’ll see: 1. **Dataset information table**
showing what will be collected (name, ID, layers, temporal resolution,
spatial resolution, description) 2. **Progress messages** as data is
downloaded 3. **Summary** of rows and columns collected

### Default Behavior

By default,
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
extracts **all available variants/depths**:

- **SMIPS**: All 6 soil moisture variants (totalbucket, SMindex,
  bucket1, bucket2, deepD, runoff)
- **SLGA datasets** (AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO): All 6 soil
  depths (0–5 cm through 100–200 cm)

This ensures you get comprehensive data without specifying each option:

``` r
# Gets all 6 SMIPS variants + all 6 AWC depths in one call
dt <- collect_tern_data(
  lon = 138.6,
  lat = -34.9,
  date_range = "2024-01-15",
  datasets = c("SMIPS", "AWC"),
  verbose = FALSE  # Hide table for brevity
)

names(dt)
# [1] "date"              "SMIPS_totalbucket" "SMIPS_SMindex"
# [4] "SMIPS_bucket1"     "SMIPS_bucket2"     "SMIPS_deepD"
# [7] "SMIPS_runoff"      "AWC_000_005"       "AWC_005_015"
# [10] "AWC_015_030"      "AWC_030_060"       "AWC_060_100"
# [13] "AWC_100_200"
```

### Multiple Locations

Extract data for multiple coordinates (returns one row per location per
date):

``` r
# Vector notation
dt_multi <- collect_tern_data(
  lon = c(138.6, 139.5, 140.1),
  lat = c(-34.9, -35.2, -34.5),
  date_range = c("2024-01-01", "2024-01-05"),
  datasets = c("SMIPS", "CANOPY")
)

nrow(dt_multi)  # 3 locations × 5 dates = 15 rows
ncol(dt_multi)  # date + lon + lat + SMIPS_variants(6) + CANOPY(1) = 11 cols
```

Or use **xy notation** with a data.frame:

``` r
locations <- data.frame(
  lon = c(138.6, 139.5, 140.1),
  lat = c(-34.9, -35.2, -34.5)
)

dt_xy <- collect_tern_data(
  xy = locations,
  date_range = "2024-01-15",
  datasets = c("ASC", "PHENOLOGY")
)
```

### Selective Extraction

Extract specific variants or depths instead of all:

``` r
# Only specific SMIPS collection
dt_smi <- collect_tern_data(
  lon = 138.6,
  lat = -34.9,
  date_range = "2024-01-15",
  datasets = "SMIPS",
  smips_collection = "SMindex"  # Just soil moisture index (0-100%)
)
# Returns: date, SMIPS_SMindex

# Only specific depth for SLGA
dt_surface <- collect_tern_data(
  lon = 138.6,
  lat = -34.9,
  date_range = "2024-01-15",
  datasets = "CLY",
  depth = "000_005"  # Top 5 cm only
)
# Returns: date, CLY
```

### All 14 Available Datasets

By default,
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
collects all 14 datasets when called without specifying `datasets`:

``` r
# Collect everything
dt_all <- collect_tern_data(
  lon = 138.6,
  lat = -34.9,
  date_range = "2024-01-15"
  # datasets = NULL (or omitted — defaults to all)
)
```

This returns:

| Category              | Datasets                                                    | Columns     |
|-----------------------|-------------------------------------------------------------|-------------|
| **Time-series**       | SMIPS (6 variants), AET                                     | 7           |
| **Soil**              | ASC, AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO (6 depths each) | 1 + 54      |
| **Vegetation/Canopy** | CANOPY, PHENOLOGY, SOILDIV                                  | 3           |
| **Total**             | 14 datasets                                                 | ~65 columns |

### Understanding Column Names

Output columns follow a naming pattern for clarity:

- **Time-series**: `{DATASET}_{VARIANT}` or `{DATASET}_{LAYER}`
  - `SMIPS_totalbucket`, `SMIPS_SMindex`, `SMIPS_bucket1`, …
  - `AET` (single layer)
- **SLGA (soil)**: `{COLLECTION}_{DEPTH}`
  - `AWC_000_005`, `AWC_005_015`, …, `AWC_100_200`
  - `CLY_000_005`, `CLY_005_015`, …, etc.
- **Static (single-layer)**: Dataset name
  - `ASC` (character soil order, e.g., “2 - Sodosol”)
  - `CANOPY` (height in metres)
  - `PHENOLOGY` (day-of-year)
  - `SOILDIV` (NMDS ordination score)

### Handling Missing Data

If a request fails (network error, API unavailable, etc.), that column
will contain `NA` for affected rows. Use `na.rm = TRUE` to remove rows
where all dataset columns are NA:

``` r
dt <- collect_tern_data(
  lon = 138.6,
  lat = -34.9,
  date_range = dates,
  datasets = c("SMIPS", "AET"),
  na.rm = TRUE  # Remove dates with no successful extractions
)
```

### Data Types

- **Numeric columns** (default): SMIPS, AET, SLGA, CANOPY, PHENOLOGY,
  SOILDIV
- **Character column**: ASC returns soil order descriptions (e.g., “2 -
  Sodosol”, “15 - Vertosol”)

Use [`as.numeric()`](https://rdrr.io/r/base/numeric.html) on ASC column
if you need just the numeric code.

### Performance Tips

1.  **Request only needed datasets** to reduce download time
2.  **Use specific variants/depths** (e.g., `depth = "000_005"`) if all
    6 depths aren’t needed
3.  **Batch multiple locations** instead of looping — vectorized
    operations are faster
4.  **Set `verbose = FALSE`** after testing to suppress messages

### Examples

#### Agricultural Analysis: Soil Properties at a Field

``` r
# Extract soil properties at one location for a growing season
field <- list(lon = 138.6, lat = -34.9)

dt_soil <- collect_tern_data(
  lon = field$lon,
  lat = field$lat,
  date_range = "2024-01-01",  # Static datasets, so date doesn't matter
  datasets = c("AWC", "CLY", "PHC"),  # Water capacity, clay %, pH
  depth = "all"  # All 6 soil depths
)

# Wide format for each soil attribute across depths
head(dt_soil)
```

#### Climate Monitoring: Multiple Sites

``` r
# Monitor evapotranspiration and canopy height at 5 monitoring stations
stations <- data.frame(
  name = c("Adelaide", "Murray Bridge", "Naracoorte", "Coonalpyn", "Kingoonya"),
  lon = c(138.6, 139.3, 140.8, 140.7, 137.2),
  lat = c(-34.9, -35.3, -37.3, -35.5, -30.5)
)

et_data <- collect_tern_data(
  xy = stations,
  date_range = c("2023-01-01", "2023-12-31"),
  datasets = "AET",
  verbose = TRUE
)

# Pivot to wide format for comparison
pivot_wider(et_data,
            names_from = name,
            values_from = AET,
            id_cols = date)
```

### See Also

- `?read_smips()` — Direct raster access to SMIPS data
- `?read_slga()` — Direct raster access to SLGA soil attributes
- `?read_tern()` — Low-level interface to any TERN dataset by ID
