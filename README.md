
This repository contains R scripts to interact with project data on Flywheel. 

### Dependencies

To use these scripts, you will need the following installed (details [here](https://flywheel-io.gitlab.io/product/backend/sdk/branches/master/python/python_sdk_with_r.html)):

- Python 3
- Python library `flywheel-sdk`
- R package `reticulate`

### Scripts

- `get-session-data.R`: creates a dataframe with information about each session in a project ([link](https://github.com/shelbybachman/flywheel/blob/main/scripts/get-session-data.R))
- `get-acquisition-data.R`: creates a dataframe with information about all acquisitions of a given type in a project ([link](https://github.com/shelbybachman/flywheel/blob/main/scripts/get-acquisition-data.R))
- `download-file.R`: downloads a file from a desired session and acquisition ([link](https://github.com/shelbybachman/flywheel/blob/main/scripts/download-file.R))

### Slides

- [Using R with the Flywheel SDK](https://github.com/shelbybachman/flywheel/blob/main/slides/intro-to-sdk.pdf)
