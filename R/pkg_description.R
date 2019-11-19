#' Create package description file
#'
#' @param path Path to description file
#' @param source Will the package be delivered as archive, from github or from another git?
#' @param out.dir Path to save output file
#' @param url url of the repository if not in URL in DESCRIPTION. Used when source is github or git.
#' @inheritParams out_from_lines
#' @importFrom desc description
#' @importFrom utils tail
#'
#' @export
create_pkg_desc_file <- function(path = "DESCRIPTION", source = c("archive", "github", "git"), url,
                                 out.dir,
                                 to = c("html", "markdown", "raw"),
                                 edit = TRUE) {

  source <- match.arg(source, c("archive", "github", "git"), several.ok = FALSE)
  to <- match.arg(to, c("html", "markdown", "raw"), several.ok = FALSE)
  if (missing(out.dir)) {out.dir <- tempdir()}
  out.dir <- normalizePath(out.dir)

  # temp dir
  temp_dir <- tempdir()

  # get description file
  desc <- description$new(path)
  pkg <- desc$get("Package")
  version <- desc$get("Version")

  # get URL
  if (missing(url)) {
    url <- desc$get("URL")
  }

  if (source %in% c("github", "git") & is.na(url)) {
    stop("When source is \"github\" or \"git\", an url must be provided either as URL in the DESCRIPTION file or as `url` in this function.")
  }

  # Installation script
  if (source == "archive") {
    install_pkg <- paste0("remotes::install_local(path = \"", pkg, "_", version, ".tar.gz\")")
  } else if (grepl("github", url)) {
    install_pkg <- paste0("remotes::install_github(repo = \"",
                          gsub(".*github.com/", "", url), "\")")
  } else {
    install_pkg <- paste0("remotes::install_git(url = \"", url, "\")")
  }




  # Script to install dependencies needed
  attachment::create_dependencies_file(path = path,
                                       to = file.path(temp_dir, "deps.R"),
                                       open_file = FALSE)
  # Get dependencies list
  deps <- attachment::att_from_description(path = path)

  content <- paste(
    paste0('# ', pkg),
    "<!-- description: start -->",
    paste0("This is package {", pkg, "}: ", gsub("\\s+|\\\\n", " ", desc$get("Title")), ".  "),
    paste0("Current version is ", version, "."),
    "<!-- description: end -->",
    '',
    '## Installation',
    "<!-- install: start -->",
    paste0('The list of dependencies required to install this package is: ',
           paste(deps, collapse = ", "), '.'),
    '',
    'To install the package, you can run the following script',
    '',
    '```{r, echo=TRUE, eval=FALSE}',
    '# install.packages("remotes")',
    install_pkg,
    '```',
    '',
    'In case something went wrong, you may want to install dependencies before using:',
    '',
    '```{r, echo=TRUE, eval=FALSE}',
    paste(readLines(file.path(temp_dir, "deps.R")), collapse = "\n"),
    '```',
    '',
    "<!-- install: end -->",
    '',
    sep = "\n")

  # write content to Rmd
  readr::write_lines(enc2utf8(content), file.path(temp_dir, "content.Rmd"))

  if (to == "raw") {
    out_lines <- readr::read_lines(file.path(temp_dir, "content.Rmd"))
  } else {
  # render file
  render_external(input = file.path(temp_dir, "content.Rmd"),
                  output_format = "bookdown::html_document2",
                  output_file = file.path(temp_dir, "content.html"))

  # extract html
  html_lines <- readr::read_lines(file.path(temp_dir, "content.html"))

  # get div
  first_div <- grep("<div", html_lines)[1]
  last_div <- tail(grep("</div>", html_lines), 1)
  out_lines <- html_lines[first_div:last_div]

  html_out <- file.path(out.dir, "content_light.html")
  readr::write_lines(enc2utf8(out_lines), html_out)
  }

  out_from_lines(out_lines = out_lines, to = to,
                 out.dir = out.dir, filename = "pkg_description",
                 edit = edit)
}
