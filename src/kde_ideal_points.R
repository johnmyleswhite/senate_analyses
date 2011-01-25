library('ProjectTemplate')
load.project()

senator.ideal.points.111 <- transform(senator.ideal.points.111, Party = determine.party(Senator))

pdf(file.path('graphs', 'ideal_point_distribution.pdf'))
print(ggplot(senator.ideal.points.111, aes(x = IdealPoint, fill = Party)) +
  geom_density() +
  xlab('Ideal Point') + 
  ylab('Estimated Density') +
  opts(title = 'Estimated Distribution of Ideal Points by Party'))
dev.off()
