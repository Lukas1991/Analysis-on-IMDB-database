#install.packages("rio")
#install.packages("base")
#install.packages("arules")
#install.packages("arulesViz")
library(grid)
library(lattice)
library(stats4)
library(modeltools)
library(rio)
library(NLP)
library(base)

library(flexclust)
library(fpc)
library(tm)
###################################
#load raw data and column names
norm_eucl<- function(m){
  m/apply(m, 1, function(x) sum(x^2)^.5)
}
set.seed(765)
options(header=FALSE, stringAsFactors=FALSE)
numericData <-  import("Final_clean.tsv",format="TSV")

plotData <- import("plot.tsv", format="TSV", header = FALSE)
colnames(numericData) <- c("id","title","year","length","budget","rating","votes","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","mpaa","Director","Writer","ProductionCompany","Language","Actors","Actress","Genre")
colnames(plotData) <- c("title", "plot")
data <- cbind(numericData, plotData$plot)

data$mpaa[nchar(data$mpaa) == 0] <- "G"
data <- data[sample(nrow(data),size=30000,replace=FALSE),]
genre.map <- c("Short" = 1, "Drama" = 1, "Comedy" = 1, "Romance" = 1, "Family" = 1, "Music" = 1, "Fantasy" = 2, "Sport" = 1, "Musical" = 1,
               "Thriller" = 2, "Horror" = 2, "Action" = 2, "Crime" = 2, "Adventure" = 2,"Sci-Fi" = 2, "Mystery" = 2, "Animation" = 2, "Western" = 2, "Film-Noir" = 2,
               "Documentary" = 3, "History" = 3, "Biography" = 3, "War" = 3, "News" = 3)
mpaa.map <- c("G" = 1,"PG" = 2, "PG-13" = 3, "NC-17" = 4, "R" = 5)
data$class <-genre.map[as.character(data$Genre)]
data$mpaa <-mpaa.map[as.character((data$mpaa))]
data.features <- data[,c("year","length", "rating","votes","mpaa","class","plotData$plot","Director","Writer","ProductionCompany","Language","Actors","Actress")]
data.features$year <- (data.features$year-min(data.features$year))/(max(data.features$year) - min(data.features$year)) * 0.01
data.features$length <- (data.features$length-min(data.features$length))/(max(data.features$length)-min(data.features$length)) * 0.01
data.features$votes <- (data.features$votes-min(data.features$votes))/(max(data.features$votes)-min(data.features$votes)) * 0.01
data.features$mpaa <- (data.features$mpaa-min(data.features$mpaa))/(max(data.features$mpaa)-min(data.features$mpaa)) * 0.01
data.features$rating <- (data.features$rating-min(data.features$mpaa))/(max(data.features$mpaa)-min(data.features$mpaa)) * 0.01

data.features <- na.omit(data.features)
textdata <- data.features[,c("class","plotData$plot")]

corpus <- Corpus(VectorSource(paste(data.features$Director, data.features$Writer,data.features$ProductionCompany,data.features$Actress,data.features$Actors)))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeWords, stopwords("english"))

dtm <- DocumentTermMatrix(corpus,control=list(bounds = list(global = c(5,Inf))))
rowTotals <- apply(dtm , 1, sum) 
data.features <- data.features[rowTotals > 0,]
textdata <- textdata[rowTotals > 0,]
dtm   <- dtm[rowTotals> 0, ]   
dtm.tfxidf <- weightTfIdf(dtm)


dtm.tfxidf$nrow <- as.numeric(dtm.tfxidf$nrow)
dtm.tfxidf$ncol <- as.numeric(dtm.tfxidf$ncol)
matrix <- as.matrix(dtm.tfxidf)


matrix.norm <- norm_eucl(matrix)
data.cluster <- data.features[,c("year","length", "rating","votes","mpaa")]
data.cluster <- cbind(data.cluster,matrix.norm)

corpus <- Corpus(VectorSource(paste(textdata$plot)))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeWords, stopwords("english"))

dtm <- DocumentTermMatrix(corpus,control=list(bounds = list(global = c(75,Inf))))
rowTotals <- apply(dtm , 1, sum) 
data.features <- data.features[rowTotals > 0,]
data.cluster <- data.cluster[rowTotals > 0,]

dtm   <- dtm[rowTotals> 0, ]   
dtm.tfxidf <- weightTfIdf(dtm)


dtm.tfxidf$nrow <- as.numeric(dtm.tfxidf$nrow)
dtm.tfxidf$ncol <- as.numeric(dtm.tfxidf$ncol)
matrix <- as.matrix(dtm.tfxidf)

matrix.norm <- norm_eucl(matrix)


data.cluster <- cbind(data.cluster,matrix.norm)

kmCluster <- kcca(data.cluster, k = 3, family=kccaFamily("kmeans"))

predictionKM<- predict(kmCluster, data.cluster)
confusion <- table(predictionKM,data.features$class)
print(summary(kmCluster))
print(confusion)
