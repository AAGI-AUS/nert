# nert 0.1.0

## New features

* Retry behaviour is now configurable via package options
  `nert.max_tries` (default `3L`) and `nert.initial_delay` (default
  `1L`, seconds). Set globally with, e.g.,
  `options(nert.max_tries = 5L, nert.initial_delay = 2L)` in your
  `.Rprofile` to apply across every `read_*()` and `collect_tern_data()`
  call. Closes
  [#20](https://github.com/AAGI-AUS/nert/issues/20).

## Internal / API changes

* The `max_tries` and `initial_delay` arguments of all public read
  functions (`read_tern()`, `read_aet()`, `read_asc()`,
  `read_canopy_height()`, `read_phenology()`, `read_slga()`,
  `read_smips()`, `read_soil_diversity()`) now default to `NULL`.
  When `NULL`, values are resolved at call time from
  `getOption("nert.max_tries")` and `getOption("nert.initial_delay")`.
  This is **non-breaking**: existing user code that passes explicit
  integers (e.g.\ `read_tern("CANOPY", max_tries = 5L)`) continues to
  work unchanged and still overrides the option.

* New internal helper `.init_nert_options()` (in `R/zzz.R`) populates
  the package options on `.onLoad()`. Pattern adapted from the
  rOpenSci [`read.abares`](https://github.com/ropensci/read.abares)
  package.

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
