rm(list=ls())
setwd("~/Dropbox/Data_Science/Coursera Course/UCI HAR Dataset")
library(data.table)
library(tidyverse)

# Load the variable names for data file (features)
features <- fread("features.txt")

# Load the train data
trainID <- fread("./train/subject_train.txt")
trainActivities <- fread("./train/y_train.txt")
trainData <- fread("./train/X_train.txt")

# 4. Appropriately labels the data set with descriptive variable names.
trainID <- rename(trainID, id = V1)
trainActivities <- rename(trainActivities, activity = V1)
names(trainData) <- features$V2

# Combine train data
trainData <- bind_cols(trainID, trainActivities, trainData)
trainData[1:5, 1:5]

# Reclass
trainData$id <- as.factor(trainData$id)
trainData$activity <- as.factor(trainData$activity)

# Load the test data
testID <- fread("./test/subject_test.txt")
testActivities <- fread("./test/y_test.txt")
testData <- fread("./test/X_test.txt")

# 4. Appropriately labels the data set with descriptive variable names.
testID <- rename(testID, id = V1)
testActivities <- rename(testActivities, activity = V1)
names(testData) <- features$V2

# Combine test data
testData <- bind_cols(testID, testActivities, testData)
testData[1:5, 1:5]

# Reclass
testData$id <- as.factor(testData$id)
testData$activity <- as.factor(testData$activity)

# 1. Merge the training and the test sets to create one data set.
data <- bind_rows(trainData, testData)

# Clear other frames from environment
rm(list = setdiff(ls(), "data"))

# 3. Rename elements in activity column
activityLookupDF <- fread("./activity_labels.txt")
activityLookupDF <- rename(activityLookupDF, old = V1, new = V2)
activityLookup <- setNames(activityLookupDF$new, activityLookupDF$old)
data$activity <- as.character(activityLookup[data$activity])

# 2. Extract the means and standard deviations columns
meanColumns <- grep("\\bmean()\\b", names(data), value = TRUE)
stdColumns <- grep("\\bstd()\\b", names(data), value = TRUE)
dataMeansStds <- select(data, c(id, activity, 
                                all_of(meanColumns), all_of(stdColumns)))

# 5. Calculate average of each variable for each activity and each subject,
# store in a new data frame
meansDF <- dataMeansStds %>% 
        group_by(activity, id) %>% 
        summarize_all(mean) 

# Write to file:
write.table(meansDF, file = "./meansDF.txt",
            row.names = FALSE, col.names = TRUE)

