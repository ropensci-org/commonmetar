commonmeta_doi <- function(prefix = "10.59350") {
  withr::with_dir(commonmeta_home(), {
    process <- processx::run("./commonmeta", args = c("encode", prefix))
  })

  trimws(process[["stderr"]])
}
