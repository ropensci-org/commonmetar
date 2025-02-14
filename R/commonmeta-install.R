# https://github.com/r-lib/hugodown/blob/f6f23dd74ce531a9957149fae15e92c7144abac2/R/hugo-install.R#L1 # nolint: line_length_linter
#' Install latest version of commonmeta
#'
#' Downloads binary from
#' [commonmeta](https://github.com/front-matter/commonmeta) releases,
#' and installs in system wide cache.
#'
#' @param os Operating system, one of "Linux", "Windows", "Darwin". Defaults
#'   to current operating system.
#' @param arch Architecture
#' @param force Whether to force a re-install/trigger an update.
#' @export
#' @examples
#' \dontrun{
#' commonmeta_install()
#' }
commonmeta_install <- function(os = commonmeta_os(),
                               arch = "x86_64",
                               force = FALSE) {
  rlang::check_installed("gh")

  message("Finding release")
  release <- commonmeta_release(os, arch)

  home <- commonmeta_home(os, arch)
  if (file.exists(home)) {
    if (force) {
      fs::file_delete(home)
    } else {
      message("commonmeta already installed")
      release[["version"]]
      return(invisible())
    }
  }

  message("Downloading ", fs::path_file(release[["url"]]), "...")
  temp <- curl::curl_download(release[["url"]], tempfile())

  message("Installing to ", fs::path_dir(home), "...")
  switch(fs::path_ext(release[["url"]]),
    gz = utils::untar(temp, exdir = home, tar = "internal"),
    zip = utils::unzip(temp, exdir = home)
  )

  invisible(fs::path_dir(home))
}


commonmeta_installed <- function() {

  if (nzchar(Sys.getenv("commonmetar.commonmeta.not.here"))) {
    return(FALSE)
  }

  process <- try(processx::run(
    "./commonmeta", # nolint: nonportable_path_linter
    args = "help",
    wd = commonmeta_home()
  ), silent = TRUE)

  !inherits(process, "try-error") && (process[["status"]] == 0L)
}

commonmeta_home <- function(os = commonmeta_os(), arch = "x86_64") {
  cache_dir <- rappdirs::user_cache_dir("commonmetar")
  fs::dir_create(cache_dir)

  commonmeta <- paste0(
    "commonmeta", "_",
    os, "_", arch
  )
  fs::path(cache_dir, commonmeta)
}

commonmeta_release <- function(os = commonmeta_os(), arch = "x86_64") {

  json <- commonmeta_releases()
  version <- sub("^v", "", json[[1L]][["tag_name"]])

  assets <- json[[1L]][["assets"]]
  names <- vapply(assets, "[[", "name", FUN.VALUE = character(1L))

  asset_name <- commonmeta_asset_name(version, os, arch)
  asset_i <- which(asset_name == names)
  if (length(asset_i) != 1L) {
    cli::cli_abort("Can't find release asset with name {.val {asset_name}}.")
  }

  list(version = version, url = assets[[asset_i]][["browser_download_url"]])
}

commonmeta_releases <- function() {
  gh::gh(
    "GET /repos/:owner/:repo/releases",
    owner = "front-matter",
    repo = "commonmeta",
    .limit = 1L,
    .progress = FALSE
  )
}

commonmeta_asset_name <- function(version,
                                  os = c("Linux", "Windows", "Darwin"),
                                  arch = "x86_64") {

  os <- rlang::arg_match(os)
  ext <- switch(os, Windows = ".zip", Darwin = , Linux = ".tar.gz")

  paste0(
    "commonmeta_",
    os, "_", arch, ext
  )
}

commonmeta_os <- function() {
  sysname <- tolower(Sys.info()[["sysname"]])
  switch(sysname,
    darwin = "Darwin",
    linux = "Linux",
    windows = "Windows",
    cli::cli_abort("Unknown operating system; please set `os`")
  )
}
