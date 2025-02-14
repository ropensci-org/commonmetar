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
  # TODO: check this works on windows
    process <- processx::run(
      "./commonmeta",
      args = c("encode", prefix),
      wd = commonmeta_home()
    )

  trimws(process[["stderr"]])
}
