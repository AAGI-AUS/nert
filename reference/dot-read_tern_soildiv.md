# Internal handler for Soil Beta Diversity (TERN/4a428d52)

Reads NMDS ordination axes for Bacteria or Fungi.

## Usage

``` r
.read_tern_soildiv(dots, api_key, max_tries, initial_delay)
```

## Arguments

- dots:

  Named list including `kingdom` and `axis` if provided.

- api_key, max_tries, initial_delay:

  Passed to
  [`.read_cog()`](https://aagi-aus.github.io/nert/reference/dot-read_cog.md).
