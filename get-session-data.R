
# this script gathers basic session data for a project on flywheel
# written by shelby bachman, sbachman@usc.edu
# last updated 2020-12-01

# setup -------------------------------------------------------------------

rm(list = ls())
library(reticulate)
use_python(Sys.which('python3'))
flywheel <- import('flywheel')

# connect to flywheel -----------------------------------------------------

# prompt user for API key
my_key <- readline(prompt = 'Enter flywheel API key: ')
fw <- flywheel$Client(my_key)
rm(my_key)

# find project on flywheel
group_name <- 'your_group_name'
project_name <- 'your_project_name'
project <- fw$lookup(paste(group_name, project_name, sep = '/'))

# list sessions -----------------------------------------------------------

sessions <- project$sessions()
session_ids <- vector(mode = 'character', length = length(sessions))
for (ii in 1:length(sessions)) {
  session_ids[ii] <- sessions[[ii]]$id
}
rm(ii)

label_session <- vector(mode = 'character', length = length(sessions))
label_subject <- vector(mode = 'character', length = length(sessions))
n_acquisitions <- vector(mode = 'numeric', length = length(sessions))

for (ii in 1:length(sessions)) {
  
  # gather session & subject labels for this session
  session <- fw$get(session_ids[ii])
  label_session[ii] <- session$label
  label_subject[ii] <- session$subject$label
  
  # compute number of acquisitions for this session
  acquisitions <- session$acquisitions()
  n_acquisitions[ii] <- length(acquisitions)
  
}

# compile session data ----------------------------------------------------

data_sessions <- data.frame(label_subject, label_session, 
                            id_session = session_ids, n_acquisitions)

