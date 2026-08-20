
# Loading the benchmark dataset for the Falcon implementation.
# Hashclasses: 0 = SHAKE256, 1 = cSHAKE256, 2 = TurboSHAKE256, 3 = KangarooTwelve
# (utilized from PyCryptodome library "https://www.pycryptodome.org")
falcon_dataset <- read.csv("benchmark_datasets/test_compare_transparent_falcon.csv", header = FALSE, sep = ";")

# Preparing the benchmark dataset for the Falcon implementation.
colnames(falcon_dataset) <- c("Operation", "Iteration", "Hashclass", "Time")
rows <- unique(falcon_dataset[, "Operation"])
columns <- unique(falcon_dataset[, "Hashclass"])

# Aggregating runtime statistics of the benchmark dataset into tables.
averages_table <- aggregate(falcon_dataset["Time"]/1000, list(falcon_dataset$Operation, falcon_dataset$Hashclass), mean)

colnames(averages_table) <- c("Operation", "Hashclass", "Time")

overall_sum <- aggregate(averages_table["Time"], list(averages_table$Hashclass), sum)
colnames(overall_sum) <- c("Hashclass", "Time")


# Depending on the R environment you are using (here: VSCode),
# execute the script once and call the following commands in the terminal:
#   - averages_table:   average runtime (in ns) per operation per XOF hash function
#   - overall_sum:      sum runtime (in ns) of all operations per XOF hash function