install.packages("tidyverse")
install.packages("rio")
install.packages("dplyr")

library("tidyverse")
library("rio")
library("readxl")
library("dplyr")

nobelPrize<-read_csv("NobelWinners.csv",col_names = c("Country","Prize_NB"),skip=1)

glimpse(nobelPrize)

#[Note x] - means that same person got reword more than 1 -> in bracket is the real number 


np<-mutate(nobelPrize
                    ,Prize_NB= 
                      case_when (str_detect(Prize_NB,"Note") ~  gsub(".*\\(","",gsub("\\).*","",Prize_NB))
                                 ,
                                 TRUE ~ Prize_NB))

np<-mutate(np, Prize_NB=as.integer(Prize_NB))
glimpse(np)


GDP<-read.csv("GDP.csv",col.names = c("Country","Code","Year","PerCapita"))
glimpse(GDP)

g<-mutate(GDP, Year= as.integer(Year))


g<-filter(GDP, Year>1965)

g<-group_by(GDP,Country) %>%
  summarize(PerCapitaMean=mean(PerCapita,na.rm = TRUE))
g

GDP_NOBEL<-inner_join(g, np, by = "Country", copy = FALSE, suffix = c(".g", ".nb"))

GDP_NOBEL<-mutate(GDP_NOBEL, Prize_NB= as.integer(Prize_NB))
glimpse(GDP_NOBEL)

b<-lm(Prize_NB  ~ PerCapitaMean,GDP_NOBEL)

summary(b)
plot(GDP_NOBEL$PerCapitaMean, GDP_NOBEL$Prize_NB)

boxplot(GDP_NOBEL$Prize_NB)
hist(GDP_NOBEL$Prize_NB)

############## life exp #####
options(digits = 4)
Life<-read_excel("Life.xlsx", col_names = c("Country","Age"),skip=1,trim_ws = FALSE)

l<-mutate(Life, Age = as.double(Age), Country=trimws(Country, which = c("both")))

glimpse(l)


gl<-inner_join(g, l, by = "Country", copy = FALSE, suffix = c(".g", ".l"))

glimpse(gl)

plot(gl)

gl<-mutate(gl, pc=log(PerCapitaMean))

b1<-lm(gl$Age ~ gl$pc)
summary(b)


ggplot(gl,aes(x = pc)) + 
  geom_density(alpha = 0.5)


ggplot(gl,aes(x = Age)) + 
  geom_density(alpha = 0.5)

#normality test

qqnorm(gl$Age,main="QQ plot of normal data",pch=19)
qqline(gl$Age)
shapiro.test(log(gl$Age))

qqnorm(gl$pc,main="QQ plot of normal data",pch=19)
qqline(gl$pc)
shapiro.test(gl$pc)


##### splitting sample ######

set.seed(188)
index   <- sample(1:nrow(gl), round(nrow(gl) * 0.65))
index

train_1 <- gl[index, ]
test_1  <- gl[-index, ]

ggplot(train_1, aes(pc, Age)) +
  geom_point() +
  geom_smooth(method = "lm") +
  geom_smooth(se = FALSE, color = "red")

ggplot(d,aes(x = pc)) + 
  geom_density(adjust=1.5, alpha=0.4) 

boxplot(train_1$pc)

help(geom_smooth)
#+  theme_ipsum()


ggplot(train_1, aes(x = pc)) + 
  geom_density(trim = TRUE,col="red") + 
  geom_density(data = test_1, trim = TRUE,col="black") 

#predict model

install.packages("modelr")
library(modelr)

b1<-lm(train_1$Age ~ train_1$pc)
summary(b1)

(test_2 <- test_1 %>% 
  add_predictions(b))

test_2


   


new <- data.frame(pc = test_1$pc)
x<-predict(b1, newdata = new)

y<-as.tibble(x)

test_1 <- mutate(test_1,pr = y) 

#compare mse

test_1 %>% 
  add_predictions(b) %>%
  summarise(MSE = mean((pred - pc)^2))

test_1
