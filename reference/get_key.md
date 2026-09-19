# Get or Set Up API Key for TERN

Fetches your TERN API key through keyring. If no key is found,
instructions for setting one up are shown and an error is raised. Can be
used to check that the key that R is using is the key that you wish to
be using, or for guidance in setting the key up in the first place.

## Usage

``` r
get_key()
```

## Value

A string value with your API key value.

## Requesting an API Key

To request an API key, go to
<https://account.tern.org.au/authenticated_user/apikeys> and click on
"Sign In" in the upper right corner. Sign in with your proper
credentials. Then, from the left-hand menu, click on "Create API Key".
Copy the key before leaving the page, as it cannot be read back
afterwards.

## Storing your key

nert reads the key through keyring, a suggested package, so install it
first with `install.packages("keyring")`.

The `"nert"` keyring is read first, where the backend supports named
keyrings:

    library(keyring)
    keyring_create("nert")
    key_set("TERN_API_KEY", keyring = "nert")

A key held in the default store is used as well. On macOS this is the
login keychain, which unlocks when you log in:

    library(keyring)
    key_set("TERN_API_KEY")

On a machine with no password manager, keyring reads the environment
instead. Set both variables in the `.Renviron` file that
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html)
opens, then restart R:

    R_KEYRING_BACKEND=env
    TERN_API_KEY=your_api_key

## Examples

``` r
if (FALSE) { # \dontrun{
get_key()
} # }
```
