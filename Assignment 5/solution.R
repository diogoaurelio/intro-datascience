library(caret)
library(rpart) #Random Decision Tree
library(tree)
library(randomForest) #Random Fores Algorithm
library(e1071) #To call SVM predictions
library(ggplot2) #plotting
#Optional:
#library(caTools) #Used for sampling!

#setwd("./Documents/Developer/Intro to Data Science/Materials/datasci_course_materials/assignment5/")
file1 <- "./seaflow_21min.csv"
myData <- read.csv(file1)

#Step 1: Read and summarize the data
#Using R, read the file seaflow_21min.csv and get the overall counts for each category of particle. You may consider using the functions read.csv and summary.

#Answer Questions 1 and 2.

#Question 1
#How many particles labeled "synecho" are in the file provided?
a <- myData[myData$pop == 'synecho', ]
nrow(a)
#or summary(myData$pop)
#18146

#Question 2
#What is the 3rd Quantile of the field fsc_small? (the summary function computes this on your behalf)
summary(myData)
#39184
#Or: sort(myData$fsc_small)[nrow(myData)*.75]



#Step 2: Split the data into test and training sets
#Divide the data into two equal subsets, one for training and one for testing. Make sure to divide the data in an unbiased manner.
#You might consider using either the createDataPartition function or the sample function, although there are many ways to achieve the goal.


#nrow(myData)
#[1] 72343
set.seed(12345) #ensuring this is reproducible
a <- sample(1:nrow(myData)) #creates a random sample
myData2 <- data.frame(a, myData)
head(myData2)
trainingSet <- myData2[myData2$a > ceiling(nrow(myData)/2),]
testSet <- myData2[myData2$a < ceiling(nrow(myData)/2),]
nrow(trainingSet)
#[1] 36171
nrow(testSet)
#[1] 36171

#Or with library caTools, use sample.split function, which makes it faster and simpler. More info: http://www.inside-r.org/packages/cran/caTools/docs/sample.split
#set.seed(12345)
#split <- sample.split(myData, SplitRatio = 1/2)
#trainingSet <- subset(myData, split == T)
#testSet <- subset(myData, split == F)
#nrow(trainingSet)
#nrow(testSet)

#Answer Question 3.

#Question 3
#What is the mean of the variable "time" for your training set?
mean(trainingSet$time)
# 342.0307



#Step 3: Plot the data
#Plot pe against chl_small	and color by pop

#Me experimenting some stuff out...
#with(myData, plot(pe,chl_small))
#boxplot(with(myData, pe ~ chl_small, data = myData, col="red"))

#This one is indeed waaaay better:
qplot(pe, chl_small, data=myData, color=pop)
dev.copy(png, file="question4plot.png")
dev.off()

#I recommend using the function ggplot in the library ggpplot2 rather than using base R functions, but this is not required.

#OK, lets give that a try...
g <- ggplot(myData, aes(x=pe, y=chl_small, color=pop))
p <- g + geom_point()
p #And... Exactly the same thing, but more complicated...
#Maybe...
q <- g + geom_line()
q #hmm...
#Answer Question 4.

#Question 4
#In the plot of pe vs. chl_small, the particles labeled ultra should appear to be somewhat "mixed" with two other populations of particles. Which two populations?
#nano and pico. 
#Note to self: good thing I'm not colorblind...


#Step 4: Train a decision tree.
#Install the rpart library if you do not have it, and load the library.

#Many statistical models in R provide an interface of the form

#model <- train(formula, dataframe)
#You can then use the model object to make predictions by passing it to the predict function.

#A formula object describes the relationship between the independent variables and the response variable, and can be expressed with the syntax

#response ~ var1 + var2 + var3
#and used with the formula function to construct the formula object itself:
#fol <- formula(response ~ var1 + var2 + var3)
#The rpart library uses this convention. Assuming your training data is in a data frame called training and you have constructed a formula objec tcalled fol, you can construct a decision tree using the following syntax (included here to avoid you struggling with a couple of unusual aspects of R):

#model <- rpart(fol, method="class", data=training)
#Train a tree as a function of the sensor measurements: fsc_small + fsc_perp + fsc_big + pe + chl_big + chl_small

#Print the model object using the print function print(model)

#The output is a set of decision nodes, one node per line. Each line is indented indicating the height of the tree. Here is a bogus example of a tree:

# 1) root 33456 22345 nano (0.0016 0.17 0.29 0.25 0.28)  
#   2) chl_small< 31000 26238 15772 pico (0 0.22 0.4 3.8e-05 0.38)  
#     4) fsc_perp< 2040 11430  1913 pico (0 8.7e-05 0.83 8.7e-05 0.17) *
#       10) chl_small>=12000 7065   628 nano (0 0.88 0 0 0.12) *
#       11) chl_small< 12000 9000  2232 ultra (0 0.13 0.097 0 0.77) *
#     5) fsc_perp>=2040 14808  5500 ultra (0 0.39 0.064 0 0.55)  
#   3) chl_small>=31000 9933   780 synecho (0.0058 0.054 0.0044 0.92 0.014)  
#     6) pe>=17532 681   156 nano (0.085 0.77 0 0.069 0.075) *
#     7) pe< 17532 9252   146 synecho (0 0.0014 0.0048 0.98 0.0096) *
#To make a prediction, walk down the tree applying the predicates to determine which branch to take. For example, in this bogus tree, a particle with chl_small=25000 and fsc_perp=1000 would take branch 2, branch 4, then branch 10, and be classified as nano.

#Answer Questions 5, 6, 7.

pop ~ fsc_small + fsc_perp + fsc_big + pe + chl_big + chl_small
fol <- formula(pop ~ fsc_small + fsc_perp + fsc_big + pe + chl_big + chl_small)
model <- rpart(fol, method="class", data=trainingSet)
print(model)

#1) root 36171 25773 pico (0.0015 0.17 0.29 0.25 0.28)  
#  2) pe< 5004 26295 15947 pico (0 0.22 0.39 0 0.39)  
#    4) chl_small< 31870.5 10993  1770 pico (0 0.00018 0.84 0 0.16) *
#    5) chl_small>=31870.5 15302  6904 ultra (0 0.38 0.074 0 0.55)  
#     10) chl_small>=41297.5 5124   649 nano (0 0.87 0 0 0.13) *
#     11) chl_small< 41297.5 10178  2429 ultra (0 0.13 0.11 0 0.76) *
#  3) pe>=5004 9876   761 synecho (0.0057 0.053 0.0051 0.92 0.014)  
#    6) chl_small>=38333.5 641   135 nano (0.087 0.79 0 0.066 0.058) *
#    7) chl_small< 38333.5 9235   162 synecho (0 0.0014 0.0054 0.98 0.011) *
#pico, ultra, nano, synecho
#crypto

#Question 5
#Use print(model) to inspect your tree. Which populations, if any, is your tree incapable of recognizing? (Which populations do not appear on any branch?) (It's possible, but very unlikely, that an incorrect answer to this question is the result of improbable sampling.) Hint: Look

print(model)

#1) root 36171 25773 pico (0.0015 0.17 0.29 0.25 0.28)  
#  2) pe< 5004 26295 15947 pico (0 0.22 0.39 0 0.39)  
#    4) chl_small< 31870.5 10993  1770 pico (0 0.00018 0.84 0 0.16) *
#    5) chl_small>=31870.5 15302  6904 ultra (0 0.38 0.074 0 0.55)  
#     10) chl_small>=41297.5 5124   649 nano (0 0.87 0 0 0.13) *
#     11) chl_small< 41297.5 10178  2429 ultra (0 0.13 0.11 0 0.76) *
#  3) pe>=5004 9876   761 synecho (0.0057 0.053 0.0051 0.92 0.014)  
#    6) chl_small>=38333.5 641   135 nano (0.087 0.79 0 0.066 0.058) *
#    7) chl_small< 38333.5 9235   162 synecho (0 0.0014 0.0054 0.98 0.011) *
#pico, ultra, nano, synecho
#crypto


#Question 6
#Most trees will include a node near the root that applies a rule to the pe field, where particles with a value less than some threshold will descend down one branch, and particles with a value greater than some threshold will descend down a different branch. If you look at the plot you created previously, you can verify that the threshold used in the tree is evident visually. What is the value of the threshold on the pe field learned in your model?

#5004



#Question 7
#Based on your decision tree, which variables appear to be most important in predicting the class population?


#chl_small, pe


#Step 5: Evaluate the decision tree on the test data.
#Use the predict function to generate predictions on your test data. Then, compare these predictions with the class labels in the test data itself.

#predict(model)

prediction <- predict(model, newdata = testSet, type = "class")
accuracyOfPrediction <- ( sum(prediction == testSet$pop)/nrow(testSet) )


#In R, if you write A==B and A and B are vectors, the result is a vector of 1s and 0s. The sum of this vector will be the number of correct predictions. Dividing this sum by the size of the test dataset will give you the accuracy.

#Answer Question 8.

#Question 8
#How accurate was your decision tree on the test data? Enter a number between 0 and 1.
accuracyOfPrediction
#[1] 0.8573996





#Step 6: Build and evaluate a random forest.
#Load the randomForest library, then call randomForest using the formula object and the data, as you did to build a single tree:

#library(randomforest)
#model <- randomForest(fol, data=trainingdata)
#Evaluate this model on the test data the same way you did for the tree.

#Answer Question 9.

#Random forests can automatically generate an estimate of variable importance during training by permuting the values in a given variable and measuring the effect on classification. If scrambling the values has little effect on the model's ability to make predictions, then the variable must not be very important.

#A random forest can obtain another estimate of variable importance based on the Gini impurity that we discussed in the lecture. The function importance(model) prints the mean decrease in gini importance for each variable. The higher the number, the more the gini impurity score decreases by branching on this variable, indicating that the variable is more important.

#Call this function and answer Question 10.

install.packages("randomForest")
library(randomforest)
#model2 <- randomForest(fol, data=trainingSet)
model2 <- randomForest(pop~fsc_small + fsc_perp + fsc_big + pe + chl_big + chl_small, method = 'class', data = trainingSet)
#Question 9
#What was the accuracy of your random forest model on the test data? Enter a number between 0 and 1.


prediction2 <- predict(model2, newdata = testSet, type = "class")
accuracyOfPrediction2 <- ( sum(prediction2 == testSet$pop)/nrow(testSet) )

accuracyOfPrediction2
#[1] 0.9189129


#Question 10
#After calling importance(model), you should be able to determine which variables appear to be most important in terms of the gini impurity measure. Which ones are they?
#Note: http://en.wikipedia.org/wiki/Decision_tree_learning#Gini_impurity
importance(model2)
#          MeanDecreaseGini
#fsc_small        2730.9843
#fsc_perp         2089.8877
#fsc_big           197.4544
#pe               8933.9503
#chl_big          4828.3971
#chl_small        8068.7680


#pe chl_small



#Step 7: Train a support vector machine model and compare results.
#Use the e1071 library and call model <- svm(fol, data=trainingdata).
#Answer Question 11.
#Support Vector Machines:
model3 <- svm(pop~fsc_small + fsc_perp + fsc_big + pe + chl_big + chl_small, data=trainingSet)

#Question 11
#What was the accuracy of your support vector machine model on the test data? Enter a number between 0 and 1.




prediction3 <- predict(model3, newdata = testSet, type = "class")
accuracyOfPrediction3 <- ( sum(prediction3 == testSet$pop)/nrow(testSet) )

accuracyOfPrediction3
#[1] 0.9185535

#Question 12
#Construct a confusion matrix for each of the three methods using the table function. What appears to be the most common error the models make?

ConfusionTableDecisionTree <- table(prediction = prediction, RealData = testSet$pop)
ConfusionTableDecisionTree
#          RealData
#prediction crypto nano pico synecho ultra
#   crypto       0    0    0       0     0
#   nano        46 5081    1      33   717
#   pico         0    1 9301       2  1771
#   synecho      0   15   42    8996   112
#   ultra        0 1301 1117       0  7635
#Notes about decision tree:
	#Crypto not predicted at all, as already discussed
	#pico is heavily confused with 'ultra', and even more vice versa
	

ConfusionTableRandomForest <- table(prediction = prediction2, RealData = testSet$pop)
ConfusionTableRandomForest
#          RealData
#prediction crypto  nano  pico synecho ultra
#   crypto      44     2     0       0     0
#   nano         0  5593     0       3   351
#   pico         0     0 10092       0  1397
#   synecho      2     4     8    9028     6
#   ultra        0   799   361       0  8481
#Notes about Random Forest:
	#ultra with nano
	#ultra with pico

ConfusionTableSVM <- table(prediction = prediction3, RealData = testSet$pop)
ConfusionTableSVM
#          RealData
#prediction crypto  nano  pico synecho ultra
#   crypto      41     2     0       0     0
#   nano         1  5645     0       3   391
#   pico         0     0 10101      21  1404
#   synecho      4     3    66    9006     8
#   ultra        0   748   294       1  8432

#Notes about SVM:
	#pico with ultra
pico mistaken as being ultra

#Question 13
#The variables in the dataset were assumed to be continuous, but one of them takes on only a few discrete values, suggesting a problem. Which variable exhibits this problem?

length(unique(myData$fsc_big))
#[1] 6
length(unique(myData$fsc_small))
#[1] 13754
length(unique(myData$fsc_perp))
#[1] 12665
length(unique(myData$pe))
#[1] 9544
length(unique(myData$chl_small))
#[1] 15974
length(unique(myData$chl_big))
#[1] 2144

#fsc_big

#Question 14
#After removing data associated with file_id 208, what was the effect on the accuracy of your svm model? Enter a positive or negative number representing the net change in accuracy, where a positive number represents an improvement in accuracy and a negative number represents a decrease in accuracy.

newData <- subset(myData, myData$file_id != 208) 
set.seed(123456)

b <- sample(1:nrow(newData)) #creates a random sample
myData3 <- data.frame(b, newData)
head(myData3)
trainingSet2 <- myData3[myData3$b > ceiling(nrow(myData3)/2),]
testSet2 <- myData3[myData3$b < ceiling(nrow(myData3)/2),]


model4 <- svm(pop~fsc_small + fsc_perp + fsc_big + pe + chl_big + chl_small, data =trainingSet2)
prediction4 <- predict(model4, newdata = testSet2, type = "class")
sum(prediction4 == testSet2$pop)/nrow(testSet2)-( sum(prediction3 == testSet$pop)/nrow(testSet) )
#[1] 0.05387214