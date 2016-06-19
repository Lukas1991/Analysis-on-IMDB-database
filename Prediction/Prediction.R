library(partykit)
library(caret)
library(RWeka)
library(e1071)
library(class)


datasetParititionIndex <- function (dataframe) {
  set.seed(6626)
  index <- 1 : nrow(dataframe)
  trainindex <- sample(index, trunc(0.8 * length(index)))
  trainindex
}

#create the raw dataset
df <- read.csv(file = "raw5.data",quote="", header = T, sep = "\t")
randomIndex  <- datasetParititionIndex(df)

#baseline
df <- read.csv(file = "baseline.data",quote="", header = T, sep = "\t")
randomIndex  <- datasetParititionIndex(df)
baselinedf <- df[,c('year', 'length', 'rating', 'votes', 'Genra')]
baselineTrain <- baselinedf[randomIndex,]
baselineTest <- baselinedf[-randomIndex,]
c45Fit <- J48(Genra~., data = baselineTrain)
c45Prediction <- predict(c45Fit, baselineTest[,1:4])
confusionMatrix(c45Prediction, baselineTest$Genra)

bayesFit <- naiveBayes(baselineTrain[, 1:4], baselineTrain[,5])
bayesPredict <- predict(bayesFit, baselineTest[, 1:5])
confusionMatrix(bayesPredict, baselineTest$Genra)

remove(baselinedf)
remove(baselineTest)
remove(baselineTrain)

#binning
binningdf <- baselinedf
for (i in 1 : nrow(binningdf)) {
  #binning the year
  if (binningdf[i, 1] < 1954) { binningdf[i,1] <- 0 } 
  else if (binningdf[i, 1] < 1984) { binningdf[i, 1] <- 1 } 
  else if (binningdf[i, 1] < 1997) { binningdf[i, 1] <- 2} 
  else { binningdf[i, 1] <- 3}
  
  #binning the Ratings
  if (binningdf[i, 3] < 2.5) { binningdf[i, 3] <- 0}
  else if (binningdf[i, 3] < 5.0) { binningdf[i, 3] <- 1}
  else if (binningdf[i, 3] < 7.5) { binningdf[i, 3] <- 2}
  else { binningdf[i, 3] <- 4}
  
  #binning votes
  if (binningdf[i, 4] < 16) { binningdf[i, 4] <- 0}
  else if (binningdf[i, 4] < 46) { binningdf[i, 4] <- 1}
  else if (binningdf[i, 4] < 206) { binningdf[i, 4] <- 2}
  else { binningdf[i, 4] <- 3 }
}

train <- binningdf[randomIndex, ]
test <- binningdf[-randomIndex, ]

c45Fit <- J48(Genra~., data = train)
c45Prediction <- predict(c45Fit, test[,1:4])
confusionMatrix(c45Prediction, test$Genra)

bayesFit <- naiveBayes(train[, 1:4], train[,5])
bayesPredict <- predict(bayesFit, test[, 1:5])
confusionMatrix(bayesPredict, test$Genra)

#binning the whole dataset
binningdf <- df
remove(df)
for (i in 1 : nrow(binningdf)) {
  #binning the year
  if (binningdf[i, 2] < 1954) { binningdf[i,2] <- 0 } 
  else if (binningdf[i, 2] < 1984) { binningdf[i, 2] <- 1 } 
  else if (binningdf[i, 2] < 1997) { binningdf[i, 2] <- 2} 
  else { binningdf[i, 2] <- 3}
  
  #binning the Ratings
  if (binningdf[i, 5] < 2.5) { binningdf[i, 5] <- 0}
  else if (binningdf[i, 5] < 5.0) { binningdf[i, 5] <- 1}
  else if (binningdf[i, 5] < 7.5) { binningdf[i, 5] <- 2}
  else { binningdf[i, 5] <- 4}
  
  #binning votes
  if (binningdf[i, 6] < 16) { binningdf[i, 6] <- 0}
  else if (binningdf[i, 6] < 46) { binningdf[i, 6] <- 1}
  else if (binningdf[i, 6] < 206) { binningdf[i, 6] <- 2}
  else { binningdf[i, 6] <- 3 }
}


###########################
# categorical data
###########################

#load data
df <- read.csv(file = "train_test.data",quote="", header = T, sep = "\t")
#load the index
randomIndex <- scan("randomIndex", what = integer(0))
traindf <- df[randomIndex, ]
testdf <- df[-randomIndex, ]

#director
train <- traindf[,c('year', 'length', 'rating', 'votes', 'Director', 'Genra')]
test <- testdf[,c('year', 'length', 'rating', 'votes', 'Director', 'Genra')]

c45Fit <- J48(Genra~., data = train)
c45Prediction <- predict(c45Fit, test[,1:5])
confusionMatrix(c45Prediction, test$Genra)

bayesFit <- naiveBayes(train[, 1:5], train[,6])
bayesPredict <- predict(bayesFit, test[, 1:5])
confusionMatrix(bayesPredict, test$Genra)

#produce company
train <- traindf[,c('year', 'length', 'rating', 'votes', 'Director', 'ProdctionCompany', 'Genra')]
test <- testdf[,c('year', 'length', 'rating', 'votes', 'Director', 'ProdctionCompany', 'Genra')]

c45Fit <- J48(Genra~., data = train)
c45Prediction <- predict(c45Fit, test[,1:6])
confusionMatrix(c45Prediction, test$Genra)

bayesFit <- naiveBayes(train[, 1:6], train[,7])
bayesPredict <- predict(bayesFit, test[, 1:6])
confusionMatrix(bayesPredict, test$Genra)


#Actor and actress
train <- traindf[,c('year', 'length', 'rating', 'votes', 'Director', 'ProdctionCompany', 'person', 'Genra')]
test <- testdf[,c('year', 'length', 'rating', 'votes', 'Director', 'ProdctionCompany', 'person', 'Genra')]
#directly use the statistical feature
confusionMatrix(test$person, test$Genra)

#with other features
c45Fit <- J48(Genra~., data = train)
c45Prediction <- predict(c45Fit, test[,1:7])
confusionMatrix(c45Prediction, test$Genra)

bayesFit <- naiveBayes(train[, 1:7], train[,8])
bayesPredict <- predict(bayesFit, test[, 1:7])
confusionMatrix(bayesPredict, test$Genra)

#plot analysis
plotdf <- read.csv(file = "train_test_keywords.data",quote="", header = T, sep = "\t")
traindf <- plotdf[randomIndex, ]
testdf <- plotdf[-randomIndex, ]
train <- traindf[,c('year', 'length', 'rating', 'votes', 'Director', 'ProdctionCompany', 'person', 'keywords', 'Genra')]
test <- testdf[,c('year', 'length', 'rating', 'votes', 'Director', 'ProdctionCompany', 'person', 'keywords', 'Genra')]
confusionMatrix(test$keywords, test$Genra)

c45Fit <- J48(Genra~., data = train)
c45Prediction <- predict(c45Fit, test[,1:8])
confusionMatrix(c45Prediction, test$Genra)

bayesFit <- naiveBayes(train[, 1:7], train[,8])
bayesPredict <- predict(bayesFit, test[, 1:7])
confusionMatrix(bayesPredict, test$Genra)


