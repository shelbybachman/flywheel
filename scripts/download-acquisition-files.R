
# this script downloads all files for a particular acquisition
# within a project
# written by shelby bachman, sbachman@usc.edu
# last updated 2021-04-02

# setup -------------------------------------------------------------------

library(reticulate)
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


# file information --------------------------------------------------------

# label(s) for acquisition(s) of all files you would like to download
# this is a vector of minimum length 1
# (NOTE: this needs to be the same across files)
label_acquisition <- c('your_acq_label1', 'your_acq_label2')

# bids-compliant acquisition names 
# these tell the script how to name downloaded files for each acquisition type
# e.g. sub-X_ses-X_[THIS-PART].nii.gz
# by default, this matches the labels above
# but usually you'll want to specify them here
# for acquisition == mprage, use `acq-T1w`
# for acquisition == functional task, use something like `task-nback_bold`
label_acquisition_bids <- label_acquisition

# file type to download within each acquisition specified above
# this is either 'dicom' or 'nifti'
file_type <- 'nifti'  # either: dicom, nifti


# exclusion information ---------------------------------------------------

# vector of subjects you want to exclude from download
subjects_to_exclude <- c()


# download information ----------------------------------------------------

# path to where you want the file downloaded, with no trailing filesep
download_path <- 'download_location'  

# binary indicating whether you want the files downloaded into bids-formatted subdirectories
# (2=yes & subdirectories do not exist yet, 
# 1=yes & subdirectories exist already,
# 0=no; just download all the files into the dir specified above)
# (NOTE: if you specified 2, this script is going to automatically detect subjects & sessions)
format_bids <- 2

# vector containing labels of sessions on flywheel
# (NOTE: add this only if you have >= 2 sessions per subject,
# leave this empty if you only have one session per subject)
label_sessions <- c()

# loop over sessions, find & download files of interest -------------------

# retrieve sessions in this project
sessions <- project$sessions()

# loop over sessions
for (ii in 1:length(sessions)) {
  this_session <- fw$get(sessions[[ii]]$id)
  
  # move on if this is a subject to exclude
  if (this_session$subject$label %in% subjects_to_exclude) {
    next
  }
  
  # retrieve acquisitions for this session
  acquisitions <- this_session$acquisitions()
  
  # loop over acquisitions
  for (jj in 1:length(acquisitions)) {
    
    # if a relevant acquisition
    if (acquisitions[[ii]]$label %in% label_acquisition) {
      this_acquisition <- acquisitions[[ii]]
      
      # retrieve files for this acquisition
      files <- this_acquisition$files
      
      # loop over files
      for (hh in 1:length(files)) {
        
        # if a relevant file
        if (files[[hh]]$type %in% file_type) {
          
          # create the subject (and as needed, session) subdirectory
          # if format_bids is 1 or 2,
          # and rename the file in bids naming convention
          
          # set bids-compliant subject, session names
          this_subject_bids <- paste('sub-', this_session$subject$label, sep = '')
          this_session_bids <- paste('ses-', this_session$label, sep = '')
          
          # set bids-compliant acqusition name
          idx <- which(label_acquisition == this_acquisition$label)
          this_acq_bids <- label_acquisition_bids[idx]
      
          # set file extension based on file type
          if (file_type == 'nifti') {
            file_ext <- '.nii.gz'
          } else if (file_type == 'dicom') {
            file_ext <- '.zip'
          }
          
          # set destination filename
          dest_file <- paste(this_subject_bids, 
                                  this_session_bids,
                                  this_acq_bids, 
                                  file_ext,
                                  sep = '_')
          dest_file_full <- file.path(download_path,
                            this_subject_bids,
                            this_session_bids,
                            dest_file)
          
          # create subject & session subdirectories if they don't exist
          if (dir.exists(file.path(download_path, this_subject_bids))) {
            dir.create(file.path(download_path, this_subject_bids))
          }
          if (dir.exists(file.path(download_path, this_subject_bids, this_session_bids))) {
            dir.create(file.path(download_path, this_subject_bids, this_session_bids))
          }
          
          # download the file
          files[[ii]]$download(dest_file = dest_file_full)
          message(paste('downloaded file: ', download_path, '/', files[[hh]]$name, sep = ''))
        }
      }
      
    }
  }
  
  
}