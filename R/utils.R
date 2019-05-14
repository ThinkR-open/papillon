#' Render Rmd in a script external to the current session
#'
#' @param warn sets the handling of warning messages. -1 or 0
#' @inheritParams rmarkdown::render
#'
#' @export
render_external <- function(input, output_format = "rmarkdown::html_document",
                            output_file, output_options,
                            warn = -1) {

  runR <- tempfile(fileext = "run.R")
  input <- normalizePath(input)
  if (!missing(output_file)) {
    output_file <- normalizePath(output_file, mustWork = FALSE)
  }
  if (missing(output_options)) {
    output_options <- list(number_sections = FALSE, self_contained = FALSE)
  }
  output_options <- deparse(output_options)

  cat(
    paste0('options(warn=', warn,
           ');invisible(rmarkdown::render("', gsub("\\", "\\\\", input, fixed = TRUE), '"',
           ', output_format = "', output_format, '"',
           ', output_options = ', output_options,
           ifelse(missing(output_file), '',
                  paste0(', output_file = "', gsub("\\", "\\\\", output_file, fixed = TRUE), '"')),
           # ', encoding = "', encoding, '"',
           ', quiet = TRUE))') #documentation = 0,
    , file = runR)

  # Purl in a new environment to avoid knit inside knit if function is inside Rmd file
  system(
    paste(normalizePath(file.path(Sys.getenv("R_HOME"), "bin", "Rscript"), mustWork = FALSE), runR)
  )
}

#' write output in utf8
#' @param out_lines vector of html lines to write
#' @param to Format to convert to. "html" or "markdown"
#' @param out.dir Directory where to save output md file
#' @param filename filename without extentions
#' @param edit Logical. Whether to open file for edition
out_from_lines <- function(out_lines, to = c("html", "markdown"), out.dir, filename = "file",
                           edit = TRUE) {
  to <- match.arg(to, c("html", "markdown"), several.ok = FALSE)

  if (missing(out.dir)) {out.dir <- tempdir()}
  out.dir <- normalizePath(out.dir)

  if (to == "html") {
    html_out <- file.path(out.dir, paste0(filename, ".html"))
    readr::write_lines(enc2utf8(out_lines), html_out)
    message(crayon::green("File "), html_out, crayon::green(" created"))
    if (isTRUE(edit)) {
      usethis::edit_file(html_out)
      message(crayon::green("You can now edit "), html_out)
    }
  }

  if (to == "markdown") {
    html_tmp <- tempfile(fileext = ".html")
    readr::write_lines(enc2utf8(out_lines), html_tmp)

    md_out <- file.path(out.dir, paste0(filename, ".md"))
    rmarkdown::pandoc_convert(html_tmp, to = "markdown", output = md_out)

    message(crayon::green("File "), md_out, crayon::green(" created"))
    if (isTRUE(edit)) {
      usethis::edit_file(md_out)
      message(crayon::green("You can now edit "), md_out)
    }
  }
}
