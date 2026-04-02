# nert 0.0.3.9000

## New features

* Addition of `collect_tern_data()` for batch extraction of TERN datasets at
  one or more locations over a date range.  Returns a `data.table` with one
  row per date per location.  Supports all 14 datasets, multi-location
  coordinate input (lon/lat vectors or data.frame), and column expansion for
  multi-layer products (SLGA depths, SMIPS variants).

* Addition of `collect_tern_data` vignette with worked examples.

# nert 0.0.2.9000

## New features

* Unified `read_tern()` dispatcher supporting 14 TERN COG datasets via
  short aliases: SMIPS, ASC, AET, 8 SLGA soil attributes (AWC, CLY, SND,
  SLT, BDW, PHC, PHW, NTO), Soil Beta Diversity, Canopy Height, and Land
  Surface Phenology.

* Convenience wrappers: `read_slga()`, `read_soil_diversity()`,
  `read_canopy_height()`, `read_phenology()`.

# nert 0.0.1.9000

## Minor changes

* Addition of `read_aet()` and `extract_aet()` to read Actual
  Evapotranspiration (AET) CMRSET data from TERN.  See
  <https://portal.tern.org.au/metadata/TERN/9fefa68b-dbed-4c20-88db-a9429fb4ba97>
  for more on these data.

* Addition of `get_asc()` to get Australian Soil Classification data and confusion index values from pattern.
See <https://www.tern.org.au/news-australian-soil-classification-map/> for more on these data.

## Bug fixes

* Spelling corrections
