# Pull in libraries
library(dplyr)
library(cvTools)
library(ggplot2)

# Turn off scientific notation
options(scipen = 999)

# load in data
df = read.csv("~/Documents/Code/ML/deepmed/modeling/finalmodelsheet.csv")

factors = c(26,27,28,29,30)
df[,factors] = lapply(df[,factors], factor)

# Set seed and split up dataset
set.seed(123)
train.ind = sample(1:nrow(df), 0.80*nrow(df))
train.df = df[train.ind,]
test.df = df[-train.ind,]

validation.ind = sample(1:nrow(train.df), 0.20 * nrow(train.df))
validation.df = train.df[validation.ind,]
train.df = train.df[-validation.ind,]

plot(train.df$rand.risk, train.df$score)
cor(train.df$rand.risk, train.df$score)

##################################################################################################################
# BASELINE MODELS
##################################################################################################################

# Baseline Regression Model
baseline_mdl_mean = lm(formula = score ~ 1 + pval.2 + SMOG, data = train.df)
baseline_mdl_mean_cv = cvFit(baseline_mdl_mean, data = train.df, y = train.df$score, K = 10)
baseline_mdl_mean_cv$cv^2 # MSE = 0.001904314

# Using the validation set to double check the above MSE calculation
prediction_mdl_mean = predict(baseline_mdl_mean, validation.df)
error_mdl_mean = prediction_mdl_mean - validation.df$golden
mean(error_mdl_mean^2) # MSE = 0.001896857

# Baseline Classification Model
baseline_mdl_del = lm(formula = pval.1 ~ 1, data = train.df)
mean(validation.df$pval.1) # 0.2081432


##################################################################################################################
# MODELS ON FEW COVARIATES
##################################################################################################################

# Linear Regression On Relevant Covariates
regression_mdl_few_covariates = lm(formula = score ~ 1 + pval.2 + Multicenter.Study + n.1 + n.2 + n.3 + SMOG, data = train.df)
prediction_mdl_few_covariates = predict(regression_mdl_few_covariates, validation.df)
MSE_mdl_few_covariates = mean((prediction_mdl_few_covariates - validation.df$score)^2)


# classification - not done here right now
class_mdl_few_covariates = glm(formula = score ~ 1 + pval.2 + Multicenter.Study + n.1 + n.2 + n.3 + SMOG, data = train.df, family = "binomial")
prediction_class_mdl_covariates = predict(class_mdl_few_covariates, validation.df)
prediction_class_mdl_covariates[prediction_class_mdl_covariates > 0.5] = TRUE
prediction_class_mdl_covariates[prediction_class_mdl_covariates <= 0.5] = FALSE
foo = (prediction_class_mdl_covariates - validation.df$golden)
bar = foo[foo != 0]
misclassification_error_few_covariates = length(bar) / nrow(validation.df)


