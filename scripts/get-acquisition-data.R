
# this script gathers basic acquisition data for a project on flywheel
# written by shelby bachman, sbachman@usc.edu
# last updated 2020-12-02

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

# set acquisition label ---------------------------------------------------

# note: the script below assumes two things:
# (1) you have only one acquisition with this label per session
# (2) you have the same acquisition label across sessions
# you should check your data to ensure these assumptions hold
acq_label <- 'your_acq_label'

# list sessions -----------------------------------------------------------

sessions <- project$sessions()
session_ids <- vector(mode = 'character', length = length(sessions))
for (ii in 1:length(sessions)) {
  session_ids[ii] <- sessions[[ii]]$id
}
rm(ii)

label_session <- vector(mode = 'character', length = length(sessions))
label_subject <- vector(mode = 'character', length = length(sessions))
label_acq <- vector(mode = 'character', length = length(sessions))
id_acq <- vector(mode = 'character', length = length(sessions))

for (ii in 1:length(sessions)) {
  
  # extract session & subject label for this session
  session <- fw$get(session_ids[ii])
  label_session[ii] <- session$label
  label_subject[ii] <- session$subject$label
  
  # get list & acquisitions for this session and loop over
  acquisitions <- session$acquisitions()
  for (hh in 1:length(acquisitions)) {
    if (acquisitions[[hh]]$label == acq_label) {
      label_acq[ii] <- acquisitions[[hh]]$label
      id_acq[ii] <- acquisitions[[hh]]$id
    }
  }
}

# compile acq data ----------------------------------------------------

data_acquisitions <- data.frame(label_subject, label_session, 
                                id_session = session_ids, 
                                label_acq, id_acq)

