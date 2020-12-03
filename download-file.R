
# this script downloads a file from flywheel
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

# provide file information ------------------------------------------------

label_subject <- 'your_subject_label'
label_session <- 'your_session_label'
label_acquisition <- 'your_acq_label'
file_type <- 'your_file_type'  # examples: dicom, nifti
download_path <- 'download_location'  # path to where you want the file downloaded, with no trailing filesep

# loop over sessions, find & download file of interest --------------------

sessions <- project$sessions()

for (ii in 1:length(sessions)) {
  this_session <- fw$get(sessions[[ii]]$id)
  if (this_session$subject$label == label_subject) {
    if (this_session$label == label_session) {
      break
    }
  }
}
rm(ii)

acquisitions <- this_session$acquisitions()

for (ii in 1:length(acquisitions)) {
  if (acquisitions[[ii]]$label == label_acquisition) {
    this_acquisition <- acquisitions[[ii]]
    break
  }
}
rm(ii)

files <- this_acquisition$files

for (ii in 1:length(files)) {
  if (files[[ii]]$type == file_type) {
    files[[ii]]$download(dest_file = paste(download_path, files[[ii]]$name, sep = '/'))
    message(paste('downloaded file: ', download_path, '/', files[[ii]]$name, sep = ''))
    break
  }
}
