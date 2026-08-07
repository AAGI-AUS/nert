# Help the User Request an API Key for the TERN API

Opens a browser window at the TERN API key request URL and provides
instruction on how to store the key. After filling the form you will get
the key soon, but not immediately.

## Usage

``` r
.set_tern_key()
```

## Value

Called for its side-effects, checks for presence of a TERN key in the
user's key ring and errors if one is not found with instructions for
acquiring one.
