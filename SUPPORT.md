# Getting help with `nert`

Thank you for your interest in `nert`. There are several places to get help.

## Questions about how to use the package

* Open a [GitHub Discussion](https://github.com/AAGI-AUS/nert/discussions)
  if the question is broad ("how would I use `read_tern()` to do X").
* Open a [GitHub Issue](https://github.com/AAGI-AUS/nert/issues) if you
  believe you have hit a bug or surprising behaviour. Please include a
  minimal reproducible example.

## Reporting bugs

* Confirm the bug is current by running the issue against the latest
  release (or the development version from `main`).
* Open an Issue with:
  - the `sessionInfo()` output,
  - a minimal reproducible example,
  - the exact error message or unexpected output.

## TERN data access

Issues that turn out to be upstream problems with the TERN portal or COG
endpoints (404s, 401s, schema changes, dataset deprecations) are best
raised with TERN directly via <https://www.tern.org.au/contact-us/>;
please open a `nert` Issue in parallel so other users can find the
diagnostic notes.

## Maintenance capacity

`nert` is maintained on a best-effort basis by the AAGI team. Response
time on issues and PRs is typically within two to four weeks.

| Role | Person | GitHub |
|---|---|---|
| Maintainer (`cre`) | Sam Rogers | @samroge |
| Authors (`aut`) | Adam Sparks, Wasin Pipattungsakul, Russell Edson, Max Moldovan | @adamhsparks, @WasinPip, @RussellEdson, @maxmoldovan |
| Funding | GRDC project CUR2210-005OPX | — |

If response is needed sooner than two weeks for a specific question, a
direct email to the maintainer is acceptable; please understand that
this is not a hard SLA.

## Security disclosures

Please do not file public issues for security-relevant findings. Email
the maintainer directly. A formal `SECURITY.md` is on the roadmap.
