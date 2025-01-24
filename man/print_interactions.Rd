% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/print_interactions.R
\name{print_interactions}
\alias{print_interactions}
\title{print interactions}
\usage{
print_interactions(interDF, writeRefs = FALSE)
}
\arguments{
\item{interDF}{data.frame with the interactions generated by any of the
following functions: \code{\link{import_Omnipath_PTMS}}, 
\code{\link{import_Omnipath_Interactions}},
\code{\link{import_PathwayExtra_Interactions}}, 
\code{\link{import_KinaseExtra_Interactions}},
\code{\link{import_LigrecExtra_Interactions}}, 
\code{\link{import_TFregulons_Interactions}},
\code{\link{import_miRNAtarget_Interactions}} or 
\code{\link{import_AllInteractions}}}

\item{writeRefs}{[FALSE] writes also the PubMed IDs if available}
}
\value{
Interactions displayed in a nice format
}
\description{
prints the interactions/ptms in a nice format
}
\examples{
ptms = import_Omnipath_PTMS()
print_interactions(head(ptms))
print_interactions(tail(ptms),writeRefs=TRUE)
print_interactions(dplyr::filter(ptms,enzyme_genesymbol=="MAP2K1",
  substrate_genesymbol=="MAPK3"))
}
