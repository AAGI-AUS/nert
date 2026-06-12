# Internal handler for retrieving Soil Beta Diversity datasets

Internal handler for retrieving Soil Beta Diversity datasets

## Usage

``` r
.read_tern_soil_diversity(did, dots, api_key, max_tries, initial_delay)
```

## Arguments

- did:

  Normalised 8-char dataset ID (unused; uniform handler signature).

- dots:

  Named list of `...` args from
  [`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md).

- api_key:

  URL-encoded API key.

- max_tries, initial_delay:

  Passed to
  [`.read_cog()`](https://aagi-aus.github.io/nert/reference/dot-read_cog.md).
