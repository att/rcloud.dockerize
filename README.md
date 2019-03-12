
## Install

1. Install this package on RCloud, using `devtools::install_github()`,
   or `install-github.me`:
   ```R
   source("https://install-github.me/att/rcloud.dockerize")
   ```
2. In the RCloud *Settings* menu, in the *Enable Extensions* line, add
   `rcloud.dockerize`, so that the package is loaded automatically.
3. Reload RCloud in the browser. This loads the package, and you should
   see a "rocket" icon in the top bar that dockerizes the current
   notebook.

## Usage

Run the notebook you want to dockerize such that all needed packages
are loaded. Then click on the "rocket" button on top which will
create a gitgist-compatible directory with the notebook, download
sources for R packages that are not in the base image and create a
Docker image based on
(rcloud-aas)[https://github.com/s-u/docker-rcloud-aas]
with the notebook pre-loaded.

### Advanced usage

The underlying code supports dockerization of multiple notebooks as
well as auxiliary files. See
```
rcloud.dockerize:::dockerize(ids, pkgs, files)
```
where all arguments are character vectors, `ids` is a vector of
notebook IDs, `pkgs` is a vector of packages and `files` is a vector
of absolute paths to files to include in the image. Please note that
the paths must be accessible by the `rcloud` user, so it is customary
to start with `/data` as that is where RCloud is installed.

### Known issues

Once the Docker container is started, RCloud services are active and
running and the notebook is available. However, there is no RCS
bootstrapping, so the notebooks have no names. Also they are not
automatically published, so until we add that feature, it is advidable
to use `http://127.0.0.1:8080/login.R` to retrieve cookies and then go
to the notebook URL. At that point it's also possible to publish
notebooks from the UI.

