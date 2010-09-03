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
