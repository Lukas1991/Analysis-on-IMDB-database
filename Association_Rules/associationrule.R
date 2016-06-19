install.packages("rio")
install.packages("base")
install.packages("arules")
install.packages("arulesViz")
library(rio)
library(base)
library(arules)
library(arulesViz)

###################################
#load raw data and column names
data <-  import("Final.tsv",format="TSV")
colnames(data) <- c("id","title","year","length","budget","rating","votes","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","mpaa","Director","Writer","ProductionCompany","Language","Actors","Actress","Genre")

# extract specific columns from data
newdata <- data[,c("Director","Writer","ProductionCompany","Actors","Actress")]

#remove NA rows
newdata <- na.omit(newdata)


for (i in 1:5){
newdata[,i]<-as.factor(newdata[,i])
}

###################################
#statistics of the data
#Director
Directortable  <- as.data.frame(table(newdata$Director))
Directortable <- Directortable[order(Directortable$Freq, decreasing = TRUE), ] 

#Writer
Writertable  <- as.data.frame(table(newdata$Writer))
Writertable  <- Writertable[order(Writertable$Freq, decreasing = TRUE), ]

#ProductionCompany
ProductionCompanytable  <- as.data.frame(table(newdata$ProductionCompany))
ProductionCompanytable  <- ProductionCompanytable[order(ProductionCompanytable$Freq, decreasing = TRUE), ]

#Actor
ActorsTable  <- as.data.frame(table(newdata$Actors))
ActorsTable  <- ActorsTable[order(ActorsTable$Freq, decreasing = TRUE), ]

#Actress
ActressTable  <- as.data.frame(table(newdata$Actress))
ActressTable  <- ActressTable[order(ActressTable$Freq, decreasing = TRUE), ]

####################################
#get raw rules which contains at least 4 people.
betterRules1 <- apriori(newdata,parameter=list(minlen=4,support=0.00017, confidence=0.8))
inspect(betterRules1)


# find redundant rules
subset.matrix <- is.subset(betterRules1, betterRules1)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1


# remove redundant rules
rules.pruned1 <- betterRules1[!redundant]
inspect(rules.pruned1)

#sort the remaining rules
sortedrule1 <- sort(rules.pruned1, by="lift")
inspect(sortedrule1)

# Find the rule that has ProductionCompany in the right hand side
rules.sub1 <- subset(sortedrule1, subset =   rhs %pin% "ProductionCompany")
inspect(rules.sub1)


#######################################
#Visualizing Association Rules
plot(sortedrule1)

plot(sortedrule1, method="graph")

#######################################
#Provide some rules which indicate the realtion between genre and cast

newdatawithgenre <- data[,c("Director","Writer","ProductionCompany","Actors","Actress","Genre")]

newdatawithgenre <- na.omit(newdatawithgenre)

for (i in 1:6){
  newdatawithgenre[,i]<-as.factor(newdatawithgenre[,i])
}


#Genre with case relation
GenreTable  <- as.data.frame(table(newdatawithgenre$Genre))
GenreTable  <- GenreTable[order(GenreTable$Freq, decreasing = TRUE), ]


betterRules2 <- apriori(newdatawithgenre,parameter=list(support=0.0005, confidence=0.7))
inspect(betterRules2)

# find redundant rules
subset.matrix <- is.subset(betterRules2, betterRules2)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1

# remove redundant rules
rules.pruned2 <- betterRules2[!redundant]
inspect(rules.pruned2)

#sort the remaining rules
sortedrule2 <- sort(rules.pruned2, by="lift")
inspect(sortedrule2)

#######################################
#Find the rules indicate relation between genre and cast
# Find the rule that has Genre in the right hand side
rules.sub2 <- subset(sortedrule2, subset =   rhs %pin% "Genre")
inspect(rules.sub2)


detach("package:rio",unload=TRUE)
detach("package:arulesViz",unload=TRUE)
detach("package:arules",unload=TRUE)


