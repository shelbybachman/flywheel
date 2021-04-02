
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
# here, the example is for an mprage acquisition and a BOLD acquisition
label_acquisition <- c('your_acq_label_mprage', 'your_acq_label_bold')

# bids-compliant acquisition names 
# these tell the script how to name downloaded files for each acquisition type
# e.g. sub-X_ses-X_[THIS-PART].nii.gz
# by default, this matches the labels above
# but usually you'll want to specify them here
# for acquisition == mprage, use `acq-T1w`
# for acquisition == functional task, use something like `task-nback_bold`
label_acquisition_bids <- label_acquisition

# bids-compliant classifications
# for each of the above acquisitions, 
# should relevant files get stored in the subdirectories 'anat' or 'bold'?
class_acquisition_bids <- c('anat', 'bold')

# file type to download within each acquisition specified above
# this is either 'dicom' or 'nifti'
file_type <- 'nifti'  # either: dicom, nifti

# binary indicating whether this is a multi-session project 
# (1=yes, 0=no)
multi_session <- 1


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
    if (acquisitions[[jj]]$label %in% label_acquisition) {
      this_acquisition <- acquisitions[[jj]]
      
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
          
          # set bids-compliant modality name
          this_modality_bids <- class_acquisition_bids[idx]
          
          # set file extension based on file type
          if (file_type == 'nifti') {
            file_ext <- '.nii.gz'
          } else if (file_type == 'dicom') {
            file_ext <- '.zip'
          }
          
          # set destination filename
          # if multi-session experiment
          if (multi_session == 1) {
            dest_file <- paste(this_subject_bids, '_',
                               this_session_bids, '_',
                               this_acq_bids,
                               file_ext,
                               sep = '')
            dest_file_full <- file.path(download_path,
                                        this_subject_bids,
                                        this_session_bids,
                                        this_modality_bids,
                                        dest_file)
          } else if (multi_session == 0) {
            dest_file <- paste(this_subject_bids, '_',
                               this_acq_bids,
                               file_ext,
                               sep = '')
            dest_file_full <- file.path(download_path,
                                        this_subject_bids,
                                        this_modality_bids,
                                        dest_file)
          }

          
          # if files are to be stored in bids-compliant directories
          if (format_bids %in% c(1,2)) {
            
            # if a multi-session experiment:
            # create subject, session & modality subdirectories if they don't exist
            if (multi_session == 1) {
              if (!dir.exists(file.path(download_path, this_subject_bids))) {
                dir.create(file.path(download_path, this_subject_bids))
              }
              if (!dir.exists(file.path(download_path, this_subject_bids, this_session_bids))) {
                dir.create(file.path(download_path, this_subject_bids, this_session_bids))
              }
              if (!dir.exists(file.path(download_path, this_subject_bids, this_session_bids, this_modality_bids))) {
                dir.create(file.path(download_path, this_subject_bids, this_session_bids, this_modality_bids))
              }
              
              # if single-session experiment-session experiment:
              # create subject & modality subdirectories if they don't exist
            } else if (multi_session == 0) {
              if (!dir.exists(file.path(download_path, this_subject_bids))) {
                dir.create(file.path(download_path, this_subject_bids))
              }
              if (!dir.exists(file.path(download_path, this_subject_bids, this_modality_bids))) {
                dir.create(file.path(download_path, this_subject_bids, this_modality_bids))
              }
            }

          }
          
          # download the file
          files[[hh]]$download(dest_file = dest_file_full)
          message(paste('downloaded file: ', dest_file_full, sep = ''))
        }
      }
      
    }
  }
  
  
}