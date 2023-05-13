#get data
options(warn=-1)  
library(data.table)
options(warn=0)

if(!library(reshape2, logical.return = TRUE)) {
  # It didn't exist, so install the package, and then load it
  install.packages('reshape2')
  library(reshape2)
}

targetFolder <- 'UCI HAR Dataset'
filename <- 'getdata_dataset.zip'

if(!file.exists(targetFolder)) {
  if(!file.exists(filename)) {
    
    download.file(
      'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',
      filename
    )
  }
  
  unzip(filename)
}

targetFolder_Test <- '~/UCI HAR Dataset/'
targetFolder_Train <- '~/UCI HAR Dataset/'
targetFolder <- '~/UCI HAR Dataset'

# 1. Merges the training and the test sets to create one data set.

# Read in the data into the test and training sets
test.data <- read.table(file.path(targetFolder_Test, 'Test', 'X_test.txt'))
test.activities <- read.table(file.path(targetFolder_Test, 'Test', 'y_test.txt'))
test.subjects <- read.table(file.path(targetFolder_Test, 'Test', 'subject_test.txt'))

train.data <- read.table(file.path(targetFolder_Train, 'Train', 'X_train.txt'))
train.activities <- read.table(file.path(targetFolder_Train, 'Train', 'y_train.txt'))
train.subjects <- read.table(file.path(targetFolder_Train, 'Train', 'subject_train.txt'))


# Bind the rows for each of the data sets together
data.data <- rbind(train.data, test.data)
data.activities <- rbind(train.activities, test.activities)
data.subjects <- rbind(train.subjects, test.subjects)

# one table
data_comp <- cbind(data.subjects, data.activities, data.data)

# get features
features <- read.table(file.path(targetFolder, 'features.txt'))
requiredFeatures <- features[grep('-(mean|std)\\(\\)', features[, 2 ]), 1]

#filter dataset
data_comp1 <- data_comp[requiredFeatures, ]

#get labels
ac_label <- read.table(file.path(targetFolder, 'activity_labels.txt'))

# Update the activity name
data_comp1[, 2] <- ac_label[data_comp1[,2], 2]

colnames(data_comp1) <- c('subject', 'activity',
  gsub('\\-|\\(|\\)', '', as.character(requiredFeatures)))
  
data_comp1[, 2] <- as.character(data_comp1[, 2])

#final structure
final.dataset <- melt(data_comp1, id = c('subject', 'activity'))
final.dataset_mean <- reshape2::dcast(final.dataset, subject + activity ~ variable, mean)

#write file
write.table(final.dataset_mean, file=file.path("tidy.txt"), 
            row.names = FALSE, quote = FALSE )
