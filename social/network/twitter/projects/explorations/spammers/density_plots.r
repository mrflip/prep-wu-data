densitywtf <- function(x)
{
  junk = NULL
  grouping = NULL
  for(i in 1:length(x))
    {
      junk = c(junk,x[[i]])
      grouping <- c(grouping, rep(i,length(x[[i]])))
    }
  grouping <- factor(grouping)
  n.gr     <- length(table(grouping))
  xr       <- range(junk)

  dens <- tapply(junk, grouping, density)
  cols <- c("red", "darkgreen", "blue")
  plot(dens[[1]], col = cols[1], xlim=c(-10,120), ylim=c(0,0.05), ann=F, axes=F, lwd=4)
  for(j in 2:n.gr)
    {
      lines(dens[[j]], col = cols[j], lwd=4)
    }
}
