# Changelog

## nert 0.0.3.9000

### New features

- Addition of
  [`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
  for batch extraction of TERN datasets at one or more locations over a
  date range. Returns a `data.table` with one row per date per location.
  Supports all 14 datasets, multi-location coordinate input (lon/lat
  vectors or data.frame), and column expansion for multi-layer products
  (SLGA depths, SMIPS variants).

- Addition of `collect_tern_data` vignette with worked examples.

## nert 0.0.2.9000

### New features

- Unified
  [`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
  dispatcher supporting 14 TERN COG datasets via short aliases: SMIPS,
  ASC, AET, 8 SLGA soil attributes (AWC, CLY, SND, SLT, BDW, PHC, PHW,
  NTO), Soil Beta Diversity, Canopy Height, and Land Surface Phenology.

- Convenience wrappers:
  [`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md),
  [`read_soil_diversity()`](https://aagi-aus.github.io/nert/reference/read_soil_diversity.md),
  [`read_canopy_height()`](https://aagi-aus.github.io/nert/reference/read_canopy_height.md),
  [`read_phenology()`](https://aagi-aus.github.io/nert/reference/read_phenology.md).

## nert 0.0.1.9000

### Minor changes

- Addition of
  [`read_aet()`](https://aagi-aus.github.io/nert/reference/read_aet.md)
  and `extract_aet()` to read Actual Evapotranspiration (AET) CMRSET
  data from TERN. See
  <https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
  for more on these data.

- Addition of `get_asc()` to get Australian Soil Classification data and
  confusion index values from pattern. See
  <https://www.tern.org.au/news-australian-soil-classification-map/> for
  more on these data.

### Bug fixes

- Spelling corrections
