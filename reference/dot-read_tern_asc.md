# Internal handler for ASC (`TERN/15728dba`)

Internal handler for ASC (`TERN/15728dba`)

## Usage

``` r
.read_tern_asc(dots, api_key, max_tries, initial_delay)
```

## Arguments

- dots:

  Named list of `...` args from
  [`read_tern()`](https://aagi-aus.github.io/nert/reference/read_tern.md).

- api_key:

  URL-encoded API key.

- max_tries, initial_delay:

  Passed to
  [`.read_cog()`](https://aagi-aus.github.io/nert/reference/dot-read_cog.md).
