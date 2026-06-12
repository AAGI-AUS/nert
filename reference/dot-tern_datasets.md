# Dataset registry

Single source of truth mapping each dataset's normalised 8-char dispatch
ID to its short alias and read handler. Both the dispatch path in
[`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md)
and the
[.tern_aliases](https://aagi-aus.github.io/nert/reference/dot-tern_aliases.md)
lookup are derived from this list, so a dataset is defined in one place.
The SLGA entries are generated from
[.slga_config](https://aagi-aus.github.io/nert/reference/dot-slga_config.md).

## Usage

``` r
.tern_datasets
```

## Format

An object of class `list` of length 20.

## Details

Each entry is a `list` with an `alias` (upper-case short name) and a
`read` handler invoked as
`read(did, dots, api_key, max_tries, initial_delay)`.
