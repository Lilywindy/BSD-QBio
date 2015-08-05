# load the data
load("../Data/MTneuron.RData")

# estimate the direction conditioned count distributions

# using the array counts to form the conditional distributions
# Number of directions
directions <- as.vector(directions)
nDirs <- length(directions)
# For each direction, count number of replicates
nReps <- rep(0, nDirs)
for (n in 1:nDirs){
  nReps[n] <- sum(theta == n)
}

#Make sure you have formed the array data
if (exists("mydata") == FALSE){
  # as done in plot_tuncurve.R
  mydata <- array(0, c(550, 24, 46))
  for (n in 1:nDirs){
    # which are the corresponding thetas?
    index <- which(theta == n)
    for (i in 1:length(index)){
      spks <- round(diturne[index[i], ])
      spks <- spks[spks > 0]
      mydata[spks, n, i] <- 1
    }
  }
  
}

# get an array of the spike counts by direction
T <- 1:350  # let's just count spikes up to 350ms after motion onset
counts <- matrix(0, nDirs, max(nReps))
for (n in 1:nDirs){
  counts[n, ] <- colSums(mydata[T, n, ])
}

# Find the joint distribution between counts and directions and the
# conditional distribution

maxcount <- max(counts)
countbins <- seq(0, maxcount + 6, by = 6) # 18 bins for R we need the actual breaks
ncountbins <- length(countbins) - 1 

Pjoint <- matrix(0, ncountbins, nDirs)
Pcounts_given_dir <- Pjoint;

for (n in 1:nDirs){
  # extract values
  tmp <- as.vector(counts[n, 1:(nReps[n])])
  # construct histogram
  hh <- hist(tmp, breaks = countbins, plot = FALSE)
  mids <- hh$mids  
  Pcounts_given_dir[,n] <- hh$counts / nReps[n]
  Pjoint[, n] <- hh$counts / sum(nReps)
}

# Notice that in each case, we are normalizing by the number of trials that
# go into the probability estimate.  For the joint distribution that is all
# the data.  For the conditional distribution, which is formed direction by
# direction, that is only the repeats for the given direction. 

# Plot the conditional count distribution for the first 350ms of the
# response, for several directions

# empty plot
plot(1, type = "n", 
     xlab = 'count', 
     ylab = 'probability', 
     main = 'Conditional count distributions for different directions',
     xlim = c(0, 120),
     ylim = c(0, 1))
# now plot several directions
for (mydir in seq(1, 24, by = 4)){
  points(mids, Pcounts_given_dir[, mydir], 
         type = "l",
         col = (mydir - 1) / 4)
  # add a text for sort-of-legend
  text(110, 1.0 - mydir * 0.01, paste("angle = ", directions[mydir]), col =  1  + (mydir - 1) / 4)
}


# THIS STILL NEEDS TRANSLATION
# cumcounts <- apply(mydata, 1, cumsum)
# 
# #get the trial-averaged cumulative count for each direction
# 
# mean_cumcounts = zeros(size(cumcounts,1),nDirs);
# for n=1:nDirs
#     mean_cumcounts(:,n) = mean(cumcounts(:,n,1:nReps(n)),3);
# end
# clear n;
# 
# figure;
# set(gca,'FontSize',14);
# h=plot(T,mean_cumcounts(T,13),'k-',T,mean_cumcounts(T,15),'b-', ...
#     T,mean_cumcounts(T,17),'r-',T,mean_cumcounts(T,19),'g-', ...
#     T,mean_cumcounts(T,11),'b--',T,mean_cumcounts(T,9),'r--', ...
#     T,mean_cumcounts(T,5),'g--');
# legend(h,'0 deg','30 deg','60 deg','90 deg','-30 deg','-60 deg','-90 deg');
# xlabel('time since motion onset (ms)');
# ylabel('spike count');
# title('Mean cumulative spike count by direction');