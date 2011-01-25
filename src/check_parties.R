library('ProjectTemplate')
load.project()

congresses <- seq(1, 111, by = 1)

senators <- data.frame()

for (congress in congresses)
{
  roll.calls <- readKH(file.path('data', paste('roll_calls_', congress, '.ord', sep = '')))

  votes <- roll.calls$votes

  binary.votes <- apply(votes, c(1, 2), yes.no.vote)
  
  current.senators <- row.names(binary.votes)
  parties <- as.character(sapply(current.senators, determine.party))

  senators <- rbind(senators, data.frame(Senator = current.senators, Congress = congress, Party = parties))
}

write.csv(senators,
          file = file.path('cache', 'senators.csv'),
          row.names = FALSE)
