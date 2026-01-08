# Get or Set Up API Key for TERN

Checks first to get key from your .Rprofile or .Renviron (or similar)
file. If it's not found, then it suggests setting it up. Can be used to
check that your key that R is using is the key that you wish to be using
or for guidance in setting up the keys.

## Usage

``` r
get_key()
```

## Value

A string value with your API key value.

## Note

TERN creates API keys that have special characters that include “/”,
which causes the query to fail. Currently, `get_key()` checks for this
in the `API_KEY` string and replaces it with “%2f” so that the query
will work properly.

## Requesting an API Key

To request an API key, go to
<https://account.tern.org.au/authenticated_user/apikeys> and click on
"Sign In" in the upper right corner. Sign in with your proper
credentials. Then, from the left-hand menu, click on "Create API Key".
Once this is done, copy the key and put it in your .Renviron using
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html)
as `TERN_API_KEY="your_api_key"`. Restart your R session and the query
should work.

The suggestion is to use your .Renviron to set up the API key. However,
if you regularly interact with the APIs outside of R using some other
language you may wish to set these up in your .bashrc, .zshrc, or
config.fish for cross-language use.

## Examples

``` r
if (FALSE) { # \dontrun{
get_key()
} # }
```
