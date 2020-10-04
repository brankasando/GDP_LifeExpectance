# Correlation between GDP of country and life expectancy

This project is done in RStudio.
Goal of this project is to determine whether there is a correlation between Per Capita of countries and life expectancy and if that correlation is linear. 

---------------------------------------------------------
#####Load GDP #####
   We have loaded data and changed type of column “PerCapita”
   Filter by year since we don’t have data for some countries before 1965
   We obtain 1 line per country and average of “PerCapita” of years

#####Load Life expectancy #####
   We have loaded data and changed type of column “Age”
---------------------------------------------------------

 -We joined tables by column “Country”
 -Graph 1: We can see that relationship have curve shape rather than linear line. 

=>We do log transformation of response variable “PerCapita”

-Graph 2: We can see that relationship looks more linear now. 
 Blue line represents linear regression. 
 Red curve represents “locally weighted” regression. 
 This means we will calculate a different value (of Y-axis) for each value of X-axis, which depends on the points “nearby”, as opposed to a standard linear regression model which uses all points all the time.  
 In R “smoothing parameter” says how many of the neighbors will used - by setting a span.
 
 
##### Splitting sample ######

 -Now, we want to create linear model and to test its accuracy by splitting sample into to 2:
Train data – based on which we will create model
Test data  – test the model 

 -We created linear model using function lm and summary of model is:

---------------------------------------------------------
(Intercept)  20.8333     3.9599   5.261 8.43e-07 ***
pc            5.8789     0.4505  13.051  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 4.978 on 98 degrees of freedom
Multiple R-squared:  0.6348,	Adjusted R-squared:  0.631 
F-statistic: 170.3 on 1 and 98 DF,  p-value: < 2.2e-16
---------------------------------------------------------

=>We can see that there is a positive correlation between GDP and life expectancy.
Linear regression can be written: 
Life Expectancy=20.83 + 5.88*PerCapita

-However Multiple R-squared is 0.6348, which means that 63% of data can be explained by the model. 

####Test model ####

Let’s now test how good our model will predict data from test data.
We will compare MSE from train data based on which we build model and test data.

MSE_train=24.3
MSE_test=15.3

It’s expected that MSE_train is lower, but here is not the case. 
This can imply that model is not good and that is easy to get better result in test data, just by chance.
It can imply that test set is small, or in general that there is not enough data.

####### Residuals vs fitted ####

Linear model yi=bi +axi + εi, 
should fulfill following for ε : 
1.	iid, don’t depend on X
2.	E(εi)=0
3.	D(εi)=ϭ2<∞ 
4.	εi  ~ N(0, ϭ2)

-Graph 3: Plot residuals vs fitted values. We can see that residuals (errors) are not equaly distributed depending on predicted values. 
-Graph 4: Plot residuals depending on theoretical quantiles of normal distribution.

-Finaly Shapiro test is showing that residuals does not have normal distribution.

-Graph 5: We can see index of residuals which are 'spoiling' normal distribution.
We can see that Equatorial Guinea and Nigeria don't have that low PerCapita, but do have life expectancy under 60.
Also, we can see that Kuwait, Lybia, Saudi Arabia and United Arab Emirates have high GDP, but not that high life expectancy as other countries with similar PerCapita.

#### Conclusion ####

PerCapita do have an impact on life expectancy, but it's not good to describe that relationship as linear. 

We can see that some countries from Arabian peninsula have high PerCapita, but not that high life expectancy. 
Oil was founded in 1938 in Arabic peninsula which brough wealth, but maybe health awareness of people didn't change that much since than. 

To explain better life expectancy it would be good to include other explanatory variables, such as quality of healthcare system, healthy habits, etc.