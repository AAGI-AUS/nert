# Internal handler for SLGA soil attributes

A generic handler that covers all eight SLGA soil attributes. Each
attribute has a fixed file-naming pattern encoded in
[.slga_config](https://aagi-aus.github.io/nert/reference/dot-slga_config.md).

## Usage

``` r
.read_tern_slga(did, dots, api_key, max_tries, initial_delay)
```

## Arguments

- did:

  Normalised dispatch ID (e.g.\\ `"482301c2"`, `"slga_cly"`).

- dots:

  Named list of `...` args from
  [`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md).

- api_key:

  URL-encoded API key.

- max_tries, initial_delay:

  Passed to
  [`.read_cog()`](https://aagi-aus.github.io/nert/reference/dot-read_cog.md).
