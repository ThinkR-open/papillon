#' Create a directory for a book
#'
#' @param path Book directory
#' @param clean Logical. Whether to remove Chapter Rmd files.
#' @param template A folder with personal template files for a bookdown site
#'
#' @export
#'
#' @example
#' book_folder <- tempdir()
#' create_book(path = book_folder, clean = TRUE)
#'
create_book <- function(path = "inst/report", clean = FALSE,
                        template) {

  path <- normalizePath(path)
  if (!dir.exists(path)) {dir.create(path, recursive = TRUE)}

  if (missing(template)) {
    template <- system.file("rstudio/templates/project/resources", package = "bookdown")
  }

  oldwd <- setwd(path)
  on.exit(setwd(oldwd), add = TRUE)
  file.copy(list.files(template, full.names = TRUE),
            path, overwrite = FALSE)

  if (isTRUE(clean)) {
    suppressMessages(file.remove(list.files(pattern = "^0[[:digit:]]-.*\\.Rmd$")))
  }
  message("Book created in ", path)
  file.edit("index.Rmd")
}

#' Build book from vignettes
#'
#' @param path Path of the book
#' @param path.v Path to vignettes folder to copy in the book folder
#' @param output_format Output format of the book. "bookdown::gitbook", "bookdown::pdf_book"
#'
#' @importFrom bookdown clean_book render_book
#'
#' @export

build_book <- function(path = "inst/report", path.v = "vignettes",
                       output_format = c("bookdown::gitbook", "bookdown::pdf_book")) {

  file.copy(list.files(normalizePath(path.v), full.names = TRUE),
            normalizePath(path),
            overwrite = TRUE)

  oldwd <- setwd(normalizePath(path))
  on.exit(setwd(oldwd), add = TRUE)
  # bookdown::bookdown_site(input = "index.Rmd")
  bookdown::clean_book(TRUE)
  lapply(output_format, function(x) bookdown::render_book("", x))
  # bookdown::render_book("", "bookdown::gitbook")
  # bookdown::render_book("", output_format = "bookdown::pdf_book")
  # setwd(here::here())
}

#' Create a function inside R folder in your package to open userguide
#'
#' @param path Path to the guide inside your package
#'
#' @export
open_guide_function <- function(path = "inst/report") {

  pkg_name <- read.dcf("DESCRIPTION")[1,"Package"]
  report_path <- strsplit(path, "inst/")[[1]][2]

  cat(
    "#' Open UserGuide of the package
    #'
    #' @param ext extension of the book to open: 'html', 'pdf'
    #'
    #' @export
    open_guide <- function(ext = 'html') {
    if (ext == 'html') {
    guide_path <- system.file('", file.path(report_path, "_book", "index.html"), "', package = '", pkg_name, "')
    } else if (ext = 'pdf') {
    guide_path <- system.file('", file.path(report_path, "_book", paste0(basename(report_path), ".pdf")), "', package = '", pkg_name, "')
    } else {
    guide_path <- system.file(paste0(\"", file.path(report_path, "_book", paste0(basename(report_path))), ".\", ext[1]), package = '", pkg_name, "')
  }

  browseURL(paste0('file://', guide_path))
}", sep = "", file = "R/open_guide.R")
}
