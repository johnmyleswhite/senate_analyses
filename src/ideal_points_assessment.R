library('ProjectTemplate')
load.project()

merged.data <- merge(senator.ideal.points.111, jackman.ideal.points, by.x = 'Senator', by.y = 'X')

pdf(file.path('graphs', 'comparison_with_jackman.pdf'))
print(ggplot(merged.data, aes(x = IdealPoint, y = Mean)) +
  geom_point() +
  xlab('Estimated Ideal Point') +
  ylab('Jackman\'s Published Ideal Point') +
  opts(title = 'Estimated Ideal Points vs. Jackman\'s Ideal Points'))
dev.off()

with(merged.data, cor.test(IdealPoint, Mean))
