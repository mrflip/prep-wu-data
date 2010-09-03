data <- read.table('word_freqs_all.tsv', header=F, sep='\t');
png('typical_dist.png', height=800, width=1200);
hist(data$V1, freq=FALSE, xlab='global token frequency', main='Typical Token Distribution', border='white');
lines(density(data$V1), col='purple');
