library('ProjectTemplate')
load.project()

congresses <- seq(97, 111, by = 1)

ideal.points <- data.frame()

for (congress in congresses)
{
  file.name <- file.path('cache', paste('senator_ideal_points_', congress, '.csv', sep = ''))
  current.ideal.points <- read.csv(file.name, header = TRUE, sep = ',')
  ideal.points <- rbind(ideal.points, cbind(current.ideal.points, Congress = congress))
}

ideal.points <- transform(ideal.points, Party = with(ideal.points, sapply(Senator, determine.party)))

# Drop the independent candidates
ideal.points <- subset(ideal.points, Party %in% c('D', 'R'))

# Don't use the default colors!
ggplot(ideal.points, aes(x = Congress, y = IdealPoint, group = Party, color = Party)) +
  geom_point(aes(alpha = 1))

ggplot(ideal.points, aes(x = Congress, y = IdealPoint, group = Party, color = Party)) +
  geom_point(aes(alpha = 0.5))

ggplot(ideal.points, aes(x = Congress, y = IdealPoint, group = Party, color = Party)) +
  stat_summary(fun.data = 'mean_cl_boot', geom = 'errorbar')

ggplot(ideal.points, aes(x = Congress, y = IdealPoint, group = Party, color = Party)) +
  stat_summary(fun.data = 'median_hilow', geom = 'point')

ggplot(ideal.points, aes(x = Congress, y = IdealPoint, group = Party, color = Party)) +
  stat_summary(fun.data = 'median_hilow', geom = 'errorbar')

ggplot(ideal.points, aes(x = Congress, y = IdealPoint, group = Party, color = Party)) +
  geom_smooth()

ggplot(ideal.points, aes(x = Congress, y = IdealPoint, group = Party, color = Party)) +
  geom_smooth(fill = 1) +
  geom_point(aes(alpha = 0.25))
