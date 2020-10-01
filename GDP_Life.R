install.packages("tidyverse")
#install.packages("rio")
#install.packages("dplyr")

library("tidyverse")
#library("rio")
library("readxl")
#library("dplyr") 

#### Load GDP ##### 
GDP<-read_csv("GDP.csv",col_names = c("Country","Code","Year","PerCapita"), col_types = (cols(PerCapita = col_integer()) ),skip=1)
glimpse(GDP)

g<-filter(GDP, Year>1965)

g<-group_by(g,Country) %>%
  summarize(PerCapitaMean=mean(PerCapita,  na.rm = TRUE))

#####Load Life exp #####

life<-read_excel("Life.xlsx", col_names = c("Country","Age"),skip=1)
glimpse(life)

l<-mutate(Life, Age = as.double(Age), Country=trimws(Country, which = c("both")))
glimpse(l)


gl<-inner_join(g, l, by = "Country")
glimpse(gl)


ggplot(gl, aes(PerCapitaMean, Age)) +
  geom_point() 

# Graph is not showing linear correlation => we will do log transformation 
gl<-mutate(gl, pc=log(PerCapitaMean), Age)

#this looks like linear correlation 
ggplot(gl, aes(pc, Age)) +
  geom_point() +
  geom_smooth(method = "lm",se = FALSE) +
  geom_smooth(se = FALSE, color = "red")


##### Splitting sample ######
set.seed(123)

#Chose random numbers from 1 to number of rows of gl
index <- sample(1:nrow(gl), round(nrow(gl) * 0.65)) 

train <- gl[index, ]
test  <- gl[-index, ]

#compare linear line with train data
ggplot(train, aes(pc, Age)) +
  geom_point() +
  geom_smooth(method = "lm") +
  geom_smooth(se = FALSE, color = "red")

#compare density graph for test and train data
ggplot(train, aes(x = pc)) + 
  geom_density(trim = TRUE,col="red") + 
  geom_density(data = test, trim = TRUE,col="black") 

####Predict model ####

#for prediction
install.packages("modelr")
library(modelr)

mdl<-lm(Age ~ pc, data=train)
summary(mdl)


#add column with predictions
(test <- test %>% 
    add_predictions(mdl))

#for label of points
library(ggplot2)
library(ggrepel)

#compare linear line with data
ggplot(test, aes(pc, Age, label=Country)) +
  geom_point()+
  geom_smooth(method = "lm") +
  geom_smooth(se = FALSE, color = "red") + 
  geom_label_repel(aes(label =ifelse(Age<62,as.character(Country),'')),box.padding= 0.35, point.padding = 0.5, segment.color = 'grey50') 


#compare MSE

test %>% 
  add_predictions(mdl) %>%
  summarise(MSE = mean((Age - pred)^2))

train %>% 
  add_predictions(mdl) %>%
  summarise(MSE = mean((Age - pred)^2))


####### Residuals vs fitted ####

#take residuals 
mdl.res = resid(mdl)

ggplot(train, aes(pc,mdl.res)) +
  geom_ref_line(h = 0) +
  geom_point() +
  geom_smooth(se = FALSE) +
  ggtitle("Residuals vs Fitted") +
  labs(x = "PerCapita", y="Residuals")


qqnorm(mdl.res,main="QQ plot of residuals",pch=19)
qqline(mdl.res)


install.packages("ggpubr")
library(ggpubr)
ggqqplot(mdl.res)


shapiro.test(mdl.res)