to_diagram <- function(dia, name, data = "", src = "", inline = TRUE, ext = "", krk = "") {
  if (krk == "") {    # If Kroki! extension is not specified - svg would be used
    krk <- "svg"
    if (ext == "") {  # If output extension is not specified - use defaults
      if (knitr::is_latex_output()) {
        ext <- "pdf"  # PDF for PDF
      } else {
        ext <- "svg"  # SVG for HTML
      }
    }
  } else {
    ext <- krk  # Otherwise outuput type should be same as for Kroki!
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
    if (!file.exists(paste("'generated/",fname,".",krk,"'", sep=""))) {
      if (dia != "from_src" || src == "") {
        system2("curl", c(
        paste("http://kroki:8000/",dia,"/",krk, sep=""),
        "-o", paste("'generated/",fname,".",krk,"'", sep=""),
        data_mode,
        data_value
        ),
        stdout=NULL, stderr=NULL)
      } else {
        system(
                paste("sed -n '/```\\sdiagram-/,/```/{/```\\sdiagram-/b;/```/b;p}' '",src,"'"     # Get content
                , " | curl http://kroki:8000/"                              # Request to server
                , "`cat '",src,"' | grep -oP '\\`\\`\\` diagram-\\K.*'`"    # Get diagram type (aka engine)
                , "/",krk                                                   # Incoming data format
                , " --data-binary @-"                                       # Send piped data in POST request
                , " -o 'generated/",fname,".",krk,"'"                       # Output to file
                , sep="")
                , ignore.stdout=TRUE, ignore.stderr=TRUE
        )
      }
    }
    # Convert SVG to necessary type
    if (krk == "svg" && ext != "svg") {
        system(
            paste("rsvg-convert -f ",ext," -o 'generated/",fname,".",ext,"' 'generated/",fname,".svg'"
            , sep="")
            , ignore.stdout=TRUE, ignore.stderr=TRUE
        )
    }
    cat(paste("![", name, "](./generated/",fname,".",ext,")", sep=""))  # TODO: ref, width, height
  } else {
    # Render Inline SVG for HTML
    if (dia != "from_src" || src == "") {
        cat(system2("curl", c(
        paste("http://kroki:8000/",dia,"/",krk, sep=""),
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
                , krk                                                       # Output data format (svg/png)
                , " --data-binary @-"                                       # Send piped data in POST request
                , sep="")
                ,intern=TRUE, ignore.stderr=TRUE
            ),
            sep=""
        )
    }
    cat(paste("![", name, "](./images/hidden_pixel.png)", sep=""))  # TODO: ref, width, height
  }
}
