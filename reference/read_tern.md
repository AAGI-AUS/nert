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
read_tern(
  dataset_id,
  ...,
  api_key = NULL,
  max_tries = 3L,
  initial_delay = 1L
)
```

## Arguments

- dataset_id:

  A `character` string identifying the dataset. Accepts the full TERN
  portal key (e.g.\\ `"TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0"`) or
  the 8-character key prefix (e.g.\\ `"TERN/d1995ee8"`). Currently
  supported keys:

  |                   |                                      |
  |-------------------|--------------------------------------|
  | `"TERN/d1995ee8"` | SMIPS daily soil moisture            |
  | `"TERN/15728dba"` | Australian Soil Classification (ASC) |
  | `"TERN/9fefa68b"` | AET/CMRSET evapotranspiration        |

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

## SMIPS — daily soil moisture (`"TERN/d1995ee8"`)

- `date`:

  Required. A single day to query, *e.g.* `"2024-01-15"` or
  `as.Date("2024-01-15")`. Both `Character` and `Date` classes are
  accepted.

- `collection`:

  One of `"totalbucket"` (default), `"SMindex"`, `"bucket1"`,
  `"bucket2"`, `"deepD"`, or `"runoff"`.

Data availability: 2015-11-20 to approximately 7 days before today.

## ASC — Australian Soil Classification (`"TERN/15728dba"`)

- `collection`:

  One of `"EV"` (estimated soil order class, default) or `"CI"`
  (confusion index — a measure of mapping reliability). No `date`
  argument required; this is a static product.

## AET — Actual Evapotranspiration/CMRSET (`"TERN/9fefa68b"`)

- `date`:

  Required. A month to query, *e.g.* `"2023-06-01"` or
  `as.Date("2023-06-01")`. Both `Character` and `Date` classes are
  accepted. The value is snapped to the first of the month internally.

- `collection`:

  One of `"ETa"` (primary AET band in mm/month, default) or `"pixel_qa"`
  (quality assurance flags).

Data availability: 2000-02-01 onwards.

## Datasets not yet implemented

The following priority datasets are tracked in the TERN catalogue and
are planned for a future release. They require verification of COG
file-naming patterns against the live TERN data server before they can
be safely included:

- `TERN/482301c2` — SLGA Available Volumetric Water Capacity

- `TERN/4a428d52` — SLGA Soil Bacteria and Fungi Beta Diversity

- `TERN/0997cb3c` — Seasonal Fractional Cover (Landsat)

- `TERN/fe9d86e1` — Seasonal Ground Cover (Landsat)

- `TERN/36c98155` — Canopy Height Models 30 m

- `TERN/2bb0c81a` — Australian Land Surface Phenology

- `TERN/PAV_slga` — SLGA Available Phosphorus

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
# SMIPS — total bucket soil moisture for a specific day
r <- read_tern("TERN/d1995ee8", date = "2024-01-15")
autoplot(r)

# SMIPS — soil moisture index, multiple collections via loop
r_smi <- read_tern("TERN/d1995ee8", date = "2024-01-15",
                   collection = "SMindex")

# ASC — estimated soil order class (static, no date needed)
r_asc <- read_tern("TERN/15728dba")
autoplot(r_asc)

# ASC — confusion index
r_ci <- read_tern("TERN/15728dba", collection = "CI")

# AET — monthly evapotranspiration
r_aet <- read_tern("TERN/9fefa68b", date = "2023-06-01")
autoplot(r_aet)

# Full UUID keys are also accepted
r2 <- read_tern(
  "TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0",
  date = "2024-01-15"
)
}
```
