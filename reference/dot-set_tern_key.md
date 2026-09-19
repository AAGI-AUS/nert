# Help the User Request an API Key for the TERN API

Opens a browser window at the TERN API key request URL and provides
instruction on how to store the key. After filling the form you will get
the key soon, but not immediately.

## Usage

``` r
.set_tern_key(reports = character())
```

## Arguments

- reports:

  A `character` vector of what each credential store raised, listed in
  the error.

## Value

Called for its side-effects, shows instructions for acquiring and
storing a key and raises an error of class `nert_no_key`.
