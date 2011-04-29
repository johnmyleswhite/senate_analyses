library('ProjectTemplate')
load.project()

library('tm')
library('topicmodels')
library('glmnet')

senators <- subset(senators, Congress == 111)
senators <- merge(senator.ideal.points.111, senators, by.x = 'Senator', by.y = 'Senator')

authors <- merge(authors, full.names, by.x = 'Author', by.y = 'FullName', all.x = TRUE)
authors <- merge(authors, senators, by.x = 'Senator', by.y = 'Senator', all.x = TRUE)

authors <- authors[!is.na(authors$Senator), ]
y <- authors$IdealPoint

# Match documents properly.
documents.order <- authors$DocumentID
documents <- transform(documents, Text = as.character(Text))
documents <- documents[documents.order, ]
row.names(documents) <- 1:nrow(documents)

# Build up corpus and clean it.
corpus <- Corpus(DataframeSource(documents))
corpus <- tm_map(corpus, tolower)
corpus <- tm_map(corpus, removeWords, stopwords('english'))

# Also remove all of the senator's names.
names <- tolower(strsplit(paste(as.character(full.names$FullName), collapse = ' '), ' ')[[1]])
corpus <- tm_map(corpus, removeWords, names)

# Build up terms matrix.
document.term.matrix <- DocumentTermMatrix(corpus)
dtm <- document.term.matrix
x <- as.matrix(document.term.matrix)

# Random split into training and test.
training.size <- round(length(y) * (2 / 3))
test.size <- round(length(y) * (1 / 3))

# We want the same splits every time.
set.seed(1234)

training.indices <- sample(1:length(y), training.size)
test.indices <- (1:length(y))[! (1:length(y) %in% training.indices)]

training.x <- x[training.indices, ]
training.y <- y[training.indices]
test.x <- x[test.indices, ]
test.y <- y[test.indices]

# Need to use cross-validation here to set lambda.
lambdas <- c(1, 0.5, 0.25, 0.1, 0.05, 0.01, 0.005, 0.001)
performance <- data.frame()

for (lambda in lambdas)
{
  for (iteration in 1:25)
  {
    # Use 80% of data during each cross-validation run.
    split.indices <- sample(1:length(training.y), 750)
    remaining.indices <- (1:length(training.y))[! (1:length(training.y) %in% split.indices)]
    
    
    split.x <- training.x[split.indices, ]
    split.y <- training.y[split.indices]
    remaining.x <- training.x[remaining.indices, ]
    remaining.y <- training.y[remaining.indices]
    
    fit <- glmnet(split.x, split.y)
    predicted.y <- predict(fit, newx = remaining.x, s = lambda)
    predicted.y <- as.numeric(predicted.y[,1])
    rmse <- sqrt(mean((remaining.y - predicted.y) ^ 2))
    
    performance <- rbind(performance,
                         data.frame(Lambda = lambda, Iteration = iteration, RMSE = rmse))
  }
}

pdf(file.path('graphs', 'lambda_rmse_without_names.pdf'))
empty <- plyr::empty
print(ggplot(performance, aes(x = Lambda, y = RMSE)) +
  stat_summary(fun.data = 'mean_cl_boot', geom = 'errorbar') +
  scale_x_log10() +
  xlab('Lambda') +
  ylab('Cross-Validated RMSE') +
  opts(title = 'Lasso Hyperparameter Tuning (No Names Corpus)'))
rm(empty)
dev.off()

# Find optimal lambda.
mean.rmse <- ddply(performance, 'Lambda', mean)
optimal.lambda <- with(subset(mean.rmse, RMSE == with(mean.rmse, min(RMSE))), Lambda)

# Refit model to whole training set.
fit <- glmnet(training.x, training.y)

# Test predictions on held out data using optimal lambda.
predicted.y <- predict(fit, newx = test.x, s = optimal.lambda)
predicted.y <- as.numeric(predicted.y[,1])
predictions <- data.frame(Predicted = predicted.y, Empirical = test.y, Residual = predicted.y - test.y)
pdf(file.path('graphs', 'ideal_point_predictions_without_names.pdf'))
empty <- plyr::empty
print(ggplot(predictions, aes(x = Predicted, y = Empirical)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE) +
  xlab('Document\'s Predicted Ideal Point') +
  ylab('Document\'s True Ideal Point') +
  opts(title = 'True vs. Predicted Ideal Points (No Names Corpus)'))
rm(empty)
dev.off()
pdf(file.path('graphs', 'ideal_point_residuals_without_names.pdf'))
empty <- plyr::empty
print(ggplot(predictions, aes(x = Predicted, y = Residual)) +
  geom_point() +
  xlab('Document\'s Predicted Ideal Point') +
  ylab('Document\'s Residual') +
  opts(title = 'Predicted Ideal Points vs. Residuals (No Names Corpus)'))
rm(empty)
dev.off()

# Assess quality using R^2 and RMSE.
r.squared <- data.frame()

for (lambda in lambdas)
{
  predicted.y <- predict(fit, newx = test.x, s = lambda)
  predicted.y <- as.numeric(predicted.y[,1])
  predictions <- data.frame(Predicted = predicted.y, Empirical = test.y, Residual = test.y - predicted.y)
  
  r.squared <- rbind(r.squared,
                     data.frame(Lambda = lambda,
                                RMSE = sqrt(mean(with(predictions, Residual) ^ 2)),
                                RSquared = summary(lm(Empirical ~ Predicted, data = predictions))$r.squared))
}
pdf(file.path('graphs', 'test_set_performance_without_names.pdf'))
empty <- plyr::empty
print(ggplot(r.squared, aes(x = Lambda, y = RMSE)) +
  scale_x_log10() +
  geom_point() +
  xlab('Lasso Lambda') +
  ylab('RMSE') +
  opts(title = 'Model Performance on Test Set'))
rm(empty)
dev.off()

# Extract coefficients at a single value of lambda
term.weights <- coef(fit, s = optimal.lambda)
biased.terms <- names(term.weights[,1][abs(term.weights[,1]) > 0])
print(biased.terms)

# Print out most Republican and most Democratic terms.
sorted.terms <- sort(term.weights[,1])
most.democratic.terms <- sorted.terms[1:50]
write.csv(data.frame(Term = names(most.democratic.terms),
                     Value = as.numeric(most.democratic.terms)),
          file.path('cache', 'most_democratic_terms_without_names.csv'),
          row.names = FALSE)
most.republican.terms <- sorted.terms[(length(sorted.terms) - 50):length(sorted.terms)]
write.csv(data.frame(Term = names(most.republican.terms),
                     Value = as.numeric(most.republican.terms)),
          file.path('cache', 'most_republican_terms_without_names.csv'),
          row.names = FALSE)
