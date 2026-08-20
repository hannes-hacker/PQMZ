
# Loading the benchmark dataset for the Falcon implementation.
# Hashclasses: 0 = SHAKE256, 1 = cSHAKE256, 2 = TurboSHAKE256, 3 = KangarooTwelve
# (utilized from PyCryptodome library "https://www.pycryptodome.org")

# change to benchmark_datasets/test_compare_transparent_falcon512_with_countermeasure.csv
# to see the benchmarks of creating a recoverable signature with the side-channel attack countermeasure.
falcon_dataset <- read.csv("benchmark_datasets/test_compare_transparent_falcon.csv", header = FALSE, sep = ";")

# Preparing the benchmark dataset for the Falcon implementation.
colnames(falcon_dataset) <- c("Operation", "Iteration", "Hashclass", "Time")

# Creating a linear model to evaluate
# if the operation and hashclass is statistically significantly influencing the runtime
reg <- lm(Time ~ Operation + Hashclass, data = falcon_dataset)

# Depending on the R environment you are using (here: VSCode),
# execute the script once and call the following commands in the terminal:
#   - summary(reg): print out statistics on the linear regression model e.g., classification into significance codes