to_diagram <- function(dia, name, data = "", src = "") {
  inline <- TRUE  # TODO: set via parameter
  if (knitr::is_latex_output()) {
    # PNG for PDF, SVG for HTML
    ext <- "png"
  } else {
    ext <- "svg"
  }
  if (src == "") {
    data_mode  <-  "--data-raw"
    data_value <- paste("\'",data,"\'", sep="")
  } else {
    data_mode  <-  "--data-binary"
    data_value <- paste("\'@",src,"\'", sep="")
  }
  if (knitr::is_latex_output() || !inline) {
    # Render as Picture
    system2("curl", c(
      paste("http://kroki:8000/",dia,"/",ext, sep=""),
      "-o", paste("\"generated/",name,".",ext,"\"", sep=""),
      data_mode,
      data_value
      ),
      stdout=NULL, stderr=NULL)
    cat(paste("![", name, "](generated/",name,".",ext,")", sep=""))
  } else {
    # Render Inline SVG for HTML
    cat(system2("curl", c(
      paste("http://kroki:8000/",dia,"/",ext, sep=""),
      data_mode,
      data_value
      ),
      stdout=TRUE, stderr=NULL), sep="")
  }
}
