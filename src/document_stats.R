library('ProjectTemplate')
load.project()

document.stats <- ddply(authors, 'Author', nrow)

names(document.stats) <- c('Author', 'TotalDocuments')

document.stats <- merge(document.stats, full.names, by.x = 'Author', by.y = 'FullName')
document.stats <- merge(document.stats, subset(senators, Congress == 111), by.x = 'Senator', by.y = 'Senator')
document.stats <- transform(document.stats, Party = as.character(Party))

pdf(file.path('graphs', 'document_statistics.pdf'))
print(ggplot(document.stats, aes(x = TotalDocuments, fill = Party)) +
  geom_histogram(binwidth = 1) +
  facet_grid(Party ~ .) +
  xlab('Total Documents per Senator') +
  ylab('Senators with N Documents') +
  opts(title = 'Corpus Statistics'))
dev.off()
