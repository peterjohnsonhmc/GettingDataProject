#Part0: Preliminary Work & Download the data

#set working directory
setwd("C:/Users/Peter/Desktop/Data Science/Coursera")
path <- getwd()

#download
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- file.path(path, "Dataset.zip")
download.file(url,f)
#remember to save the date
dateDownloaded <- Sys.Date() #"2017-07-11"

#unzip the file
unzip("Dataset.zip", exdir = getwd())

#go look at the files
#we will not be dealing with the inertial signals files

#Read the files
features <- read.csv("./UCI HAR Dataset/features.txt", header =FALSE, sep = ' ')
#make the 2nd column characters
features <- as.character(features[,2])

activity<-read.table("UCI HAR Dataset/activity_labels.txt")

trainx <- read.table('./UCI HAR Dataset/train/X_train.txt')
trainy <- read.table('./UCI HAR Dataset/train/y_train.txt') #activities
trains <- read.table('./UCI HAR Dataset/train/subject_train.txt')

testx <- read.table('./UCI HAR Dataset/test/x_test.txt')
testy <- read.table('./UCI HAR Dataset/test/y_test.txt') #activities
tests <- read.table('./UCI HAR Dataset/test/subject_test.txt')

#Part1: Merge the training and test sets
train <- data.frame(trains,trainy,trainx)
names(train) <- c(c("subject", "activity"), features) #features are the names of the columns

test <- data.frame(tests,testy,testx)
names(test) <- c(c("subject", "activity"), features)

#bind it all together
data <- rbind(train, test)

#Part2: Extracts only the measurements on the mean and standard deviation for each measurement
#pick out features that include mean or std
meanSTDs <- grep(("mean|std"), features)

dataSubset <- data[,meanSTDs]

#Part3: Uses descriptive activity names to name the activities in the data set
#read the labels from activity_labels.txt
activityLabels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activityLabels <- as.character(activityLabels[,2])

dataSubset$activity <- activityLabels[dataSubset$activity]

#Part4: Appropriately labels the data set with descriptive variable names
#get the old names to clean up
#look at features info
newNames <- names(dataSubset)
#use gsub to remove stuff we dont want
newNames <- gsub("^t", "TimeDomain", newNames)
newNames <- gsub("^f", "FrequencyDomain", newNames)
newNames <- gsub("-","", newNames)
newNames <- gsub("Acc","Accelerometer", newNames)
newNames <- gsub("Gyro","Gyroscope", newNames)
newNames <- gsub("Mag","Magnitude", newNames)
newNames <- gsub("std","StandardDeviation", newNames)
newNames <- gsub("mean","Mean", newNames)
newNames <- gsub("[(][)]","", newNames)
newNames <- gsub("correlation","Correlation", newNames)
names(dataSubset) <- newNames
#Part5: From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject

#aggregate Splits the data into subsets, computes summary statistics for each, and 
#returns the result in a convenient form.
tidyData <- aggregate(dataSubset[,3:79], by= list(activity = dataSubset$activity, subject=dataSubset$subject),FUN=mean)

#return output as tidyData.txt
write.table(x=tidyData, file="tidyData.txt", row.names = FALSE)