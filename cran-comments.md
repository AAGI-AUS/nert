# cran-comments.md — nert 0.1.0

## Submission summary

This is the first CRAN submission of `nert`. The package provides an R API
client for Australia's Terrestrial Ecosystem Research Network (TERN) data,
covering 14 soil, canopy, and phenology datasets accessed as Cloud-Optimised
GeoTIFFs via `terra::rast()` over `/vsicurl/`.

## Test environments

| Environment | R version | Result |
| --- | --- | --- |
| Local macOS 25.4 (arm64) | R 4.5.2 | 0 ERRORs, 0 WARNINGs, _N_ NOTEs (see below) |
| GitHub Actions, ubuntu-latest | R-devel | 0E / 0W / _N_ NOTEs |
| GitHub Actions, ubuntu-latest | R-release | 0E / 0W / _N_ NOTEs |
| GitHub Actions, ubuntu-latest | R-oldrel-1 | 0E / 0W / _N_ NOTEs |
| GitHub Actions, macos-latest | R-release | 0E / 0W / _N_ NOTEs |
| GitHub Actions, windows-latest | R-release | 0E / 0W / _N_ NOTEs |
| `devtools::check_win_devel()` | R-devel (Windows) | _to be run pre-release_ |
| `rhub::rhub_check()` | linux + macos + windows | _to be run pre-release_ |

The matrix entries marked _to be run pre-release_ will be populated and the
results pasted in here before submission.

## R CMD check results

`R CMD check --as-cran nert_0.1.0.tar.gz` on local macOS (R 4.5.2,
aarch64-apple-darwin20):

```
0 ERRORs, 0 WARNINGs, 2 NOTEs.
```

### NOTE-by-NOTE itemisation

Each NOTE that survives the cleanup is enumerated here with a category and a
one-line justification. CRAN policy requires per-NOTE rationale; aggregate
"_N_ NOTEs" summaries are not acceptable.

| # | NOTE excerpt | Category | Justification |
| --- | --- | --- | --- |
| 1 | "New submission" (incoming feasibility) | intrinsic | First CRAN submission of `nert`; this NOTE will not appear after acceptance. |
| 2 | "Skipping checking HTML validation: 'tidy' doesn't look like recent enough HTML Tidy" | environmental | Local-toolchain NOTE arising from the macOS HTML-Tidy version on the maintainer's machine; does not fire on CRAN's check farm or on GitHub-Actions runners (which ship with current HTML Tidy). |

If a NOTE appears at submission time that is not listed above, it will be
added before the upload, with an explicit category from {intrinsic /
environmental / source-fix-attempted / deferred-with-reason}.

## Reverse dependencies

This is a new release. There are currently no downstream dependencies for
this package. `revdepcheck::revdep_check()` is not applicable; nothing on
CRAN depends on, imports, or suggests `nert`.

## Submission notes

* User-facing API surface is intentionally small (11 exports, all
  `read_*()`, `collect_tern_data()`, `get_key()`, plus a re-exported
  `ggplot2::autoplot` generic).
* No bundled compiled code; all data access is via `terra::rast()` over
  `/vsicurl/` URLs against `data.tern.org.au`. No on-disk caching by
  default; no writes outside `tempdir()`.
* All examples that hit the network are wrapped in either
  `@examplesIf interactive()` or `\dontrun{}`, so the CRAN check farm does
  not require a `TERN_API_KEY` to build.
* Vignettes are precompiled from `*.Rmd.orig` sources via
  `vignettes/!precompile.R`, so `R CMD build` does not hit the network.
* Australian/British English throughout (`Language: en-AU` in DESCRIPTION).

## Maintainer commitment

`Sam Rogers <sam.rogers@adelaide.edu.au>` (cre) is a real, monitored email
account at the University of Adelaide. The maintainer commits to responding
to CRAN-team correspondence within 14 days during business periods.
