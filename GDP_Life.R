library("rstudioapi")                                 # Load rstudioapi package
setwd(dirname(getActiveDocumentContext()$path))       # Set working directory to source file location

install.packages("tidyverse")
install.packages("dplyr")

library("tidyverse")
library("readxl")
library("dplyr") 

#### Load GDP ##### 
# from https://ourworldindata.org/grapher/average-real-gdp-per-capita-across-countries-and-regions?time=2016
GDP<-read_csv("GDP.csv",col_names = c("Country","Code","Year","PerCapita"), col_types = (cols(PerCapita = col_integer()) ),skip=1)
glimpse(GDP)

g<-filter(GDP, Year>1965)

g<-group_by(g,Country) %>%
  summarize(PerCapitaMean=mean(PerCapita,  na.rm = TRUE))

#####Load Life exp #####
#from https://en.wikipedia.org/wiki/List_of_countries_by_life_expectancy
life<-read_excel("Life.xlsx", col_names = c("Country","Age"),skip=1)
glimpse(life)

l<-mutate(life, Age = as.double(Age))
glimpse(l)


gl<-inner_join(g, l, by = "Country")
glimpse(gl)


ggplot(gl, aes(PerCapitaMean, Age)) +
  geom_point() +
  ggtitle("Gaph1: Correlation between GDP and Life Expectancy")

# Graph is not showing linear correlation => we will do log transformation 
gl<-mutate(gl, pc=log(PerCapitaMean), Age)

#for label of points
library(ggplot2)
install.packages("ggrepel")
library(ggrepel)

#this looks ,more like linear correlation 
ggplot(gl, aes(pc, Age)) +
  geom_point() +
  geom_smooth(method = "lm",se = FALSE)  +
  geom_smooth(method ="loess" ,se = FALSE, color = "red", span=0.50) +
  ggtitle("Gaph2: Correlation between log(PerCapita) and Life Expectancy") +
  labs(x = "log(PerCapita)", y="Age")+
  geom_label_repel(aes(label =ifelse(Age<55 | Age>83,as.character(Country),'')),box.padding= 0.35, point.padding = 0.5, segment.color = 'grey50') 


##### Splitting sample ######
set.seed(123)

#Chose random numbers from 1 to number of rows of gl
index <- sample(1:nrow(gl), round(nrow(gl) * 0.65)) 

train <- gl[index, ]
test  <- gl[-index, ]

mdl<-lm(Age ~ pc, data=train)
summary(mdl)

####Test model ####

#for prediction
install.packages("modelr")
library(modelr)

#add column with predictions
(test <- test %>% 
    add_predictions(mdl))


#compare MSE
(MSE_train<-train %>% 
  add_predictions(mdl) %>%
  summarise(MSE = mean((Age - pred)^2)))

(MSE_test<-test %>% 
    add_predictions(mdl) %>%
    summarise(MSE = mean((Age - pred)^2)))

####### Residuals vs fitted ####

#take residuals 
mdl.res = resid(mdl)

ggplot(train, aes(pc,mdl.res)) +
  geom_ref_line(h = 0) +
  geom_point() +
  geom_smooth(se = FALSE) +
  ggtitle("Graph 3: Residuals vs Fitted") +
  labs(x = "PerCapita", y="Residuals")


qqnorm(mdl.res,main="Graph 4: QQ plot of residuals",pch=19)
qqline(mdl.res)

shapiro.test(mdl.res)

install.packages("car")
library(car)
qqPlot(mdl.res,main="Graph 5: QQ plot of residuals")

mdl.res[51]
mdl.res[89]

#to see which Countries has most mistaken prediction
(train <- train %>% 
    add_predictions(mdl))

train<-mutate(train, res=Age-pred)

ggplot(train, aes(pc, Age)) +
  geom_point() +
  geom_smooth(method = "lm",se = FALSE)  +
  geom_smooth(method ="loess" ,se = FALSE, color = "red", span=0.50) +
  ggtitle("Gaph6: Correlation between log(PerCapita) and Life Expectancy") +
  labs(x = "log(PerCapita)", y="Age") +
  geom_label_repel(aes(label =ifelse(Age<60 | (Age<78 & pc>10),Country,'')),box.padding= 0.35, point.padding = 0.5, segment.color = 'grey50')
 

