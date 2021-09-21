to_diagram <- function(dia, name, data = "", src = "", inline = TRUE) {
  if (knitr::is_latex_output()) {
    # PDF for PDF, SVG for HTML
    ext <- "pdf"
  } else {
    ext <- "svg"
  }
  fname <- name # TODO: substitute prohibited chars like this: `gsub(" ", "-", name, fixed = TRUE)`
  if (src == "") {
    data_mode  <- "--data-raw"
    data_value <- paste("\'",data,"\'", sep="")
  } else if (dia != "from_src") {
    data_mode  <- "--data-binary"
    data_value <- paste("\'@",src,"\'", sep="")
  } else {
    data_mode  <- "--data-binary"
    data_value <- "@-"
  }
  if (knitr::is_latex_output() || !inline) {
    # Render as Picture
    # TODO: str_interp
    if (!file.exists(paste("'generated/",fname,".svg'", sep=""))) {
      if (dia != "from_src" || src == "") {
        system2("curl", c(
        paste("http://kroki:8000/",dia,"/svg", sep=""),
        "-o", paste("'generated/",fname,".svg'", sep=""),
        data_mode,
        data_value
        ),
        stdout=NULL, stderr=NULL)
      } else {
        system(
                paste("sed -n '/```\\sdiagram-/,/```/{/```\\sdiagram-/b;/```/b;p}' '",src,"'"     # Get content
                , " | curl http://kroki:8000/"                              # Request to server
                , "`cat '",src,"' | grep -oP '\\`\\`\\` diagram-\\K.*'`"    # Get diagram type (aka engine)
                , "/svg"                                                    # Incoming data is always SVG
                , " --data-binary @-"                                       # Send piped data in POST request
                , " -o 'generated/",fname,".svg","'"                        # Output to file
                , sep="")
                , ignore.stdout=TRUE, ignore.stderr=TRUE
        )
      }
    }
    # Convert SVG to PDF
    if (ext == 'pdf') {
        system(
            paste("rsvg-convert -f pdf -o 'generated/",fname,".pdf' 'generated/",fname,".svg'"
            , sep="")
            , ignore.stdout=TRUE, ignore.stderr=TRUE
        )
    }
    cat(paste("![", name, "](./generated/",fname,".",ext,")", sep=""))
  } else {
    # Render Inline SVG for HTML
    if (dia != "from_src" || src == "") {
        cat(system2("curl", c(
        paste("http://kroki:8000/",dia,"/",ext, sep=""),
        data_mode,
        data_value
        ),
        stdout=TRUE, stderr=NULL), sep="")
    } else {
        cat(
            system(
                paste("sed -n '/```\\sdiagram-/,/```/{/```\\sdiagram-/b;/```/b;p}' '",src,"'"     # Get content
                , " | curl http://kroki:8000/"                              # Request to server
                , "`cat '",src,"' | grep -oP '\\`\\`\\` diagram-\\K.*'`/"   # Get diagram type
                , ext                                                       # Output data format (svg/png)
                , " --data-binary @-"                                       # Send piped data in POST request
                , sep="")
                ,intern=TRUE, ignore.stderr=TRUE
            ),
            sep=""
        )
    }
  }
}
