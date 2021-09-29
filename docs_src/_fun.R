auto_name <- 0

to_diagram <- function(
    engine, name = "", data = "", src = "",
    dformat = "", format = "",
    rawsvg = TRUE, downloadOnly=FALSE,
    ref="", width = "", height = "", moreOpts="",
    service="Kroki"
    ) {

  ################################################################################################################################
  # Renders diagram from text description and inserts into document
  # Image is inserted with knitr::include_graphics or by inserting markdown image specification string, depending on arguments.
  # If knitr::include_graphics is used then refrence label, width, height etc. should be specified via R chunk options.
  #   see https://bookdown.org/yihui/rmarkdown/r-code.html for details
  ####
  # engine        - Diagram rendering engine. Specify one of supported engines (see Kroki)
  #                 Special value `from_src` for outer files SHOULD be used to get engine from source file itself
  #                 in case if recomendations from `docs_src/diagrams/README.md` are satisfied.
  # name          - Name for diagram. Also would be used as name for downloaded file.
  #                 If omitted then filename would be generated automatically or source file path would be used for name.
  #                 Should be ommited in case if it's intened to insert image with knitr::include_graphics
  # data          - Diagram description in text form (should be compatible with rendering engine).
  #                 Ignored if value for `src` is sepcified.
  # src           - Path to outer file with diagram description in text form. See `docs_src/diagrams/README.md` for details.
  #                 Should be omitted if `data` argument is to be used.
  # dformat       - Specify data format for downloaded diagram. See https://kroki.io/#support for details.
  #                 `svg` would be used by default if value is empty string.
  #                 Sometimes SVG conversion to PDF/PNG not works good on client side. In that case it's suggested to use PNG.
  #                 Take a NOTE: not all Kroki services provide diagrams in PNG format.
  # format        - Explicitly set client side conversion for data downloaded in **SVG** format.
  #                 By default (if value is empty string):
  #                 * SVG is used for HTML output (i.e. no conversion),
  #                 * PDF for PDF output,
  #                 * PNG for anything else (MS Word, MS PPT).
  #                 Use this option in cases if default conversion produces corrupted result.
  # rawsvg        - Option to insert SVG graphics as code right into HTML. This way text on diagrams is searchable.
  #                 Enabled by default.
  #                 Only aplicable for HTML output and only if `dformat` and `format` args are "SVG".
  #                 If rawsvg is used (default) then additional options like ref/width/height should be specified via arguments,
  #                 not via R chunk options.
  # downloadOnly  - Only generate and download diagram, don't insert into doc.
  #                 Use for custom diagram embedding later in the doc.
  #                 All the necessary conversions
  #                 Result would be in `docs_src/generated` dir with name and extension as defined by args `name` and `format`.
  # service       - Renderning service (now it's sonly "Kroki")

  ################################################################################################################################
  # Additional Options for markdown specification string
  # If any of this arguments is specified then markdown string is used (like this - ![Alt Text](image_path){...options...})
  ####
  # ref           - Reference label  (alphanumeric)
  # width         - Width for image  (as per markdown spec)
  # height        - Height for image (as per markdown spec)
  # moreOpts      - More options to markdown image tag (see https://pandoc.org/MANUAL.html#images)

  ################################################################################################################################
  # Implementation
  ####

  if (rawsvg || name != "" || ref != "" || width != "" || height != "" || moreOpts != "") {
    RWay <- FALSE
    # When RWay is FALSE ref, width and hegiht are taken from function arguments and markdown image specification string is used
  } else {
    RWay <- TRUE
    # When RWay is TRUE  it means that ref, width and height are specified via R chunk options and knitr::include_graphics is used
    # to insert graphics. This provides more options image placement tuning via additional R chunk options
    # (see https://bookdown.org/yihui/rmarkdown/r-code.html#figures)
    # but this way SVG graphics can't be placed as raw SVG code into HTML
  }

  # File name for downloaded daigaram
  if (src != "") {
    # If source file is specified then it's path would be used for downloaded file name
    fname <- gsub("/", "-", src, fixed = TRUE)
  } else {
    # If diagram is generated from string
    if (name == "") {
      # Generate file name automatically if name is omitted
      auto_name <- auto_name + 1
      fname <- paste("_fig_",auto_name,sep="")
    } else {
      # Otherwise use diagram name for file name
      fname <- name # TODO: substitute prohibited chars like this: `gsub(" ", "-", name, fixed = TRUE)`
    }
  }

  # Select download and output formats
  if (dformat == "") {
    dformat <- "svg"      # If Kroki format is not specified - svg would be used
  }

  if (dformat == "svg") { # If download format is SVG then conversion for output format may be required
    if (format == "") {   # If output format is not specified - use defaults
      if (knitr::is_latex_output()) {
        format <- "pdf"   # PDF for PDF
      } else if (knitr::is_html_output()) {
        format <- "svg"   # SVG for HTML
      } else {
        format <- "png"   # PDF for anything else
      }
    }
  } else {                # If download format is other than SVG
    format <- dformat     # then outuput foumat should be same as download format
  }

  # If output format is not svg then rawsvg is imposible
  if ( format != "svg") {
    rawsvg <- FALSE
  }
  # rawsvg can be used with HTML only
  if (!knitr::is_html_output()) {
    rawsvg <- FALSE
  }

  # Render diagram
  if (service == "Kroki") {
    # by Kroki
    if (!file.exists(paste("'generated/",fname,".",dformat,"'", sep=""))) {

      # Options for kroki request
      if (src == "") {
        # Send string
        data_mode  <- "--data-raw"
        data_value <- paste("\'",data,"\'", sep="")
      } else if (engine != "from_src") {
        # Send whole source file
        data_mode  <- "--data-binary"
        data_value <- paste("\'@",src,"\'", sep="")
      } else {
        # Extracted diagram description from source file (for engine='from_src')
        data_mode  <- "--data-binary"
        data_value <- "@-"
      }

      if (engine != "from_src" || src == "") {
        # system2 is used if data is string or whole file. This way (system2) it's safe to pass raw string data
        system2("curl", c(
        paste("http://kroki:8000/",engine,"/",dformat, sep=""),             # Request to server
        "-o", paste("'generated/",fname,".",dformat,"'", sep=""),           # Output path, downloaded data format
        data_mode,                                                          # Data mode (raw/binary)
        data_value                                                          # Data for POST request (raw string data / whole file path)
        ),
        stdout=NULL, stderr=NULL)
      } else {
        # system is used if data is extracted from source file since pipe required here
        system(
                paste("sed -n '/```\\sdiagram-/,/```/{/```\\sdiagram-/b;/```/b;p}' '",src,"'"  # Get diagram data from source file
                , " | curl http://kroki:8000/"                              # Request to server
                , "`cat '",src,"' | grep -oP '\\`\\`\\` diagram-\\K.*'`"    # Get diagram type (aka engine) from source file
                , "/",dformat                                               # Downloaded data format
                , " -o 'generated/",fname,".",dformat,"'"                   # Output path
                , " --data-binary @-"                                       # Use piped data in POST request
                , sep="")
                , ignore.stdout=TRUE, ignore.stderr=TRUE
        )
      }
    }
  }

  # Convert SVG to necessary format
  if (dformat == "svg" && format != "svg" && !file.exists(paste("generated/",fname,".",format, sep=""))) {
      system(
          paste("rsvg-convert -f ",format," -o 'generated/",fname,".",format,"' 'generated/",fname,".svg'"
          , sep="")
          , ignore.stdout=TRUE, ignore.stderr=TRUE
      )
  }

  if (!downloadOnly) {
    # Insert rendered diagram
    if (!rawsvg) {
      # As picture
      if (RWay == FALSE) {
        # in a markdown way
        if (ref!="" || width!="" || height!="" || moreOpts!="") {
          opts <- paste(
            "{",
            if (ref=="")       "" else paste("#",ref,sep=""),
            if (width=="")     "" else paste("width=",width,sep=""),
            if (height=="")    "" else paste("height=",height,sep=""),
            moreOpts,
            "}")
        } else {
          opts <- ""
        }
        cat(paste("![", name, "](generated/",fname,".",format,")",opts, sep=""))
      } else {
        # in a R way
        knitr::include_graphics(paste("generated/",fname,".",format, sep=""))
      }
    } else {
      # Raw SVG for HTML

      # Insert SVG data
      cat("\n\n")
      cat(system2("python3", c(
        "../_resizeSvg.py",
        paste("'generated/",fname,".",format,"'", sep=""), # Input file
        "-",                                          # Output to stdout
        paste('"',width,'"', sep=""),                 # Required width
        paste('"',height,'"', sep="")                 # Required height
        ), stdout=TRUE, stderr=NULL), sep="")

      # Add a caption
      if (ref!="") {
        opts <- paste("{","#",ref," .caption}",sep="")
      } else {
        opts <- paste("{#fig:",gsub(" ", "-", name, fixed = TRUE)," .caption}",sep="")
      }

      # Caption and Link to rendered diagram so it can be saved by user
      cat(paste("\n\n[", name, "](","generated/",fname,".",format,")",opts,"\n\n", sep=""))
    }
  }
}
