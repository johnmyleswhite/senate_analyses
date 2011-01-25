library('ProjectTemplate')
load.project()

# Goal is to generate ideal points for all 111 Congresses.
#congresses <- seq(1, 111, by = 1)
congresses <- seq(90, 96, by = 1)
#congresses <- seq(101, 111, by = 1)

for (congress in congresses)
{
  hardcoded.member <- with(subset(hardcoded.ideal.points,
                                  Congress == congress),
                           as.character(Senator))

  hardcoded.ideal.point <- with(subset(hardcoded.ideal.points,
                                       Congress == congress),
                                IdealPoint)

  generate.ideal.points(congress, hardcoded.member, hardcoded.ideal.point)
}
