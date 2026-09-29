#' Show the Available TERN Datasets
#'
#' Returns one row for each dataset that [read_tern()] and
#'   [collect_tern_data()] can read.
#'
#' @returns A `data.frame` with columns `alias` (the short name to pass as
#'   `dataset_id` or in `datasets`), `id` (the \acronym{TERN} dataset ID),
#'   `temporal` (how often the data are published), `resolution` and
#'   `description`.
#'
#' @examples
#' show_datasets()
#'
#' @export
show_datasets <- function() {
  field <- function(name) {
    return(vapply(.tern_datasets, `[[`, character(1L), name))
  }
  return(data.frame(
    alias = field("alias"),
    id = paste0("TERN/", names(.tern_datasets)),
    temporal = field("temporal"),
    resolution = field("resolution"),
    description = field("description"),
    row.names = NULL
  ))
}
