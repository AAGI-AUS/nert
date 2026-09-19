# Read the TERN API Key From One Credential Store

Reports the key or what the store raised when no key is supplied.

## Usage

``` r
.read_tern_key(backend, keyring)
```

## Arguments

- backend:

  The keyring backend, from
  [`keyring::default_backend()`](https://keyring.r-lib.org/reference/backends.html).

- keyring:

  Name of the keyring to read, or `NULL` for the default store.

## Value

A named `list`: `key`, empty when no key was supplied, and `report`,
what the store raised.
