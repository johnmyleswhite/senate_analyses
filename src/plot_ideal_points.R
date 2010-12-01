library('ProjectTemplate')
load.project()

# Goal is to generate ideal points for all 111 Congresses.
#congresses <- seq(1, 111, by = 1)
congresses <- seq(109, 111, by = 1)

for (congress in congresses)
{
  plot.ideal.points(congress)
}
