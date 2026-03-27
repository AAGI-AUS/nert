# Validate dataset-specific arguments before the API key is checked

Runs the same guards as the individual handlers but without requiring an
API key, so that input-validation errors surface in CI and tests even
when `TERN_API_KEY` is not set.

## Usage

``` r
.tern_validate_args(did, dots, dataset_id)
```

## Arguments

- did:

  Normalised 8-char dataset ID from
  [`.tern_dispatch_id()`](https://aagi-aus.github.io/nert/reference/dot-tern_dispatch_id.md).

- dots:

  Named list of `...` arguments from the caller.

- dataset_id:

  The raw `dataset_id` for error messages.

## Value

`NULL` (invisibly); called for its side effects (errors).
