############################################
# Food Trends
#############################################

# data available from 9/20/2017 http://www.makeovermonday.co.uk/data/data-sets-2017/

library(RODBC) #connect to SQL Server
library(GGally) #ggpairs correlation
library(tidyverse)

# Creates connection with existing SQL Server
Local <- odbcConnect("Example", uid = "", pwd = "")

# Load data into R environment
Trend <- sqlQuery(Local, "SELECT * FROM FoodTrends.dbo.Trend")
Region <- sqlQuery(Local, "SELECT * FROM FoodTrends.dbo.Region")
Diet <- sqlQuery(Local, "SELECT * FROM FoodTrends.dbo.Diet")
Category <- sqlQuery(Local, "SELECT * FROM FoodTrends.dbo.Category")

FoodTrend <- Trend %>%
            left_join (Region, by = "RegionID") %>%
            left_join (Diet, by = "DietID") %>%
            left_join (Category, by = c("DietCategoryID" = "CategoryID"))

glimpse(FoodTrend)

#correlation
ggpairs(data = FoodTrend[,c('Followers', 'RegionID', 'DietCategoryID', 'DietID' )])

#Attempting to predict
fit <- lm(Followers~ RegionID + DietCategoryID + DietID , data = FoodTrend)
summary(fit)

fit2 <- lm(RegionID ~ Followers + DietCategoryID + DietID , data = FoodTrend)
summary(fit2)

fit3 <- lm(DietCategoryID ~ Followers + RegionID + DietID, data = FoodTrend)
summary(fit3)

fit4 <- lm(DietID ~ Followers + RegionID + DietCategoryID, data = FoodTrend)
summary(fit4)


#plotting with Religion removed
FoodTrend %>%
  filter(FoodTrend$CategoryName != "Religion") %>%
  ggplot(aes(Followers, DietName, color = RegionName)) +
  geom_point(alpha = 0.7)



#Close Connection
odbcCloseAll()

