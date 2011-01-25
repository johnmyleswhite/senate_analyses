library('ProjectTemplate')
load.project()

source('first_pass.R')
#ideal.points <- read.csv('cache/ideal_points.csv')

estimated.g <- apply(j.samples$g, 1, mean)

comparisons <- data.frame(Gamma = estimated.g, YeaTotal = bills$yeatotal)

save(comparisons, file = 'comparisons.RData')

ggplot(comparisons, aes(x = Gamma, y = YeaTotal)) + geom_point() + geom_smooth()

comparisons <- transform(comparisons, Disagreement = abs(YeaTotal - 50))

ggplot(comparisons, aes(x = Gamma, y = Disagreement)) + geom_point() + geom_smooth()
