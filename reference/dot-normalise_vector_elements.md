# Helper function: resolve the given `character` vector to its valid elements

Helper function: resolve the given `character` vector to its valid
elements

## Usage

``` r
.normalise_vector_elements(vec, valid_elements, info)
```

## Arguments

- vec:

  A `character` vector (of user-supplied elements, e.g., dataset names,
  variants), or `NULL`/`"all"`.

- valid_elements:

  A `character` vector containing the valid elements against which the
  `given_vec` vector should be compared.

- info:

  A `character` string that describes the elements in `given_vec` (so
  that errors/warnings are more informative).

## Value

A `character` vector of valid elements (de-duplicated, order preserved).
