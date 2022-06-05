
## 1: stringdist package
# adapted from http://www.markvanderloo.eu/yaRb/2015/01/24/stringdist-0-9-exercise-all-your-cores/
library(bench)
library(stringdist)
set.seed(19481210)

# number of strings
N <- 10000

# Generate N random strings of length min_len to max_len
rand_str <- function(N, min_len=5, max_len=31){
  len <- sample(min_len:max_len, size=N, replace=TRUE)
  sapply(len,function(n) paste(sample(letters,n,replace=TRUE),collapse=""))
}

x <- rand_str(N)
y <- rand_str(N)

bm_sd <- bench::mark(
    stringdist(x, y, nthread=1),
    stringdist(x, y, nthread=2),
    stringdist(x, y, nthread=3),
    stringdist(x, y, nthread=4),
    stringdist(x, y, nthread=11),
    iterations = 50
)

summary(bm_sd)

# if openmp is recognized data.table will load using multiple threads,
# see the load message when loading the package
library(data.table)

# or:
data.table::getDTthreads()

# this should max out at n available cores (?? i think?)
# compare to parallel::detectCores()
data.table::setDTthreads(threads = 1000)
data.table::getDTthreads()
