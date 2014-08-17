##########################################
#Disclosure: I am following this (really good, btw) blog tutorial provided on Kaggle itself, since this is challenge just for learning purposes:
#Source: http://trevorstephens.com/post/72916401642/titanic-getting-started-with-r
##########################################

###Start importing the data
#Set the working directory (Note: this depends on your own computor directory structure, please adjust to the directory where you want to work)
setwd("./kaggle-titanic-problem")

#Setup folder to receive data:
if (!file.exists("data")) {
	dir.create("data")
}
#Confirm folder was created:
dir()

#Get training data

#if (!file.exists("./data/train.csv")) {
	#Train.csv url
#	trainUrl <- "http://www.kaggle.com/c/titanic-gettingStarted/download/train.csv"
#	download.file(trainUrl, destfile = "./data/train.csv", method = "curl")
#	list.files("./data")
#	dateDownloaded <- date()
#	dateDownloaded
#	} else {
#		print("File already downloaded")
#	}
trainData <- read.table("./data/train.csv", sep=",", header=TRUE)
head(trainData)
#Take a look at the dataframe structure:
str(trainData)
#'data.frame':	891 obs. of  12 variables:
# $ PassengerId: int  1 2 3 4 5 6 7 8 9 10 ...
# $ Survived   : int  0 1 1 1 0 0 0 0 1 1 ...
# $ Pclass     : int  3 1 3 1 3 3 1 3 3 2 ...
# $ Name       : Factor w/ 891 levels "Abbing, Mr. Anthony",..: 109 191 354 273 16 555 516 625 413 577 ...
# $ Sex        : Factor w/ 2 levels "female","male": 2 1 1 1 2 2 2 2 1 1 ...
# $ Age        : num  22 38 26 35 35 NA 54 2 27 14 ...
# $ SibSp      : int  1 1 0 1 0 0 0 3 0 1 ...
# $ Parch      : int  0 0 0 0 0 0 0 1 2 0 ...
# $ Ticket     : Factor w/ 681 levels "110152","110413",..: 524 597 670 50 473 276 86 396 345 133 ...
# $ Fare       : num  7.25 71.28 7.92 53.1 8.05 ...
# $ Cabin      : Factor w/ 148 levels "","A10","A14",..: 1 83 1 57 1 1 131 1 1 1 ...
# $ Embarked   : Factor w/ 4 levels "","C","Q","S": 4 2 4 4 4 3 4 4 4 2 ...

#table command provids summary picture: 549 died, 342 survived; 
> table(trainData$Survived)

#  0   1 
#549 342 

#In terms of proportion:
prop.table(table(trainData$Survived))

#        0         1 
#0.6161616 0.3838384 

#Starting to test some assumptions with test data
testData <- read.table("./data/test.csv", sep=",", header=T)
str(testData)
#'data.frame':	418 obs. of  11 variables:
# $ PassengerId: int  892 893 894 895 896 897 898 899 900 901 ...
# $ Pclass     : int  3 3 2 3 3 3 3 2 3 3 ...
# $ Name       : Factor w/ 418 levels "Abbott, Master. Eugene Joseph",..: 207 404 270 409 179 367 85 58 5 104 ...
# $ Sex        : Factor w/ 2 levels "female","male": 2 1 2 2 1 2 1 2 1 2 ...
# $ Age        : num  34.5 47 62 27 22 14 30 26 18 21 ...
# $ SibSp      : int  0 1 0 0 1 0 0 1 0 2 ...
# $ Parch      : int  0 0 0 0 1 0 0 1 0 0 ...
# $ Ticket     : Factor w/ 363 levels "110469","110489",..: 153 222 74 148 139 262 159 85 101 270 ...
# $ Fare       : num  7.83 7 9.69 8.66 12.29 ...
# $ Cabin      : Factor w/ 77 levels "","A11","A18",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ Embarked   : Factor w/ 3 levels "C","Q","S": 2 3 2 3 3 3 2 3 1 3 ...

#Test 1: suppose everyone on testData died; the following creates a new column (since testData does not have survivor values)
testData$Survived <- rep(0, 418)
submit <- data.frame(PassengerId = testData$PassengerId, Survived = testData$Survived)
write.csv(submit, file = "./data/theyallperish.csv", row.names= F)
dir("./data") #confirm that csv was created
#[1] "genderclassmodel.csv" "gendermodel.csv"      "test.csv"            
#[4] "theyallperish.csv"    "train.csv" 

#Submit to Kaggle as a test submission and confirm that I'm not indeed the only one following this tutorial!

#The disaster was famous for saving “women and children first”
summary(trainData$Sex)
#female   male 
#   314    577

prop.table(table(trainData$Sex, trainData$Survived))        
#                  0          1
#  female 0.09090909 0.26150393
#  male   0.52525253 0.12233446
prop.table(table(trainData$Sex, trainData$Survived),1) #to have relative to the sex       
#                 0         1
#  female 0.2579618 0.7420382 #The maxority of females survived
#  male   0.8110919 0.1889081 #Only a very short number of man survived, most likely upper class

#Test 2: set all female sex passengers as having survived; 
testData$Survived <- 0
testData$Survived[testData$Sex == 'female'] <- 1 
submit <- data.frame(PassengerId = testData$PassengerId, Survived = testData$Survived)
write.csv(submit, file ="./data/womanpower.csv", row.names = F)

#Analysis by Age	
summary(trainData$Age)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#   0.42   20.12   28.00   29.70   38.00   80.00     177 

#Creating a new variable "Child", and assuming that children also survived:
trainData$Child <- 0
trainData$Child[trainData$Age <18] <- 1 
aggregate(Survived ~ Child + Sex, data=trainData, FUN=sum)
#  Child    Sex Survived
#1     0 female      195
#2     1 female       38
#3     0   male       86
#4     1   male       23


