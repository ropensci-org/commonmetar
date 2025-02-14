# https://github.com/r-lib/hugodown/blob/f6f23dd74ce531a9957149fae15e92c7144abac2/R/hugo-install.R#L1
#' Install latest version of commonmeta
#'
#' Downloads binary from commonmeta releases, and installs in system wide cache.
#'
#' @param os Operating system, one of "Linux", "Windows", "macOS". Defaults
#'   to current operating system.
#' @param arch Architecture
#' @param force Whether to force a re-install/trigger an update.
#' @export
#' @examples
#' \dontrun{
#' commonmeta_install()
#' }
commonmeta_install <- function(os = commonmeta_os(), arch = "x86_64", force = FALSE) {
  rlang::check_installed("gh")

  message("Finding release")
  release <- commonmeta_release(os, arch)

  home <- commonmeta_home(os, arch)
  if (file.exists(home)) {
    if (!force) {
      message("commonmeta already installed")
      release$version
      return(invisible())
    } else {
      fs::file_delete(home)
    }
  }

  message("Downloading ", fs::path_file(release$url), "...")
  temp <- curl::curl_download(release$url, tempfile())

  message("Installing to ", fs::path_dir(home), "...")
  switch(fs::path_ext(release$url),
    "gz" = utils::untar(temp, exdir = home, tar = "internal"),
    "zip" = utils::unzip(temp, exdir = home)
  )

  invisible()
}


commonmeta_installed <- function() {
  path_file(dir_ls(rappdirs::user_cache_dir("commonmetar")))
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
  version <- sub("^v", "", json[[1]]$tag_name)

  assets <- json[[1]]$assets
  names <- vapply(assets, "[[", "name", FUN.VALUE = character(1))

  asset_name <- commonmeta_asset_name(version, os, arch)
  asset_i <- which(asset_name == names)
  if (length(asset_i) != 1) {
    cli::cli_abort(paste0("Can't find release asset with name '", asset_name, "'"))
  }

  list(version = version, url = assets[[asset_i]]$browser_download_url)
}

commonmeta_releases <- function() {
  gh::gh(
      "GET /repos/:owner/:repo/releases",
      owner = "front-matter",
      repo = "commonmeta",
      .limit = 1,
      .progress = FALSE
    )
}

commonmeta_asset_name <- function(
                            version,
                            os = c("Linux", "Windows", "macOS"),
                            arch = "x86_64") {

  os <- rlang::arg_match(os)
  ext <- switch(os, Windows = ".zip", macOS = , Linux = ".tar.gz")

  paste0(
    "commonmeta_",
    os, "_", arch, ext
  )
}

commonmeta_os <- function() {
  sysname <- tolower(Sys.info()[["sysname"]])
  switch(sysname,
    darwin = "macOS",
    linux = "Linux",
    windows = "Windows",
    abort("Unknown operating system; please set `os`")
  )
}
