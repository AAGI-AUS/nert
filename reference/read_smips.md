# Read TERN SMIPS Soil Moisture Data

Wrapper around
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
for TERN/SMIPS daily soil moisture data. Provides soil moisture
estimates at 1 km resolution from November 2015 to approximately 7 days
before today.

## Usage

``` r
read_smips(
  date,
  collection = "totalbucket",
  api_key = NULL,
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- date:

  A day to download (Date or character, e.g. `"2024-01-15"` or
  `as.Date("2024-01-15")`). Required.

- collection:

  SMIPS collection variant (default `"totalbucket"`). Options:

  `"totalbucket"`

  :   **Total soil moisture in the full active layer** (mm). Represents
      the total water stored in all soil layers of the active profile.
      Use for: Overall soil water availability, drought monitoring.
      Output column: `SMIPS_totalbucket`

  `"SMindex"`

  :   **Soil Moisture Index, 0-100%** (standardized metric). Rescaled to
      0-100% for comparison across regions and seasons. Use for:
      Regional comparisons, anomaly detection, percentage-based
      thresholds. Output column: `SMIPS_SMindex`

  `"bucket1"`

  :   **Top soil layer moisture** (mm, typically 0-10 cm). Represents
      water in surface soil where seeds germinate and shallow roots
      operate. Use for: Shallow-rooting plants, seed germination,
      surface runoff prediction. Output column: `SMIPS_bucket1`

  `"bucket2"`

  :   **Second soil layer moisture** (mm, typically 10-40 cm).
      Represents water in intermediate soil depth where many plant roots
      develop. Use for: Typical crop rooting depth, plant-available
      water. Output column: `SMIPS_bucket2`

  `"deepD"`

  :   **Deep soil layer moisture** (mm, typically \>40 cm). Represents
      water in deeper soil layers accessed by deep-rooting plants. Use
      for: Deep-rooting trees/shrubs, groundwater recharge, long-term
      drought. Output column: `SMIPS_deepD`

  `"runoff"`

  :   **Surface runoff** (mm). Represents water predicted to run off the
      surface (not infiltrate). Use for: Flood risk, erosion modeling,
      drainage engineering. Output column: `SMIPS_runoff`

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
object of the requested SMIPS collection.

## References

SMIPS portal:
<https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0>

## See also

[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md),
[`read_aet()`](https://aagi-aus.github.io/nert/reference/read_aet.md),
[`read_asc()`](https://aagi-aus.github.io/nert/reference/read_asc.md)

## Examples

``` r
if (FALSE) { # interactive()
# Total bucket soil moisture (default)
r <- read_smips("2024-01-15")
autoplot(r)

# Soil moisture index (0-100%)
r_smi <- read_smips("2024-01-15", collection = "SMindex")

# Top soil bucket (shallow rooting plants)
r_bucket1 <- read_smips("2024-01-15", collection = "bucket1")

# Deep soil layer (deep rooting plants)
r_deep <- read_smips("2024-01-15", collection = "deepD")

# Surface runoff
r_runoff <- read_smips("2024-01-15", collection = "runoff")
}
```
