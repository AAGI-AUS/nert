# nert 1.0.1

## Performance

* `collect_tern_data()` is now vectorised across locations. Previously the
  function looped over (location, dataset, date) tuples and called
  `read_tern()` + `terra::extract()` once per single point, redownloading
  the same Cloud Optimised GeoTIFF (COG) once per location. The
  refactored version plans a list of *work items* (one item per unique
  COG), opens each COG once via `/vsicurl/`, and calls
  `terra::extract()` once with all coordinates passed as a single
  `SpatVector`. For M locations and a work-item budget K, the function
  now performs K reads and K extracts rather than M × K of each.

## Bug fixes

* `collect_tern_data()` now predeclares every output column at `NA` at
  planning time. A per-COG fetch failure leaves the affected column at
  `NA` without removing it from the result, so the column count and
  schema are invariant under network failure (previously, non-SLGA
  static datasets could disappear from the result silently).
* `.check_collection_agreement()` (SMIPS date validator) now uses the
  documented 2015-11-20 lower bound (was 2005) and emits grammatical,
  dated error messages. The operator-precedence bug that caused
  non-`totalbucket` collections to bypass the lower-bound check is fixed.
* `read_asc(confusion_index = NULL)` previously silently took the
  Confusion-Index branch via `isFALSE(NULL) == FALSE`. The argument is
  now strictly required to be a single non-`NA` logical.
* `.read_cog(max_tries = 0L)` previously returned `NULL` silently
  because the loop body never executed; now errors with a clear message.
  Non-integer-coercible `max_tries` (e.g. `"two"`) is also rejected.
* `.tern_dispatch_id()` now rejects vector input rather than silently
  collapsing to the first element. The error message points users to
  `collect_tern_data()` for multi-dataset calls.
* `read_phenology()` with a missing `year` now surfaces the documented
  2003--2018 message rather than R's generic missing-argument message
  (`year` defaults to `NULL`). The validator also rejects non-integer
  values (e.g. `2018.5`) and vector years.
* Two vignette runnability defects fixed: the agricultural vignette
  previously called `read_smips(day = ...)` (now `date = ...`) and
  contained an injected `collect_tern_data()` section whose output
  schema clobbered the chunk-to-chunk `smips_data` variable used by
  later analytics; replaced with a corrected, `eval=FALSE` showcase
  placed after the analytics. The intro vignette's two remaining
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
  HTTP 404 as of 2026-05, while GeoNetwork resolves all UUIDs.
  The dead `www.clw.csiro.au/aclep/...` URL replaced with the active
  `esoil.io/TERNLandscapes/...` equivalent. `urlchecker::url_check()`
  is now clean.

## Internal changes

* `sf` removed from Imports (zero references in package code; legacy
  scaffolding from a never-delivered helper).
* `nlme` demoted from Imports to Suggests; it is used only by the
  agricultural vignette, which already declares
  `%\VignetteDepends{nlme}`. The `@import nlme` directive that pulled
  it into the namespace without using any of it was removed.
* `tests/testthat/test-validation.R` and a substantially expanded
  `test-collect_tern_data.R` cover the new validation paths and the
  new work-item planner (37 + 9 deterministic offline tests).

# nert 1.0.0

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
