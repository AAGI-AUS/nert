# Initialise nert package options (internal)

Extracted from `.onLoad()` to allow direct unit testing. Sets
package-level defaults for the retry behaviour shared by every
`read_*()` and
[`collect_tern_data()`](https://aagi-aus.github.io/nert/reference/collect_tern_data.md)
call:

- `nert.max_tries` — integer, default `3L`

- `nert.initial_delay` — integer (seconds), default `1L`

## Usage

``` r
.init_nert_options()
```

## Value

`NULL`, invisibly. Called for its side effect on
[`base::options()`](https://rdrr.io/r/base/options.html).

## Details

Existing user-set values (e.g. set in `.Rprofile` or via
[`base::options()`](https://rdrr.io/r/base/options.html) before
[`library(nert)`](https://aagi-aus.github.io/nert/)) are preserved; only
unset options are populated with defaults.
