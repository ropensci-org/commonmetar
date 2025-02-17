#' Generate random DOI string
#'
#' @param prefix DOI prefix
#'
#' @return A random DOI string
#' @export
#'
#' @examplesIf interactive()
#' commonmeta_doi()
commonmeta_doi <- function(prefix = "10.59350") {

  if (!commonmeta_installed()) {
    cli::cli_abort(c(
      "commonmeta must be installed",
      "see {.fun commonmetar::commonmeta_install}."
    ))
  }

  process <- processx::run(
    "./commonmeta", # nolint: nonportable_path_linter
    args = c("encode", prefix),
    wd = commonmeta_home()
  )

  doi <- sub(
    ".*doi\\.\\org/",
    "",
    trimws(process[["stderr"]])
  )

  if (rlang::is_interactive()) {
    clipr::write_clip(doi)
    cli::cli_alert_success("Copied {.val {doi}} to clipboard.")
  }

  doi
}
