createImage <- function(id=rcloud.support::rcloud.session.notebook.id()) {
    ns <- loadedNamespaces()
    ns <- ns[!grepl("^rcloud.*", ns)] ## remove rcloud-related packages (FIXME)
    dockerize(id, ns)
}

dockerize <- function(ids, pkgs, files) {
    wd <- getwd()
    dir.create("out")
    on.exit(setwd(wd))
    setwd("out")
    if (missing(files)) files <- c()

    ## STEP 1: get notebooks and create repos for gitgist

    repo.root <- file.path(getwd(),"data/rcloud/data/gists")
    if (!file.exists(repo.root)) dir.create(repo.root, recursive=TRUE, mode="0766")

    ctx <- gitgist:::create.gist.context("rcloud", repo.root)
    for (p in ids) { ## create notebook repos
	i1 <- gsub("^(..).*","\\1",p)
	i2 <- gsub("^..(..).*","\\1",p)
	i3 <- substr(gsub("^....","",p), 1, 16) ## NOTE: gitgist truncates at 20 characters for historic reasons
	nb <- rcloud.get.notebook(p) ## get the latest version of the notebook from RCloud

	## create.gist() doesn't allow us to specify ID so we have to create a bare repo manually fist
	dir <- paste0("data/rcloud/data/gists/", i1, "/", i2, "/", i3)
	if (!file.exists(dir)) dir.create(dir, recursive=TRUE, mode="0766")
	guitar::repository_init(dir, TRUE)
	gitgist::modify.gist.gitgistcontext(p, list(files=nb$content$files), ctx)
    }
    fns <- gsub("^/", "", files[grep("^/", files)])
    if (length(fns) < length(files)) stop("`files' must all be absolute paths")

    ## STEP 2: any files to copy over (data etc.)
    if (length(fns)) for (fn in fns) {
        dir <- dirname(fn)
	if (!file.exists(dir)) dir.create(dir, recursive=TRUE, mode="0766")
	system(paste("cp", shQuote(paste0("/", fn)), shQuote(fn)))
    }

    ## STEP 3: packages
    ##
    ## FIXME: not doing recursive yet ...
    ## list from the rcloud-aas base image
    installed <- c("askpass", "base64enc", "BH", "bitops", "brew", "Cairo", "curl",
"digest", "evaluate", "FastRWeb", "gist", "gitgist", "github",
"githubgist", "glue", "guitar", "highr", "htmltools", "httr",
"jsonlite", "knitr", "magrittr", "markdown", "mime", "openssl",
"PKI", "png", "R6", "rcloud.client", "rcloud.enviewer", "rcloud.jupyter",
"rcloud.lux", "rcloud.notebook.info", "rcloud.python", "rcloud.r",
"rcloud.rmarkdown", "rcloud.sh", "rcloud.solr", "rcloud.support",
"rcloud.viewer", "rcloud.web", "Rcpp", "RCurl", "rediscc", "reticulate",
"rjson", "rmarkdown", "Rook", "RSclient", "Rserve", "sendmailR",
"stringi", "stringr", "sys", "tinytex", "ulog", "unixtools",
"uuid", "xfun", "yaml", "base", "boot", "class", "cluster", "codetools",
"compiler", "datasets", "foreign", "graphics", "grDevices", "grid",
"KernSmooth", "lattice", "MASS", "Matrix", "methods", "mgcv",
"nlme", "nnet", "parallel", "rpart", "spatial", "splines", "stats",
"stats4", "survival", "tcltk", "tools", "utils",
## FIXME: flexdashboard is an extension that we have loaded,
## but it's not in the image - so for now assume it's not needed
"flexdashboard", "htmlwidgets"
)

    pkgs <- pkgs[! pkgs %in% installed]
    dir <- "data/packages/src/contrib"
    if (!file.exists(dir)) dir.create(dir, recursive=TRUE, mode="0766")

    if (length(pkgs)) download.packages(pkgs, dir, type='source', repos=c("http://rforge.net", "https://cloud.r-project.org"))
    tools:::write_PACKAGES(dir)

    ## Tar it all up and dockerize ...
    system("chmod -R a+rX . && tar fvcz ../rcservice.tar.gz *")

    setwd(wd)

    writeLines(readLines(system.file("docker","Dockerfile", package="rcloud.dockerize")),
		"Dockerfile")

    system("chmod a+r rcservice.tar.gz && docker build .")
}
