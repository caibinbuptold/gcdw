#setwd("D:\\code\\openclass\\UCI HAR Dataset") #set working dir

#Read meta-data

features<-read.table("features.txt", header=FALSE)
colnames(features) <- c("id", "features.name")
activity_labels<-read.table("activity_labels.txt", header=FALSE)
colnames(activity_labels) <- c("label.id", "label")

#Merges the training and the test sets to create one data set

test.sub<-read.table("test\\subject_test.txt", header=FALSE)
test.x<-read.table("test\\X_test.txt", header=FALSE)
test.y<-read.table("test\\y_test.txt", header=FALSE)

train.sub<-read.table("train\\subject_train.txt", header=FALSE)
train.x<-read.table("train\\X_train.txt", header=FALSE)
train.y<-read.table("train\\y_train.txt", header=FALSE)

all.sub<-rbind(test.sub, train.sub)
all.x<-rbind(test.x, train.x)
all.y<-rbind(test.y, train.y)

colnames(all.sub) <- c("subject")
colnames(all.x) <- features$features.name
colnames(all.y) <- c("label.id")

#Extracts only the measurements on the mean and standard deviation for each measurement

extracted.index <- c(grep("std\\(\\)", features$features.name))                       #std()
extracted.index <- c(extracted.index, grep("mean\\(\\)", features$features.name))     #mean()
extracted.index <- c(extracted.index, grep("meanFreq\\(\\)", features$features.name)) #meanFreq()
extracted.index <- c(extracted.index, grep("Mean", features$features.name))           #Mean
all.x.extracted <- all.x[, extracted.index]

#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive activity names

all.y<-merge(activity_labels, all.y)
all<-cbind(all.sub, all.x.extracted, all.y)
all[,"label.id"]=NULL    #remove column label.id

#Creates a second, independent tidy data set with the average of each variable for each activity and each subject
require(plyr) 
tidy<-ddply(all, .(subject, label), numcolwise(mean))

require(reshape2)  #According to TA David Hood
tmelt<-melt(all, id = c("subject", "label"))
tidy2<-dcast(tmelt, subject + label ~ variable , mean)

write.csv(tidy, file="tidy.csv")
