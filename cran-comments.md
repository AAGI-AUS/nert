## Test environments

* local macOS, R 4.5 (current release)
* GitHub Actions: Ubuntu (latest), macOS (latest), Windows (latest), each
  on R-release / R-devel / R-oldrel-1
* `devtools::check_win_devel()`
* `rhub::rhub_check()` (rhub v2; GitHub-Actions-backed)

## R CMD check results

0 errors | 0 warnings | 0 notes (intended at submission time).

If NOTEs remain at submission, each must be itemised here individually with
a one-line justification per NOTE. Aggregate "N notes" summaries are not
acceptable.

| NOTE | Category | Justification |
| --- | --- | --- |
| _none yet_ | _intrinsic / environmental / source-fix-attempted / deferred-with-reason_ | _to be filled in at submission_ |

## Reverse dependencies

`nert` is not yet on CRAN; there are no reverse dependencies.
`revdepcheck::revdep_check()` returns an empty result.

## Submission notes

* This is the first stable release of `nert` (TERN data API client),
  version 1.0.0.  It follows the development line `0.0.1` → `0.0.4` and
  consolidates the user-facing API surface (11 exports covering 14
  TERN datasets through a unified `read_tern()` dispatcher and the
  batch primitive `collect_tern_data()`) together with the audit-driven
  pre-CRAN polish.  The audit findings folded in are itemised below.
* No bundled compiled code; all data access is via `terra::rast()` over
  `/vsicurl/` against `data.tern.org.au`.
* All metadata-page references in Rd were migrated from
  `portal.tern.org.au/metadata/TERN/<UUID>` (which returns 404 for several
  datasets as of 2026-05) to
  `geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/<UUID>`
  (which resolves with HTTP 200 for every dataset shipped by the package).
  Confirmed clean with `urlchecker::url_check()`.
* Examples in exported functions are guarded with `@examplesIf interactive()`
  because they require a valid `TERN_API_KEY` environment variable to fetch
  COG data over `/vsicurl/`.  `R CMD check --as-cran` therefore neither
  attempts nor counts the network-bound examples.

## Audit findings folded into this release

The following items are documented in `NEWS.md` under 1.0.0:

* **Vignette runnability** — both bundled vignettes corrected to call
  `read_smips(date = ...)`; the agricultural vignette's `xy = ` argument
  no longer references columns that `collect_tern_data()` cannot resolve;
  prose typos `Yield_tha`, `vaporisation`, `Ecological`, `visualalising`,
  `SMindex 0–1` fixed.
* **`collect_tern_data()` vectorisation** — refactored from a per-location
  outer loop (M×K COG opens and extractions) to a per-COG loop (K COG
  opens and extractions, `terra::extract()` invoked once with all
  coordinates per work item).
* **Schema invariance under failure** — output columns are predeclared at
  NA at planning time; a per-COG fetch failure leaves the column at NA
  without removing it from the output, so column count matches the
  user-facing summary regardless of network state.
* **Input validation** — `.read_cog(max_tries = 0L)` no longer silently
  returns NULL; `read_asc(confusion_index = NULL)` no longer takes the
  Confusion-Index branch; `.tern_dispatch_id(c('a','b'))` no longer silently
  collapses to the first element; `read_phenology()` with a missing year
  surfaces the documented 2003–2018 message rather than R's generic
  missing-argument message; phenology year now rejects non-integer
  values rather than truncating.
* **Date-bounds validator** — `.check_collection_agreement()` now uses
  the documented 2015-11-20 lower bound (was 2005) and emits a
  grammatical, dated message; the operator-precedence bug that caused
  non-`totalbucket` collections to be only upper-bound checked is fixed.
* **Dependency footprint** — `sf` removed from Imports (zero references
  in package code); `nlme` demoted to Suggests (used only by the
  agricultural vignette, which already declares `%\VignetteDepends{nlme}`).
* **Dead/redirected URLs** — `portal.tern.org.au/metadata/...` references
  migrated to GeoNetwork; the `www.clw.csiro.au/aclep/...` reference
  (now NXDOMAIN) replaced with `esoil.io/TERNLandscapes/...` (HTTP 200);
  the `tern.org.au/news-...` redirect target updated to its current path.

A complete commit summary for reviewers is available in the branch
`cleanup/cran-prep-1.1.0` (PR #41).
