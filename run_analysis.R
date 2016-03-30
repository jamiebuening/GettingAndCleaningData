#############################################################################
#
# This is an R script which will perform the activities specified in the
# Getting and Cleaning Data Week 4 Project assignment.  This script:
#
# 1) Merges the training and the test sets to create one data set.
#
# 2) Extracts only the measurements on the mean and standard deviation for
#    each measurement.
#
# 3) Uses descriptive activity names to name the activities in the data set.
#
# 4) Appropriately labels the data set with descriptive variable names.
#
# 5) From the data set in step 4, creates a second, independent tidy data set
#    with the average of each variable for each activity and each subject.
#
#############################################################################

# Load the needed libary for this script.
library(plyr)
library(dplyr)
library(data.table)

# Set the correct working directory.
setwd("C:/Users/m01188/datasciencecoursera/Getting and Cleaning Data/Week 4/Project")

# Read in the data files so the data can be used.
x_train <- fread("UCI HAR Dataset/train/X_train.txt")
y_train <- fread("UCI HAR Dataset/train/y_train.txt")
subject_train <- fread("UCI HAR Dataset/train/subject_train.txt")

x_test <- fread("UCI HAR Dataset/test/X_test.txt")
y_test <- fread("UCI HAR Dataset/test/y_test.txt")
subject_test <- fread("UCI HAR Dataset/test/subject_test.txt")

# Combine matching train and test data sets.
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

# Read in features information so we have the full list of variable names.
features <- fread("UCI HAR Dataset/features.txt")

# Set names for columns in features.
names(features) <- c("feature_id","feature_name")

# Create a new column/variable to allow matching against x_data.
features$feature_code <- features[,paste("V",feature_id,sep="")]

# Create a subset of features containing mean or std
features <- features[grepl("mean\\(\\)|std\\(\\)",feature_name)]

# Subset the data against features to included only the columns we are interested in.
x_data <- x_data[,features$feature_code,with=FALSE]

# Rename the columns to be descriptive
names(x_data) <- features$feature_name

# Read in the names of the activities so we can use them for descriptive labels.
activities <- fread("UCI HAR Dataset/activity_labels.txt")

# Rename the columns in activities and y_data to be descriptive and so that
# they can be merged together.
names(activities) <- c("activity_id","activity_name")
names(y_data) <- c("activity_id")

# Combine activities with y_data so descriptive names are used.
y_data <- merge(y_data,activities,by="activity_id",all.x=TRUE,sort=FALSE)

# Set a descriptive column name for subject_data.
names(subject_data) <- "subject_id"

# Combine all of the data into a single data set.
all_data <- cbind(subject_data,y_data, x_data)

# Remove the column activity_id since it is no longer needed now that it
# has been replaced by activity_name
all_data <- all_data[,!"activity_id",with=FALSE]

# Create a new data frame with averages by activity and subject
sub_act_avgs <- ddply(all_data, c("subject_id","activity_name"), numcolwise(mean))

# Save final data out to file
write.table(sub_act_avgs, file="sub_act_avgs.txt", row.name=FALSE)
