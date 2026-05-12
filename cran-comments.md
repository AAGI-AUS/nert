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

This is a new release; there are no reverse dependencies on CRAN.
`revdepcheck::revdep_check()` returns an empty result.

## Submission notes

* First CRAN submission of `nert` (TERN data API client).
* User-facing API surface is small (11 exports) and stable on the 0.0.x
  development line; we expect to move to 0.1.0 after CRAN acceptance.
* No bundled compiled code; all data access is via `terra::rast()` over
  `/vsicurl/` against `data.tern.org.au`.
