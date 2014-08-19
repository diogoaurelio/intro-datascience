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

#To find out the total number of people in each subset:
aggregate(Survived ~ Child + Sex, data=trainData, FUN=length)
#  Child    Sex Survived
#1     0 female      259
#2     1 female       55
#3     0   male      519
#4     1   male       58

#To find out the proportions, change the FUN applied in aggregate:
aggregate(Survived ~ Child + Sex, data=trainData, FUN= function(x) { sum(x)/length(x) } )
#  Child    Sex  Survived
#1     0 female 0.7528958
#2     1 female 0.6909091
#3     0   male 0.1657033
#4     1   male 0.3965517

#Investigating now at the passenger class
# Let’s bin the fares into less than $10, between $10 and $20, $20 to $30 and more than $30 and store it to a new variable
trainData$Fare2 <- '30+'
trainData$Fare2[trainData$Fare < 30 & trainData$Fare >= 20] <- '20-30'
trainData$Fare2[trainData$Fare < 20 & trainData$Fare >= 10] <- '10-20'
trainData$Fare2[trainData$Fare < 10] <- '<10'

#Now running same aggregate function to see if there are any interesting results:
aggregate(Survived ~ Child + Fare2 + Sex, data = trainData, FUN = function(x) { sum(x)/length(x) } )

#   Child Fare2    Sex  Survived
#1      0 10-20 female 0.7166667
#2      1 10-20 female 0.7777778
#3      0 20-30 female 0.7173913
#4      1 20-30 female 0.5454545
#5      0   30+ female 0.9062500
#6      1   30+ female 0.6315789
#7      0   <10 female 0.5614035
#8      1   <10 female 0.8571429 #Children in 3rd class do better than female adults in same class 
#9      0 10-20   male 0.1222222
#10     1 10-20   male 0.7272727
#11     0 20-30   male 0.2153846
#12     1 20-30   male 0.3571429
#13     0   30+   male 0.3238095
#14     1   30+   male 0.4000000
#15     0   <10   male 0.1042471
#16     1   <10   male 0.1538462

aggregate(Survived ~ Fare2 + Pclass + Sex, data = trainData, FUN = function(x) { sum(x)/length(x) } )
#   Fare2 Pclass    Sex  Survived
#1  20-30      1 female 0.8333333
#2    30+      1 female 0.9772727
#3  10-20      2 female 0.9142857
#4  20-30      2 female 0.9000000
#5    30+      2 female 1.0000000 
#6  10-20      3 female 0.5813953
#7  20-30      3 female 0.3333333
#8    30+      3 female 0.1250000 
#9    <10      3 female 0.5937500
#10 20-30      1   male 0.4000000
#11   30+      1   male 0.3837209
#12   <10      1   male 0.0000000
#13 10-20      2   male 0.1587302
#14 20-30      2   male 0.1600000
#15   30+      2   male 0.2142857
#16   <10      2   male 0.0000000
#17 10-20      3   male 0.2368421
#18 20-30      3   male 0.1250000
#19   30+      3   male 0.2400000
#20   <10      3   male 0.1115385

aggregate(Survived ~ Fare2 + Pclass + Child + Sex, data = trainData, FUN = function(x) { sum(x)/length(x) } )

#Overall Conclusions

#   Fare2 Pclass Child    Sex   Survived
#1  20-30      1     0 female 0.83333333
#2    30+      1     0 female 0.98750000 #female who are in Pclass 1 and Pclass 2 & pay +30 do better
#3  10-20      2     0 female 0.90625000
#4  20-30      2     0 female 0.88000000
#5    30+      2     0 female 1.00000000 #female who are in Pclass 1 and Pclass 2 & pay +30 do better
#6  10-20      3     0 female 0.50000000
#7  20-30      3     0 female 0.40000000
#8    30+      3     0 female 0.11111111 #females who pay more than 10 yield worse results in Pclass 3
#9    <10      3     0 female 0.56140351
#10   30+      1     1 female 0.87500000 #Being a female child did not yield better result in Pclass 1
#11 10-20      2     1 female 1.00000000 #But did on 2nd class, no matter the price!
#12 20-30      2     1 female 1.00000000 #But did on 2nd class, no matter the price!
#13   30+      2     1 female 1.00000000 #But did on 2nd class, no matter the price!
#14 10-20      3     1 female 0.73333333
#15 20-30      3     1 female 0.16666667
#16   30+      3     1 female 0.14285714
#17   <10      3     1 female 0.85714286
#18 20-30      1     0   male 0.40000000
#19   30+      1     0   male 0.35365854
#20   <10      1     0   male 0.00000000
#21 10-20      2     0   male 0.11864407
#22 20-30      2     0   male 0.04761905
#23   30+      2     0   male 0.00000000
#24   <10      2     0   male 0.00000000
#25 10-20      3     0   male 0.12903226
#26 20-30      3     0   male 0.07142857
#27   30+      3     0   male 0.41666667
#28   <10      3     0   male 0.10931174
#29   30+      1     1   male 1.00000000 #Being a male child on Pclass 1 yields better results;
#30 10-20      2     1   male 0.75000000 #Being a male child on Pclass 2 yields better results;
#31 20-30      2     1   male 0.75000000 #Being a male child on Pclass 2 yields better results;
#32   30+      2     1   male 1.00000000 #Being a male child on Pclass 2 yields better results;
#33 10-20      3     1   male 0.71428571 
#34 20-30      3     1   male 0.20000000
#35   30+      3     1   male 0.07692308
#36   <10      3     1   male 0.15384615

#Trying my own conclusions, not the Blog-tuturial conclusions
testData$Survived <- 0
testData$Survived[testData$Sex == 'female' & testData$Pclass == 1 & testData$Pclass == 2 ] <- 1
testData$Survived[testData$Sex == 'male' & testData$Age < 18 & testData$Pclass != 3] <- 1
submit <- data.frame(PassengerId = testData$PassengerId, Survived = testData$Survived)
write.csv(submit, file ="./data/woman_pclass_age.csv", row.names = F)

#did not improve my position at Kaggle...
testData$Survived <- 0
testData$Survived[testData$Sex == 'female'] <- 1
testData$Survived[testData$Sex == 'female' & testData$Pclass == 3 & testData$Fare >= 20] <- 0
testData$Survived[testData$Sex == 'male' & testData$Age < 18 & testData$Pclass != 3] <- 1
submit <- data.frame(PassengerId = testData$PassengerId, Survived = testData$Survived)
write.csv(submit, file ="./data/woman_pclass_age.csv", row.names = F)

#Alright! "You improved on your best score by 0.01914. You just moved up 821 positions on the leaderboard."



#Using Machine Learning Techniques - Decision Trees

#rpart for ‘Recursive Partitioning and Regression Trees’ and uses the CART decision tree algorithm. While rpart comes with base R, you still need to import the functionality each time you want to use it.
library(rpart)
#You feed it the equation, headed up by the variable of interest and followed by the variables used for prediction. You then point it at the data, and for now, follow with the type of prediction you want to run (see ?rpart for more info).
#If you wanted to predict a continuous variable, such as age, you may use method=”anova”. This would run generate decimal quantities for you. But here, we just want a one or a zero, so method=”class” is appropriate:

fit <- rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked, data=trainData, method="class")
plot(fit)
text(fit)

dev.copy(png, file="./data/decisionTree1.png", height=480, width=480)
dev.off()

#To get some more informative graphics, you will need to install some external packages
install.packages('rattle')
install.packages('rpart.plot')
install.packages('RColorBrewer')
library(rattle)
library(rpart.plot)
library(RColorBrewer)

fancyRpartPlot(fit)
dev.copy(png, file = "./data/decisionTree2.png", height = 480, width=480)
dev.off()

#To make a prediction from this tree doesn’t require all the subsetting and overwriting we did last lesson, it’s actually a lot easier.
Prediction <- predict(fit, testData, type = "class")
submit <- data.frame(PassengerId = testData$PassengerId, Survived = Prediction)
write.csv(submit, file = "./data/myfirstdtree.csv", row.names = FALSE)
#Kaggle results: "Your submission scored 0.78469, which is not an improvement of your best score. Keep trying!" . Hmm...

#The rpart package automatically caps the depth that the tree grows by using a metric called complexity which stops the resulting model from getting too out of hand. But we already saw that a more complex model than what we made ourselves did a bit better, so why not go all out and override the defaults? Let’s do it. You can find the default limits by typing ?rpart.control. The first one we want to unleash is the cp parameter, this is the metric that stops splits that aren’t deemed important enough. The other one we want to open up is minsplit which governs how many passengers must sit in a bucket before even looking for a split. Let’s max both out and reduce cp to zero and minsplit to 2 (no split would obviously be possible for a single passenger in a bucket)

fit <- rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked, data=trainData,
             method="class", control=rpart.control(minsplit=2, cp=0))
fancyRpartPlot(fit)
Prediction <- predict(fit, testData, type="class")
submit <- data.frame(PassengerId = testData$PassenferId, Survived = Prediction)

#However score on Kaggle does not improve because of overfitting!
#Overfitting is technically defined as a model that performs better on a training set than another simpler model, but does worse on unseen data, as we saw here. We went too far and grew our decision tree out to encompass massively complex rules that may not generalize to unknown passengers. Perhaps that 34 year old female in third class who paid $20.17 for a ticket from Southampton with a sister and mother aboard may have been a bit of a rare case after all
#The point of this exercise was that you must use caution with decision trees. While this particular tree may have been 100% accurate on the data that you trained it on, even a trivial tree with only one rule could beat it on unseen data. You just overfit big time!



#Before moving on, I encourage you to have a play with the various control parameters we saw in the rpart.control help file. Perhaps you can find a tree that does a little better by either growing it out further, or reigning it in. You can also manually trim trees in R with these commands:

fit <- rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked, data=train,
             method="class", control=rpart.control( your controls ))
new.fit <- prp(fit,snip=TRUE)$obj
fancyRpartPlot(new.fit)

#An interactive version of the decision tree will appear in the plot tab where you simply click on the nodes that you want to kill. Once you’re satisfied with the tree, hit ‘quit’ and it will be stored to the new.fit object. Try to look for overly complex decisions being made, and kill the nodes that appear to go to far. 

###Feature engineering
#Analysing reamining variables, starting by Name
trainData$Name[1]
#[1] Braund, Mr. Owen Harris
#891 Levels: Abbing, Mr. Anthony ... van Melkebeke, Mr. Philemon

#New data.frame to work
trainData <- read.table("./data/train.csv", sep=",", header=TRUE)
testData$Survived <- NA
combi <- rbind(trainData, testData)

#strings are automatically imported as factors in R, even if it doesn’t make sense. So we need to cast this column back into a text string. To do this we use as.character.
combi$Name <- as.character(combi$Name)
combi$Name[1]

#Splitting Strings through basic RGEX:
strsplit(combi$Name[1], split='[,.]')
#[[1]]
#[1] "Braund"       " Mr"          " Owen Harris"
strsplit(combi$Name[1], split='[,.]')[[1]]
#[1] "Braund"       " Mr"          " Owen Harris"

#String split uses a doubly stacked matrix because it can never be sure that a given regex will have the same number of pieces. If there were more commas or periods in the name, it would create more segments, so it hides them a level deeper to maintain the rectangular types of containers that we are used to in things like spreadsheets, or now dataframes!

#Ripping specific parts
strsplit(combi$Name[1], split='[,.]')[[1]][[2]]
#" Mr"
combi$Title <- sapply(combi$Name, FUN = function(x) { strsplit(x, split='[,.]')[[1]][[2]] })

#R’s apply functions all work in slightly different ways, but sapply will work great here. We feed sapply our vector of names and our function that we just came up with. It runs through the rows of the vector of names, and sends each name to the function. The results of all these string splits are all combined up into a vector as output from the sapply function, which we then store to a new column in our original dataframe, called Title.
#Finally, we may wish to strip off those spaces from the beginning of the titles. Here we can just substitute the first occurrence of a space with nothing. We can use sub for this (gsub would replace all spaces, poor ‘the Countess’ would look strange then though)

combi$Title <- sub(' ', '', combi$Title)
table(combi$Title)
#         Capt           Col           Don          Dona            Dr 
#            1             4             1             1             8 
#     Jonkheer          Lady         Major        Master          Miss 
#            1             1             2            61           260 
#         Mlle           Mme            Mr           Mrs            Ms 
#            2             1           757           197             2 
#          Rev           Sir  the Countess 
#            8             1             1 

combi$Title[combi$Title %in% c('Mme', 'Mlle')] <- 'Mlle'

#What have we done here? The %in% operator checks to see if a value is part of the vector we’re comparing it to. So here we are combining two titles, ‘Mme’ and ‘Mlle’, into a new temporary vector using the c() operator and seeing if any of the existing titles in the entire Title column match either of them. We then replace any match with ‘Mlle’.
#Let’s keep looking for redundancy. It seems the very rich are a bit of a problem for our set here too. For the men, we have a handful of titles that only one or two have been blessed with: Captain, Don, Major and Sir. All of these are either military titles, or rich fellas who were born with vast tracts of land. For the ladies, we have Dona, Lady, Jonkheer (*see comments below), and of course our Countess. All of these are again the rich folks, and may have acted somewhat similarly due to their noble birth. Let’s combine these two groups and reduce the number of factor levels to something that a decision tree might make sense of:
combi$Title[combi$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
combi$Title[combi$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'


#Our final step is to change the variable type back to a factor, as these are essentially categories that we have created:
combi$Title <- factor(combi$Title)

#variables SibSb and Parch that indicate the number of family members the passenger is travelling with. Seems reasonable to assume that a large family might have trouble tracking down little Johnny as they all scramble to get off the sinking ship, so let’s combine the two variables into a new one, FamilySize:
combi$FamilySize <- combi$SibSp + combi$Parch + 1

#Pretty simple! We just add the number of siblings, spouses, parents and children the passenger had with them, and plus one for their own existence of course, and have a new variable indicating the size of the family they travelled with.

#Combining the Surname with the family size to obtain 
combi$Surname <- sapply(combi$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
#combi$Surname <- sub(' ', '', combi$Surname)

#We then want to append the FamilySize variable to the front of it, but as we saw with factors, string operations need strings. So let’s convert the FamilySize variable temporarily to a string and combine it with the Surname to get our new FamilyID variable:
combi$FamilyID <- paste(as.character(combi$FamilySize), combi$Surname, sep="")

#We used the function paste to bring two strings together, and told it to separate them with nothing through the sep argument. This was stored to a new column called FamilyID. But those three single Johnsons would all have the same Family ID. Given we were originally hypothesising that large families might have trouble sticking together in the panic, let’s knock out any family size of two or less and call it a “small” family. This would fix the Johnson problem too.
combi$FamilyID[combi$FamilySize <= 2] <- 'Small'
table(combi$FamilyID)
famIDs <- data.frame(table(combi$FamilyID))

#Here we see again all those naughty families that didn’t work well with our assumptions, so let’s subset this dataframe to show only those unexpectedly small FamilyID groups.
famIDs <- famIDs[famIDs$Freq <= 2,]

#overwrite any family IDs in our dataset for groups that were not correctly identified 
combi$FamilyID[combi$FamilyID %in% famIDs$Var1] <- 'Small'
combi$FamilyID <- factor(combi$FamilyID)

#We are now ready to split the test and training sets back into their original states, carrying our fancy new engineered variables with them. The nicest part of what we just did is how the factors are treated in R. Behind the scenes, factors are basically stored as integers, but masked with their text names for us to look at. If you create the above factors on the isolated test and train sets separately, there is no guarantee that both groups exist in both sets.

#Because we built the factors on a single dataframe, and then split it apart after we built them, R will give all factor levels to both new dataframes, even if the factor doesn’t exist in one. It will still have the factor level, but no actual observations of it in the set. Neat trick right? Let me assure you that manually updating factor levels is a pain.

#So let’s break them apart and do some predictions on our new fancy engineered variables:
train <- combi[1:891,]
test <- combi[892:1309,]

#Time to do our predictions! We have a bunch of new variables, so let’s send them to a new decision tree. Last time the default complexity worked out pretty well, so let’s just grow a tree with the vanilla controls and see what it can do
fit <- rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID,
             data=train, method="class")
fancyRpartPlot(fit)

dev.copy(png, file = "./data/featureEngineering.png", height = 480, width=480)
dev.off()

Prediction <- predict(fit, test, type = "class")
submit <- data.frame(PassengerId = test$PassengerId, Survived = Prediction)
write.csv(submit, file = "./data/featureEngineering.csv", row.names = FALSE)

#Your Best Entry
#You improved on your best score by 0.01435. 
#You just moved up 448 positions on the leaderboard. 0.79904


#Final Approach: Random Forests

#First Approach - Bagging:
sample(1:10, replace = TRUE)
#In this simulation, we would still have 10 rows to work with, but rows 1, 2, 9 and 10 are each repeated twice, while rows 4, 5, 6 and 8 are excluded. If you run this command again, you will get a different sample of rows each time. On average, around 37% of the rows will be left out of the bootstrapped sample. With these repeated and omitted rows, each decision tree grown with bagging would evolve slightly differently. If you have very strong features such as gender in our example though, that variable will probably still dominate the first decision in most of your trees.

#Second Approach - The second source of randomness gets past this limitation though. Instead of looking at the entire pool of available variables, Random Forests take only a subset of them, typically the square root of the number available. In our case we have 10 variables, so using a subset of three variables would be reasonable. The selection of available variables is changed for each and every node in the decision trees. This way, many of the trees won’t even have the gender variable available at the first split, and might not even see it until several nodes deep.

#R’s Random Forest algorithm has a few restrictions that we did not have with our decision trees. The big one has been the elephant in the room until now, we have to clean up the missing values in our dataset. rpart has a great advantage in that it can use surrogate variables when it encounters an NA value. In our dataset there are a lot of age values missing. If any of our decision trees split on age, the tree would search for another variable that split in a similar way to age, and use them instead. Random Forests cannot do this, so we need to find a way to manually replace these values. A method we implicitly used in part 2 when we defined the adult/child age buckets was to assume that all missing values were the mean or median of the remaining data. Since then we’ve learned a lot of new skills though, so let’s use a decision tree to fill in those values instead. Let’s pick up where we left off last lesson, and take a look at the combined dataframe’s age variable to see what we’re up against


summary(combi$Age)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#   0.17   21.00   28.00   29.88   39.00   80.00     263 

#263 values out of 1309 were missing this whole time, that’s a whopping 20%! A few new pieces of syntax to use. Instead of subsetting by boolean logic, we can use the R function is.na(), and it’s reciprocal !is.na() (the bang symbol represents ‘not’). This subsets on whether a value is missing or not. We now also want to use the method=”anova” version of our decision tree, as we are not trying to predict a category any more, but a continuous variable. So let’s grow a tree on the subset of the data with the age values available, and then replace those that are missing

Agefit <- rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title + FamilySize,
                data=combi[!is.na(combi$Age),], method="anova")
combi$Age[is.na(combi$Age)] <- predict(Agefit, combi[is.na(combi$Age),])

summary(combi$Embarked)
#      C   Q   S 
#  2 270 123 914 

#Embarked has a blank for two passengers. While a blank wouldn’t be a problem for our model like an NA would be, since we’re cleaning anyhow, let’s get rid of it. Because it’s so few observations and such a large majority boarded in Southampton, let’s just replace those two with ‘S’. First we need to find out who they are though! We can use which for this:
which(combi$Embarked == '')
#[1]  62 830

#This gives us the indexes of the blank fields. Then we simply replace those two, and encode it as a factor
combi$Embarked[c(62,830)] = "S"
combi$Embarked <- factor(combi$Embarked)

which(is.na(combi$Fare))
#[1] 1044
combi$Fare[1044] <- median(combi$Fare, na.rm = TRUE)
combi$Fare[1044]
#[1] 14.4542

#Okay. Our dataframe is now cleared of NAs. Now on to restriction number two: Random Forests in R can only digest factors with up to 32 levels. Our FamilyID variable had almost double that. We could take two paths forward here, either change these levels to their underlying integers (using the unclass() function) and having the tree treat them as continuous variables, or manually reduce the number of levels to keep it under the threshold.

#Let’s take the second approach. To do this we’ll copy the FamilyID column to a new variable, FamilyID2, and then convert it from a factor back into a character string with as.character(). We can then increase our cut-off to be a “Small” family from 2 to 3 people. Then we just convert it back to a factor and we’re done:

combi$FamilyID2 <- combi$FamilyID
combi$FamilyID2 <- as.character(combi$FamilyID2)
combi$FamilyID2[combi$FamilySize <= 3] <- 'Small'
combi$FamilyID2 <- factor(combi$FamilyID2)

#Okay, we’re down to 22 levels so we’re good to split the test and train sets back up as we did last lesson and grow a Random Forest. Install and load the package randomForest:

install.packages('randomForest')
library(randomForest)

train <- combi[1:891,]
test <- combi[892:1309,]

#Because the process has the two sources of randomness that we discussed earlier, it is a good idea to set the random seed in R before you begin. This makes your results reproducible next time you load the code up, otherwise you can get different classifications for each run.

set.seed(415)
#The number inside isn’t important, you just need to ensure you use the same seed number each time so that the same random numbers are generated inside the Random Forest function.

#Now we’re ready to run our model. The syntax is similar to decision trees, but there’s a few extra options.
fit <- randomForest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize +
                    FamilyID2, data=train, importance=TRUE, ntree=2000)
				



#Instead of specifying method=”class” as with rpart, we force the model to predict our classification by temporarily changing our target variable to a factor with only two levels using as.factor(). The importance=TRUE argument allows us to inspect variable importance as we’ll see, and the ntree argument specifies how many trees we want to grow.
#If you were working with a larger dataset you may want to reduce the number of trees, at least for initial exploration, or restrict the complexity of each tree using nodesize as well as reduce the number of rows sampled with sampsize. You can also override the default number of variables to choose from with mtry, but the default is the square root of the total number available and that should work just fine. Since we only have a small dataset to play with, we can grow a large number of trees and not worry too much about their complexity, it will still run pretty fast. So let’s look at what variables were important


varImpPlot(fit)

#Remember with bagging how roughly 37% of our rows would be left out? Well Random Forests doesn’t just waste those “out-of-bag” (OOB) observations, it uses them to see how well each tree performs on unseen data. It’s almost like a bonus test set to determine your model’s performance on the fly. There’s two types of importance measures shown above. The accuracy one tests to see how worse the model performs without each variable, so a high decrease in accuracy would be expected for very predictive variables. The Gini one digs into the mathematics behind decision trees, but essentially measures how pure the nodes are at the end of the tree. Again it tests to see the result if each variable is taken out and a high score means the variable was important. Unsurprisingly, our Title variable was at the top for both measures. We should be pretty happy to see that the remaining engineered variables are doing quite nicely too. Anyhow, enough delay, let’s see how it did! The prediction function works similarly to decision trees, and we can build our submission file in exactly the same way. It will take a bit longer though, as all 2000 trees need to make their classifications and then discuss who’s right:

Prediction <- predict(fit, test)
submit <- data.frame(PassengerId = test$PassengerId, Survived = Prediction)
write.csv(submit, file = "./data/firstforest.csv", row.names = FALSE)


#Hrmm, well this actually worked out exactly the same as Kaggle’s Python random forest tutorial. I wouldn’t take that as the expected result from any forest though, this may just be pure coincidence. It’s relatively poor performance does go to show that on smaller datasets, sometimes a fancier model won’t beat a simple one. Besides that, there’s also the private leaderboard as only 50% of the test data is evaluated for our public scores. But let’s not give up yet. There’s more than one ensemble model. Let’s try a forest of conditional inference trees. They make their decisions in slightly different ways, using a statistical test rather than a purity measure, but the basic construction of each tree is fairly similar. So go ahead and install and load the party package.

install.packages('party')
library(party)

#We again set the seed for consistent results and build a model in a similar way to our Random Forest:
set.seed(415)
fit <- cforest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID,
               data = train, controls=cforest_unbiased(ntree=2000, mtry=3))
			
			
#Conditional inference trees are able to handle factors with more levels than Random Forests can, so let’s go back to out original version of FamilyID. You may have also noticed a few new arguments. Now we have to specify the number of trees inside a more complicated command, as arguments are passed to cforest differently. We also have to manually set the number of variables to sample at each node as the default of 5 is pretty high for our dataset. Okay, let’s make another prediction:

Prediction <- predict(fit, test, OOB=TRUE, type = "response")
submit <- data.frame(PassengerId = test$PassengerId, Survived = Prediction)
write.csv(submit, file = "./data/secondforest.csv", row.names = FALSE)

#You improved on your best score by 0.01435. You just moved up 175 positions on the leaderboard. Score: 0.81340