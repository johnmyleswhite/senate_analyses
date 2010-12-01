clean.variable.name <- function(variable.name)
{
  variable.name <- gsub('_', '.', variable.name, perl = TRUE)
  variable.name <- gsub('-', '.', variable.name, perl = TRUE)
  variable.name <- gsub('\\s+', '.', variable.name, perl = TRUE)
  return(variable.name)
}

yes.no.vote <- function (vote)
{
  if (vote == 1)
  {
    return(1)
  }

  if (vote == 6)
  {
    return(0)
  }
  else
  {
    return(NA)
  }
}

generate.ideal.points <- function(congress, hardcoded.member, hardcoded.ideal.point)
{
  roll.calls <- readKH(file.path('data', paste('roll_calls_', congress, '.ord', sep = '')))

  votes <- roll.calls$votes

  binary.votes <- apply(votes, c(1, 2), yes.no.vote)

  a <- rep(NA, nrow(binary.votes))
  a[which(row.names(binary.votes) == hardcoded.member)] <- hardcoded.ideal.point

  jags <- jags.model('jags/ideal_points.bug',
                     data = list('votes' = binary.votes,
                                 'M' = nrow(binary.votes),
                                 'N' = ncol(binary.votes),
                                 'a' = a),
                     n.chains = 4,
                     n.adapt = 500)

  update(jags, 100)

  j.samples <- jags.samples(jags,
                          c('a', 'b', 'g'),
                          250)

  estimated.a <- apply(j.samples$a, 1, mean)
  a.min <- sapply(1:nrow(binary.votes),
                  function (i) {quantile(as.numeric(j.samples$a[i,,]), probs = c(0.005, 0.995))})[1,]
  a.max <- sapply(1:nrow(binary.votes),
                  function (i) {quantile(as.numeric(j.samples$a[i,,]), probs = c(0.005, 0.995))})[2,]

  write.csv(data.frame(Senator = row.names(binary.votes),
                       IdealPoint = estimated.a,
                       MinIdealPoint = a.min,
                       MaxIdealPoint = a.max),
            file = file.path('cache', paste('senator_ideal_points', congress, '.csv', sep = '')),
            row.names = FALSE)
}

plot.ideal.points <- function(congress)
{
  ideal.points <- read.csv(file.path('cache', paste('senator_ideal_points_', congress, '.csv', sep = '')))

  uncertainty <- aes(ymin = MinIdealPoint, ymax = MaxIdealPoint)

  ideal.points <- transform(ideal.points,
                            Party = ifelse(grepl('\\(R', ideal.points$Senator),
                                           'Republican',
                                           'Democract'))

  colors <- c("#2121D9", "#D92121")

  png(file.path('graphs',
                paste('ideal_points_',
                      congress,
                      '.png',
                      sep = '')),
      width = 600,
      height = 2400)
  p <- ggplot(ideal.points, aes(x = reorder(Senator, IdealPoint), y = IdealPoint, color = Party)) + 
    geom_point() +
    geom_errorbar(uncertainty) +
    coord_flip() +
    scale_color_manual(values = colors) +
    xlab('Senator') +
    ylab('Estimated Ideal Point') +
    opts(title = 'Ideal Points for 110th Congress')
  print(p)
  dev.off()
}
