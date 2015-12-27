### Load libraries
packagesToLoad <- c("sqldf","data.table","dplyr","plyr")
lapply(packagesToLoad, require, character.only = TRUE)

### Get the files
if(!file.exists("./data/UCI_HAR_Dataset.zip")){
  if(!file.exists("./data")){
    dir.create("./data")
  }
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,destfile="./data/UCI_HAR_Dataset.zip",method="curl")
}


if(file.exists("./data/UCI_HAR_Dataset.zip")){
  ### Unzip the file
  unzip(zipfile="./data/UCI_HAR_Dataset.zip",exdir="./data")
  
  pathDataFiles <- file.path("./data", "UCI HAR Dataset")
  # files<-list.files(pathDataFiles, recursive=TRUE)
}


### Load  Metadata Files
features <- read.table(file.path(pathDataFiles, "features.txt"),header = FALSE, stringsAsFactors = FALSE)
activities <- read.table(file.path(pathDataFiles, "activity_labels.txt"), header = FALSE)

### Load Test Files
subjectTest <- read.table(file.path(pathDataFiles, "test" , "subject_test.txt"), header = FALSE)
featuresTest <- read.table(file.path(pathDataFiles, "test" , "X_test.txt"), header = FALSE)
activityTest <- read.table(file.path(pathDataFiles, "test" , "y_test.txt"), header = FALSE)

### Load Train Files
subjectTrain <- read.table(file.path(pathDataFiles, "train", "subject_train.txt"), header = FALSE)
featuresTrain <- read.table(file.path(pathDataFiles, "train", "X_train.txt"), header = FALSE)
activityTrain <- read.table(file.path(pathDataFiles, "train", "y_train.txt"), header = FALSE)


# 1.- Merges the training and the test sets to create one data set.

featuresData <-rbind(featuresTrain,featuresTest)
colnames(featuresData) <- features$V2

activitiesData <- rbind(activityTrain,activityTest)
colnames(activitiesData) <- "Activity"

subjectData <- rbind(subjectTrain, subjectTest)
colnames(subjectData) <- "Subject"


### Merge all
allData <- cbind(featuresData,activitiesData,subjectData)

# 2.- Extracts only the measurements on the mean and standard deviation for each measurement

sdMeansData <- allData[ ,c(grep("mean(",colnames(allData),fixed=TRUE),grep("std(",colnames(allData),fixed=TRUE))]
sdMeansData <- cbind(sdMeansData,activitiesData,subjectData)

# 3.- Uses descriptive activity names to name the activities in the data set
for(i in 1:length(allData$Activity)){
  allData$Activity[i]<-activities[allData$Activity[i],2]
}

# 4.- Appropriately labels the data set with descriptive variable names. 
names(sdMeansData)<-gsub("^t", "time", names(sdMeansData))
names(sdMeansData)<-gsub("^f", "frequency", names(sdMeansData))
names(sdMeansData)<-gsub("Acc", "Accelerometer", names(sdMeansData))
names(sdMeansData)<-gsub("Gyro", "Gyroscope", names(sdMeansData))
names(sdMeansData)<-gsub("Mag", "Magnitude", names(sdMeansData))

# 5.- From the data set in step 4, creates a second, independent tidy data set with the
# average of each variable for each activity and each subject.

secondData<-aggregate(. ~Subject + Activity, sdMeansData, mean)
secondData<-secondData[order(secondData$Activity,secondData$Subject ),]

write.table(secondData, file = "data.txt",row.name=FALSE)

### Prouduce Codebook
library(knitr)
knit2html("codebook.rmd");

