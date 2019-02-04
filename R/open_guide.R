#' Open UserGuide of the package
#'
#' @param ext extension of the book to open: 'html', 'pdf'
#'
#' @importFrom utils browseURL
#'
#' @export
open_guide <- function(ext = "html") {
    if (ext == "html") {
    guide_path <- system.file('report/_book/index.html', package = 'visualidentity')
    } else if (ext == "pdf") {
    guide_path <- system.file('report/_book/report.pdf', package = 'visualidentity')
    } else {
    guide_path <- system.file(paste0("report/_book/report.", ext[1]), package = 'visualidentity')
    }

  browseURL(paste0('file://', guide_path))
}
