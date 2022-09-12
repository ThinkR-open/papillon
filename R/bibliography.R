#' Create bibliography md file from a package DESCRIPTION file
#'
#' @param path Path to DESCRIPTION file
#' @inheritParams create_biblio_file
#'
#' @export

create_pkg_biblio_file <- function(path = "DESCRIPTION",
                                   out.dir,
                                   output = c("packages", "references"),
                                   to = c("html", "markdown"),
                                   custom.md,
                                   edit = TRUE) {
  if (missing(out.dir)) {out.dir <- tempdir()}
  if (missing(custom.md)) {custom.md <- ""}
  pkg_dependencies <- attachment::att_from_description(path)

  create_biblio_file(packages = pkg_dependencies, out.dir = out.dir,
                     output = output, to = to, custom.md = custom.md,
                     edit = edit)
}

#' Create bibliography md file from a vector of packages
#'
#' @param packages vector of packages names
#' @param output Vector with "packages" (list of packages as bullet points),
#' "references" (list of citation references) or both "packages" and "references"
#' @param custom.md Vector of markdown text to add to the document before rendering
#' @param edit Logical. Whether to open output md file for manual edition
#' @inheritParams out_from_lines
#'
#' @export
#'
#' @examples
#' packages <- c("rmarkdown", "attachment")
#' create_biblio_file(packages, out.dir = tempdir())

create_biblio_file <- function(packages, out.dir,
                               output = c("packages", "references"),
                               to = c("html", "markdown"),
                               custom.md,
                               edit = TRUE) {

  output <- match.arg(output, c("packages", "references"), several.ok = TRUE)
  to <- match.arg(to, c("html", "markdown"), several.ok = FALSE)
  if (missing(out.dir)) {out.dir <- tempdir()}
  out.dir <- normalizePath(out.dir)
  if (missing(custom.md)) {custom.md <- ""}

  # Read template
  bib <- system.file("templates/bibliography.Rmd", package = "papillon")
  bib_lines <- readr::read_lines(bib)

  # temporary output
  dir_temp <- tempdir()
  file_temp <- tempfile()

  # custom md
  bib_lines[grep("CUSTOM_HERE", bib_lines)] <- paste(custom.md, collapse = "\n")

  # list packages
  bib_lines[grep("PACKAGES_HERE", bib_lines)] <- gsub(
    pattern = "PACKAGES_HERE",
    replacement = paste0("c(", paste(paste0('"', packages, '"'), collapse = ", "), ")"),
    x = bib_lines[grep("PACKAGES_HERE", bib_lines)])

  # path to bib
  bib_lines[grep("BIBPATH_HERE", bib_lines)] <- gsub(
    pattern = "BIBPATH_HERE",
    replacement = paste0('"', dir_temp, '"'),
    x = bib_lines[grep("BIBPATH_HERE", bib_lines)])

  # Link citation
  if (!"references" %in% output) {
    bib_lines[grep("link-citations", bib_lines)] <- "link-citations: no"
  }

  # escape \
  # bib_lines <- gsub("\\", "\\\\", bib_lines, fixed = TRUE)

  # write modified Rmd
  readr::write_lines(enc2utf8(bib_lines), paste0(file_temp, ".Rmd"))

  # render file in an external script
  render_external(input = paste0(file_temp, ".Rmd"),
                  output_format = "bookdown::html_document2",
                  output_file = paste0(file_temp, ".html"))

  # extract html
  html_lines <- readr::read_lines(paste0(file_temp, ".html"))

  # _custom_md
  custom_start <- grep("<!-- begin custom_md -->", html_lines)
  custom_end <- grep("<!-- end custom_md -->", html_lines)

  # _packages
  dep_start <- grep("<!-- begin list_of_dependencies -->", html_lines)
  dep_end <- grep("<!-- end list_of_dependencies -->", html_lines)

  # _references
  end_divs <- grep("</div>", html_lines)
  allref_start <- grep("<div id=\"ref", html_lines)
  ref_start <- allref_start[1] #grep("<!-- begin references -->", html_lines)
  ref_end <- end_divs[which(end_divs > ref_start)[length(allref_start)]]
  # ref_end <- grep("<!--end references -->", html_lines)

  # Build page
  out_lines <- html_lines[custom_start:custom_end]
  if ("packages" %in% output) {
    out_lines <- c(out_lines, "<!-- packages -->", html_lines[dep_start:dep_end], "")
  }
  if ("references" %in% output) {
    out_lines <- c(out_lines, "<!-- references -->", html_lines[ref_start:ref_end], "")
  }

  out_from_lines(out_lines = out_lines, to = to,
                 out.dir = out.dir, filename = "bibliography",
                 edit = edit)
}

