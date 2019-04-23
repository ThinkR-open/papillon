#' Create a function inside R folder in your package to open pkgdown website
#'
#' @param path Path to the pkgdown inside your package
#'
#' @export
open_pkgdown_function <- function(path = "docs") {

  pkg_name <- read.dcf("DESCRIPTION")[1,"Package"]
  fun_template <- system.file("templates/open_pkgdown_template.R", package = "visualidentity")

  if (!dir.exists(path)) {
   stop("There is no directory: ", path)
  }

  cat(paste(readLines(fun_template), collapse = "\n"),
      "\n",
      "open_pkgdown <- function() {
      guide_path <- system.file('", file.path(path, "index.html"), "', package = '", pkg_name, "')
      if (guide_path == \"\") {
        stop('There is no pkgdown site in ', '", file.path(path, "index.html"),"')
      }

  browseURL(paste0('file://', guide_path))
}
", sep = "", file = "R/open_pkgdown.R")

  message(paste0("You can add in your package documentation to open pkgdown site using: ",
                 pkg_name, "::open_pkgdown()"))
  message("Run 'devtools::document()'")
}

#' Build pkgdown site and move to inst
#'
#' If "docs" is not in "inst" folder, it will not be available to the users
#'
#' @param move Logical. Whether to move the "docs" folder in "inst" to be kept in the package
#' @param clean_before Logical. Whether to empty the "docs" and "inst/docs" prior to build site
#' @param clean_after Logical. Whether to remove the original "docs" folder at the root of the project
#' @param yml path to custom "_pkgdown.yml" file
#' @param favicon path to favicon
#' @param ... Other parameters needed by \code{\link{build_site}}
#'
#' @inheritParams pkgdown::build_site
#'
#' @importFrom pkgdown build_site
#' @importFrom usethis use_build_ignore
#'
#' @export
build_pkgdown <- function(move = TRUE, clean_before = TRUE, clean_after = TRUE,
                          yml, favicon, preview = NA, ...) {

  if (!missing(yml)) {
    file.copy(yml, "_pkgdown.yml", overwrite = TRUE)
    use_build_ignore("_pkgdown.yml")
  }

  if (isTRUE(clean_before)) {
    unlink("docs", recursive = TRUE)
    unlink("inst/docs", recursive = TRUE)
  }

  use_build_ignore("docs")
  pkgdown::build_site(..., preview = FALSE)

  if (!missing(favicon)) {
    ext <- strsplit(favicon, "\\.")[[1]]
    ext <- ext[length(ext)]
    file.copy(favicon, paste0("docs/favicon.", ext), overwrite = TRUE)
  }

  if (isTRUE(move)) {
    files <- list.files("docs", recursive = TRUE)
    invisible(
      lapply(file.path("inst/docs", sort(unique(dirname(files)))),
             function(x) if (!dir.exists(x)) dir.create(x, recursive = TRUE, showWarnings = FALSE))
    )
    file.copy(file.path("docs", files), file.path("inst","docs", files), overwrite = TRUE)
  }

  if (isTRUE(clean_after)) {
    unlink("docs", recursive = TRUE)
  }

  if (is.na(preview)) {
    preview <- interactive()
  }
  if (preview) {
    pkg <- pkgdown::as_pkgdown(".")
    cli::rule("Previewing site")
    utils::browseURL(file.path(pkg$src_path, "inst", "docs", "index.html"))
  }
}
