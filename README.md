
This repository contains R scripts to interact with project data on Flywheel. 

### Dependencies

To use these scripts, you will need the following installed (details [here](https://flywheel-io.gitlab.io/product/backend/sdk/branches/master/python/python_sdk_with_r.html)):

- Python 3
- Python library `flywheel-sdk`
- R package `reticulate`

### Scripts

- `get-session-data.R`: creates a dataframe with information about each session in a project
- `get-acquisition-data.R`: creates a dataframe with information about all acquisitions of a given type in a project
