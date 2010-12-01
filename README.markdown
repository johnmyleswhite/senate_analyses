# Introduction
Source code for my analyses of Senate roll calls. Currently, only the most basic ideal point analyses are implemented.

# Ideal Point Hardcoding
To resolve the inherent indeterminacy between assigning Republicans positive numbers and Democrats positive numbers, Senator Coburn (R OK) has been assigned a hardcoded ideal point of 2. While I consider a better solution, I am holding off estimating ideal points for earlier congresses.

# Data Sources
All of the roll call data comes from [VoteView](http://voteview.com/). If you use their data, please cite them, because their remarkable efforts are what makes it possible to analyze roll call records so easily.

# Getting Started
If you'd like to start using this code as a basis for your own work, you'll need to have R installed along with the ProjectTemplate, pscl, ggplot2 and rjags packages available on CRAN. In addition, you will need to have JAGS installed, as the ideal point model itself is currently implemented as a JAGS model.

For details on the underlying mathematics, both [Simon Jackman](http://www.amazon.com/Bayesian-Analysis-Sciences-Probability-Statistics/dp/0470011548) and [Andrew Gelman])(http://www.amazon.com/Analysis-Regression-Multilevel-Hierarchical-Models/dp/052168689X) have written books that contain very clear descriptions of ideal point models.
