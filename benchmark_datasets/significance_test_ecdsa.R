
# Loading the benchmark dataset for the Falcon implementation.
# Hashclasses: 0 = SHAKE256, 1 = cSHAKE256, 2 = TurboSHAKE256, 3 = KangarooTwelve
# (utilized from PyCryptodome library "https://www.pycryptodome.org")
ecdsa_dataset <- read.csv("benchmark_datasets/test_compare_transparent_ecdsa.csv", header = FALSE, sep = ";")

# Preparing the benchmark dataset for the ECDSA implementation.
colnames(ecdsa_dataset) <- c("Operation", "Iteration", "Hashclass", "Time")

# Creating a linear model to evaluate
# if the operation and hashclass is statistically significantly influencing the runtime
reg <- lm(Time ~ Operation + Hashclass, data = ecdsa_dataset)

# Depending on the R environment you are using (here: VSCode),
# execute the script once and call the following commands in the terminal:
#   - summary(reg): print out statistics on the linear regression model e.g., classification into significance codes