# Dataset registry

Single source of truth mapping each dataset's normalised 8-char dispatch
ID to its short alias, optional argument validator, and read handler.
The dispatch path in
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

## Details

Each entry is a `list` with an `alias` (upper-case short name), a `read`
handler invoked as `read(did, dots, api_key, max_tries, initial_delay)`,
and an optional `validate` function invoked as
`validate(dots, dataset_id)` before the API key is checked. Both the
validator (where present) and the handler live in the dataset's own
`R/read_<name>.R` file. Datasets with no pre-key argument validation
simply omit `validate`.
