##  See the README file for information on packages needed to run

##  Read in the files ##
##  this assumes the zip file has been unzipped into the 
##  working directory per instructions
library(reshape2)

x_train <- read.table("./train/X_train.txt", stringsAsFactor=FALSE)
y_train <- read.table("./train/y_train.txt", stringsAsFactor=FALSE)
y_test <- read.table("./test/y_test.txt", stringsAsFactor=FALSE)
x_test <- read.table("./test/X_test.txt", stringsAsFactor=FALSE)
sub_train <- read.table("./train/subject_train.txt", stringsAsFactor=FALSE)
sub_test <- read.table("./test/subject_test.txt", stringsAsFactor=FALSE)

## append the activity id from y as a new column in x for both datasets
x_test$act_id <- y_test[,1]
x_train$act_id <- y_train[,1]

## append the subject id from sub as a new column in x for both datasets
x_test$subject <- sub_test[,1]
x_train$subject <- sub_train[,1]

## concatenate the rows of the two datasets into a new tt (testtrain) dataset
tt <- rbind(x_test, x_train)

## extract the column labels from the features file
features <- read.table("./features.txt")

## rename the columns of our cobined table to match the features
## note that we preserve the activity id on the final column
colnames(tt) <- c(as.character(features[,2]), "act_id", "subject")

## tt now contains training and test data with meaningful
## column names (straight from the features dataset), it also
## contains an activity and subject code in the final columns, labeled 
## appropriately.
## Next step is to select out only mean and std dev columns.
## Rather than type them in, I'll extract column names from
## features that contain "mean(" or "std(" and create a new
## subset with only those columns while moving the act_id
## and subject the front of the new dataframe
tt1 <- tt[,(c(562, 563, grep("mean\\(|std\\(", features$V2)))]

## now we will use a similar process to get the descriptive
## activity names out of the activity lables file and
## insert it into our dataframe

activities <- read.table("./activity_labels.txt")
tt2 <- merge(tt1, activities, by.x = "act_id", by.y = "V1")

# make the activities label column name meaningful
# and drop the old act_id column
colnames(tt2)[colnames(tt2) == "V2"] <- "activity"
tt2$act_id <- NULL

# melt all the variables into dataframe with 1 observation per 
# subject, by activity
tt3 <- melt(tt2, id=c("subject", "activity"))

# compute the mean for each unique row combination
tt4 <- dcast(tt3, subject + activity ~ variable, mean)

# tt4 is now 180 rows containing the mean of our 66 mean and
# std variables for each combination of subject and activity
# we can now tidy it up by melting it into a 4 column table 
# of data with a row for each variable-value pair
tt5 <- melt(tt4, id=c("subject", "activity"))
write.table(tt5,"./tidy-UCIHAR.txt", row.names=FALSE, quote=FALSE)
