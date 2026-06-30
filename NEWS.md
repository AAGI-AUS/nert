# nert (development version)

- The SMIPS date validator now uses a per-collection earliest date. Requests
  for the `totalbucket` and `SMindex` collections are accepted back to
  2005-01-01 (these are archived earlier than the four bucket-level
  collections `bucket1`, `bucket2`, `deepD`, and `runoff`, which start
  2015-01-01). Previously every SMIPS request before 2015-01-01 was rejected,
  so valid 2005--2014 `totalbucket` / `SMindex` requests were turned away. The
  out-of-range error message now also names the requested collection.


# nert 1.1.0

Updated version, fixing a number of issues with the TERN dataset retrieval.

- `read_smips()` now tests the correct day when validating the date for
  a requested raster.
- `read_phenology()` now provides access to all of the phenology datasets
  available on the TERN Data Portal, including the monthly SGS/PGS/EGS.
- `read_slga()` provides access to an additional six datasets (CEC,ECE,
  AVP,PTO,DUL,L15), and also allows the user to pull the 05 and 95
  percentile bounds, which together span a 90% interval.
- `read_asc()` now provides access to its data and confusion index rasters
  using a consistent interface with the rest of the `read_*()` functions.
- Documentation for the functions and their TERN datasets has been
  reviewed and improved.


# nert 1.0.0

First stable release.  The package has matured through the 0.0.x
development line and is presented here with its complete user-facing
surface — 11 exports covering 14 TERN datasets via a unified
`read_tern()` dispatcher and the batch primitive `collect_tern_data()`
— along with the audit-driven polish accumulated during pre-CRAN
review.

## Breaking changes

* `read_smips()` argument `day` has been renamed to `date`, matching
  the unified argument naming used across all `read_*()` functions.
  Existing code calling `read_smips(day = ...)` will fail with an
  "unused argument" error; replace `day = ` with `date = `. The
  rename was introduced when `read_smips()` was reintroduced as a thin
  wrapper over `read_tern("SMIPS", ...)` (PR #26) but was not
  surfaced in `NEWS.md` at the time; this 1.0.0 entry corrects the
  omission per
  [#35](https://github.com/AAGI-AUS/nert/issues/35).

## New features

* Retry behaviour is now configurable via package options
  `nert.max_tries` (default `3L`) and `nert.initial_delay` (default
  `1L`, seconds). Set globally with, e.g.,
  `options(nert.max_tries = 5L, nert.initial_delay = 2L)` in your
  `.Rprofile` to apply across every `read_*()` and `collect_tern_data()`
  call. Closes
  [#20](https://github.com/AAGI-AUS/nert/issues/20).

## Performance

* `collect_tern_data()` is now vectorised across locations.  An earlier
  implementation looped over `(location, dataset, date)` tuples and
  called `read_tern()` + `terra::extract()` once per single point,
  redownloading the same Cloud Optimised GeoTIFF (COG) once per
  location.  The refactored version plans a list of *work items* (one
  item per unique COG), opens each COG once via `/vsicurl/`, and calls
  `terra::extract()` once with all coordinates passed as a single
  `SpatVector`.  For M locations and a work-item budget K, the function
  now performs K reads and K extracts rather than M × K of each.

## Bug fixes

* `collect_tern_data()` now predeclares every output column at `NA` at
  planning time.  A per-COG fetch failure leaves the affected column at
  `NA` without removing it from the result, so the column count and
  schema are invariant under network failure (non-SLGA static datasets
  no longer disappear from the result on a transient fetch error).
* `collect_tern_data()` now always emits `lon` and `lat` columns,
  including for single-location calls (previously omitted when only one
  location was passed), standardising the output schema across call
  shapes.
* `.check_collection_agreement()` (SMIPS date validator) now uses the
  documented 2015-11-20 lower bound (was 2005) and emits grammatical,
  dated error messages.  The operator-precedence bug that caused
  non-`totalbucket` collections to bypass the lower-bound check is
  fixed.
* `read_asc(confusion_index = NULL)` previously silently took the
  Confusion-Index branch via `isFALSE(NULL) == FALSE`.  The argument is
  now strictly required to be a single non-`NA` logical.
* `.read_cog(max_tries = 0L)` previously returned `NULL` silently
  because the loop body never executed; now errors with a clear
  message.  Non-integer-coercible `max_tries` (e.g. `"two"`) is also
  rejected.
* `.tern_dispatch_id()` now rejects vector input rather than silently
  collapsing to the first element.  The error message points users to
  `collect_tern_data()` for multi-dataset calls.
* `read_phenology()` with a missing `year` now surfaces the documented
  2003--2018 message rather than R's generic missing-argument message
  (`year` defaults to `NULL`).  The validator also rejects non-integer
  values (e.g. `2018.5`) and vector years.
* Two vignette runnability defects fixed: the agricultural vignette
  previously called `read_smips(day = ...)` (now `date = ...`) and
  contained an injected `collect_tern_data()` section whose output
  schema clobbered the chunk-to-chunk `smips_data` variable used by
  later analytics; replaced with a corrected, `eval=FALSE` showcase
  placed after the analytics.  The intro vignette's two remaining
  `day = ...` calls were also corrected.
* Prose corrections in vignettes: `Yield_tha` → `Yield_Tha` (matches
  the data column name); `Ecological` → `Ecosystem` (TERN's actual
  expansion); `vaporisation` → `volatilisation` (consistent with the
  earlier paragraph and chemistry); `visualalising` → `visualising`;
  `SMindex` scale described as "0--100" rather than "0--1" to match
  the COG.
* `grain` Rd description corrected: `Variety` factor has 8 levels
  (matches `levels(grain$Variety)`), not 10.

## Documentation

* All `portal.tern.org.au/metadata/TERN/<UUID>` Rd references migrated
  to `geonetwork.tern.org.au/...` URLs; several portal URLs returned
  HTTP 404 as of 2026-05, while GeoNetwork resolves all UUIDs.  The
  dead `www.clw.csiro.au/aclep/...` URL replaced with the active
  `esoil.io/TERNLandscapes/...` equivalent.  `urlchecker::url_check()`
  is now clean.

## Internal / API changes

* The `max_tries` and `initial_delay` arguments of all public read
  functions (`read_tern()`, `read_aet()`, `read_asc()`,
  `read_canopy_height()`, `read_phenology()`, `read_slga()`,
  `read_smips()`, `read_soil_diversity()`) now default to `NULL`.
  When `NULL`, values are resolved at call time from
  `getOption("nert.max_tries")` and `getOption("nert.initial_delay")`.
  This is **non-breaking**: existing user code that passes explicit
  integers (e.g., `read_tern("CANOPY", max_tries = 5L)`) continues to
  work unchanged and still overrides the option.

* New internal helper `.init_nert_options()` (in `R/zzz.R`) populates
  the package options on `.onLoad()`. Pattern adapted from the
  rOpenSci [`read.abares`](https://github.com/ropensci/read.abares)
  package.

* `sf` removed from `Imports` (zero references in package code; legacy
  scaffolding from a never-delivered helper).
* `nlme` demoted from `Imports` to `Suggests`; it is used only by the
  agricultural vignette, which already declares
  `%\VignetteDepends{nlme}`.  The `@import nlme` directive that pulled
  it into the namespace without using any of it was removed.
* `tests/testthat/test-validation.R` and a substantially expanded
  `test-collect_tern_data.R` cover the validation paths and the
  work-item planner (37 + 9 deterministic offline tests).

* **Test coverage uplift.** Eight new/expanded offline test files
  (`test-url-snapshots.R`, `test-read_aet.R`, `test-read_slga.R`,
  `test-read_soil_diversity.R`, `test-read_canopy_height.R`,
  `test-read_phenology.R`, `test-collect_tern_data_mocked.R`,
  `test-read_asc.R`) lift package coverage from ~58% to ~83%, with
  every `read_*()` reader at 100%.  Mocking is done at the internal
  `.read_cog()` binding via `testthat::local_mocked_bindings()`;
  `test-url-snapshots.R` pins every URL template via
  `expect_snapshot()`.
* Bumped `testthat (>= 3.0.0)` -> `testthat (>= 3.2.0)` in
  `Suggests` for `local_mocked_bindings()` support.

# nert 0.0.4

## Bug fixes

* AET URL prefix corrected from `/landscapes/aet/v2_2/` to
  `/model-derived/aet/v2_2/` in `.make_aet_url()`. TERN's bucket
  reorganisation moved CMRSET v2.2 under the model-derived classification
  (CMRSET is a CSIRO-modelled output, not a satellite landscape product);
  the legacy path returns 301 → 401 because GDAL `/vsicurl/` does not
  propagate the `apikey:KEY@host` userinfo across the redirect, surfacing
  in R as `[rast] file does not exist`. Verified against the live TERN COG
  listing.

* `read_slga()` now applies `toupper()` to the `attribute` argument before
  `rlang::arg_match()` (rather than inside it), fixing the
  `! 'arg' must be a symbol, not a call.` error reported when running the
  help example.

* `.TERN_ALIASES` casing bug in `.tern_dispatch_id()` resolved (incomplete
  rename surfaced during PR #30; live name is `.tern_aliases`).

* `collect_tern_data()` now correctly expands `depth = "all"` for the eight
  SLGA datasets (AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO) into the six
  GlobalSoilMap depth intervals, producing one column per (dataset, depth)
  named e.g. `AWC_000_005`. Previously the literal string `"all"` was
  passed straight through to `.read_tern_slga()` which rejected it via
  `rlang::arg_match()`; the resulting error was silently swallowed and the
  eight SLGA datasets disappeared from the result. Returning all 14
  datasets at all SLGA depths now yields 60 columns (1 date + 6 SMIPS
  variants + ASC + AET + 8 SLGA x 6 depths + SOILDIV + CANOPY + PHENOLOGY).

* `collect_tern_data()` now surfaces fetch errors via `cli::cli_warn()`
  instead of silently dropping the failed dataset's column. Failed cells
  contain `NA`; the warning identifies the dataset, the date (where
  applicable), and the underlying error message. Pairs with the SLGA fix
  above to ensure the column count of the result matches the verbose
  datasets-table announcement.

## Internal changes

* Removed unused `.create_sf()` helper and its tests. Originally added as
  scaffolding for an `extract_aet()` function that was never delivered.

* Removed unused `.check_not_example_api_key()` helper and its test.

* `withr` added to `Suggests` for test fixtures.

* `tests/testthat/setup.R` loads `TERN_API_KEY` from `~/.Renviron` so the
  network-dependent tests run during `R CMD check` when the user has the
  key configured locally. CI continues to skip the network tests when no
  repository secret is configured — intentional behaviour.

* `roxyglobals` and `moodymudskipper/devtag` integrated for `@autoglobal`
  and `@dev` roxygen tag support; pkgdown reference index now builds
  without internal-helper warnings.

* `Authors@R`: Max Moldovan ORCID added.

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
See <https://www.tern.org.au/news/news-australian-soil-classification-map/> for more on these data.

## Bug fixes

* Spelling corrections
