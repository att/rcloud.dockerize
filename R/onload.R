
caps <- NULL

.onLoad <- function(libname, pkgname) {

  ## Not in RCloud? Return silently
  if (! requireNamespace("rcloud.support", quietly = TRUE)) return()

  path <- system.file(
    package = "rcloud.dockerize",
    "javascript",
    "rcloud.dockerize.js"
  )

  caps <<- rcloud.support::rcloud.install.js.module(
    "rcloud.dockerize",
    paste(readLines(path), collapse = '\n')
  )

  ocaps <- list(
    createImage = make_oc(createImage)
  )

  if (!is.null(caps)) caps$init(ocaps)
}

make_oc <- function(x) {
  do.call(base::`:::`, list("rcloud.support", "make.oc"))(x)
}
