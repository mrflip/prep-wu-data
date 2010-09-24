beta_uc <- function(x, u, c) {
  return (x^(c*u - 1.0)*(1.0 - x)^(c*(1.0 - u) - 1.0))
}

beta_ab <- function(x, a, b) {
  return (x^(a - 1.0)*(1.0 - x)^(b - 1.0))
}

beta_mu_rho <- function(x, mu, rho) {
  u = mu
  c = (1.0/rho) - 1.0
  return (beta_uc(x, u, c))
}

#
# x in [0,1], N*x is count
#
zibinom <- function(x, z, p, N) {
  if(x == 0) {
    return (z + (1-z) * (1-p)^N)
  }
  else {
    return ((1-z)*choose(N, round(N*x))*p^(N*x)*(1-p)^(N*(1-x)))
  }
}

#
# What you need to do to do this analysis
#
bootstrap_beta_fitting <- expression({
  # get and load required packages
  install.packages("VGAM");
  library(VGAM);
  # Read in data that is (successes, n_trials), successes/n_trials in [0,1]
  cnts <- read.table('success_and_trial_data_for_one_term.tsv', header=F, sep='\t');
  # Make a histogram to see what you're doing
  hist(cnts$V1/cnts$V2, breaks=200, freq=FALSE);
  # Fit distribution, this may take a while (use a beefy machine)
  fit = vglm(cnts$V1/cnts$V1 ~ 1, beta.ab);
  # Plot your fit so you're convinced, it will probably not be that good
  lines(x, dbeta(x, Coef(fit)["shape1"], Coef(fit)["shape2"]), col="red")
  # Get shape parameters for distribution
  beta_a <- as.numeric(Coef(fit)["shape1"]);
  beta_b <- as.numeric(Coef(fit)["shape2"]);

  expectation = beta_a/(beta_a + beta_b);
  variance    = expectation*(1.0 - expectation)/(beta_a + beta_b + 1.0);
  # Hurray
})
