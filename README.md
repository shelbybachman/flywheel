
This repository contains R scripts to interact with project data on Flywheel. 

### Dependencies

To use the scripts below, you will need the following installed (details [here](https://flywheel-io.gitlab.io/product/backend/sdk/branches/master/python/python_sdk_with_r.html)):

- R
- Python 3
- Python library `flywheel-sdk`
- R package `reticulate`
 
Make sure your python `Tools` --> `Global Options` (or better yet, `Project Options`, if you are working in an RStudio project and would like project-specific settings) --> `Python` and select the python interpreter of your choice. Then, test that things are working by entering the following command the R console:

`flywheel <- import('flywheel')`

This should run with no errors. If you get an error that the module cannot be found, try a different interpreter. You can also set the interpreter manually using the `use_python(Sys.which('python3'))`, or something similar.

### Scripts

- `get-session-data.R`: creates a dataframe with information about each session in a project ([link](https://github.com/shelbybachman/flywheel/blob/main/scripts/get-session-data.R))
- `get-acquisition-data.R`: creates a dataframe with information about all acquisitions of a given type in a project ([link](https://github.com/shelbybachman/flywheel/blob/main/scripts/get-acquisition-data.R))
- `download-file.R`: downloads a file from a desired session and acquisition ([link](https://github.com/shelbybachman/flywheel/blob/main/scripts/download-file.R))

### Slides

- [Using R with the Flywheel SDK](https://github.com/shelbybachman/flywheel/blob/main/slides/intro-to-sdk.pdf)
