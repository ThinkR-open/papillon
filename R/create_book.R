#' Create a directory for a book
#'
#' @param path Book directory
#' @param clean Logical. Whether to remove Chapter Rmd files.
#' @param template A folder with personal template files for a bookdown site
#'
#' @importFrom usethis edit_file
#'
#' @export
#'
#' @examples
#' \dontrun{
#' book_folder <- tempdir()
#' create_book(path = book_folder, clean = TRUE)
#' }
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
  edit_file("index.Rmd")
}

#' Build book from vignettes
#'
#' @param path Path of the book
#' @param path.v Path to vignettes folder to copy in the book folder
#' @param output_format Output format of the book. "bookdown::gitbook", "bookdown::pdf_document2"
#' @param clean_before Logical. Whether to remove all Rmd (except keep_rmd) before build
#' @param clean_after Logical. Whether to remove all Rmd (except keep_rmd) after build
#' @param keep_rmd Regex to list Rmd filenames to keep if clean_before or clean_after is TRUE. You'd better keep index.Rmd.
#'
#' @inheritParams bookdown::clean_book
#' @importFrom bookdown clean_book render_book
#'
#' @export

build_book <- function(path = "inst/report", path.v = "vignettes",
                       output_format = c("bookdown::gitbook", "bookdown::pdf_document2"),
                       clean_before = TRUE, clean_after = TRUE,
                       keep_rmd = "index\\.Rmd$|zzz-references\\.Rmd$",
                       clean = TRUE) {

  # Clean Rmd files before
  to_clean_before <- list.files(normalizePath(path), full.names = TRUE, pattern = ".Rmd$")
  to_clean_before <- to_clean_before[!grepl(keep_rmd, basename(to_clean_before))]

  if (isTRUE(clean_before) && length(to_clean_before) > 0) {
    file.remove(to_clean_before)
  }

  # Copy vignettes
  file.copy(list.files(normalizePath(path.v), full.names = TRUE),
            normalizePath(path),
            overwrite = TRUE)

  # Keep Rmd for clean after
  to_clean_after <- list.files(normalizePath(path), full.names = TRUE, pattern = ".Rmd$")
  to_clean_after <- to_clean_after[!grepl(keep_rmd, basename(to_clean_after))]


  oldwd <- setwd(normalizePath(path))
  on.exit(setwd(oldwd), add = TRUE)

  # Build books
  bookdown::clean_book(clean)
  lapply(output_format, function(x) bookdown::render_book("", x))

  # Clean Rmd after
  if (isTRUE(clean_after) && length(to_clean_after) > 0) {
    file.remove(to_clean_after)
  }
}

#' Create a function inside R folder in your package to open userguide
#'
#' @param path Path to the guide inside your package
#'
#' @export
open_guide_function <- function(path = "inst/report") {

  pkg_name <- read.dcf("DESCRIPTION")[1,"Package"]
  report_path <- strsplit(path, "inst/")[[1]][2]
  fun_template <- system.file("templates/open_userguide_template.R", package = "papillon")

  cat(paste(readLines(fun_template), collapse = "\n"),
      "\n",
    "open_guide <- function(ext = \"html\") {
    if (ext == \"html\") {
    guide_path <- system.file('", file.path(report_path, "_book", "index.html"), "', package = '", pkg_name, "')
    } else if (ext == \"pdf\") {
    guide_path <- system.file('", file.path(report_path, "_book", paste0(basename(report_path), ".pdf")), "', package = '", pkg_name, "')
    } else {
    guide_path <- system.file(paste0(\"", file.path(report_path, "_book", paste0(basename(report_path))), ".\", ext[1]), package = '", pkg_name, "')
    }

  browseURL(paste0('file://', guide_path))
}
", sep = "", file = "R/open_guide.R")

  message(paste0("You can add in your package documentation to open guide using: ",
                pkg_name, "::open_guide()"))
  message("Run 'devtools::document()'")
}
