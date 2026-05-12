# Changelog

## nert 0.0.4

### Bug fixes

- AET URL prefix corrected from `/landscapes/aet/v2_2/` to
  `/model-derived/aet/v2_2/` in
  [`.make_aet_url()`](https://aagi-aus.github.io/nert/reference/dot-make_aet_url.md).
  TERN’s bucket reorganisation moved CMRSET v2.2 under the model-derived
  classification (CMRSET is a CSIRO-modelled output, not a satellite
  landscape product); the legacy path returns 301 → 401 because GDAL
  `/vsicurl/` does not propagate the `apikey:KEY@host` userinfo across
  the redirect, surfacing in R as `[rast] file does not exist`. Verified
  against the live TERN COG listing.

- [`read_slga()`](https://aagi-aus.github.io/nert/reference/read_slga.md)
  now applies [`toupper()`](https://rdrr.io/r/base/chartr.html) to the
  `attribute` argument before
  [`rlang::arg_match()`](https://rlang.r-lib.org/reference/arg_match.html)
  (rather than inside it), fixing the
  `! 'arg' must be a symbol, not a call.` error reported when running
  the help example.

- `.TERN_ALIASES` casing bug in
  [`.tern_dispatch_id()`](https://aagi-aus.github.io/nert/reference/dot-tern_dispatch_id.md)
  resolved (incomplete rename surfaced during PR
  [\#30](https://github.com/AAGI-AUS/nert/issues/30); live name is
  `.tern_aliases`).

- [`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
  now correctly expands `depth = "all"` for the eight SLGA datasets
  (AWC, CLY, SND, SLT, BDW, PHC, PHW, NTO) into the six GlobalSoilMap
  depth intervals, producing one column per (dataset, depth) named
  e.g. `AWC_000_005`. Previously the literal string `"all"` was passed
  straight through to
  [`.read_tern_slga()`](https://aagi-aus.github.io/nert/reference/dot-read_tern_slga.md)
  which rejected it via
  [`rlang::arg_match()`](https://rlang.r-lib.org/reference/arg_match.html);
  the resulting error was silently swallowed and the eight SLGA datasets
  disappeared from the result. Returning all 14 datasets at all SLGA
  depths now yields 60 columns (1 date + 6 SMIPS variants + ASC + AET +
  8 SLGA x 6 depths + SOILDIV + CANOPY + PHENOLOGY).

- [`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
  now surfaces fetch errors via
  [`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html)
  instead of silently dropping the failed dataset’s column. Failed cells
  contain `NA`; the warning identifies the dataset, the date (where
  applicable), and the underlying error message. Pairs with the SLGA fix
  above to ensure the column count of the result matches the verbose
  datasets-table announcement.

### Internal changes

- Removed unused `.create_sf()` helper and its tests. Originally added
  as scaffolding for an `extract_aet()` function that was never
  delivered.

- Removed unused `.check_not_example_api_key()` helper and its test.

- `withr` added to `Suggests` for test fixtures.

- `tests/testthat/setup.R` loads `TERN_API_KEY` from `~/.Renviron` so
  the network-dependent tests run during `R CMD check` when the user has
  the key configured locally. CI continues to skip the network tests
  when no repository secret is configured — intentional behaviour.

- `roxyglobals` and `moodymudskipper/devtag` integrated for
  `@autoglobal` and `@dev` roxygen tag support; pkgdown reference index
  now builds without internal-helper warnings.

- `Authors@R`: Max Moldovan ORCID added.

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
