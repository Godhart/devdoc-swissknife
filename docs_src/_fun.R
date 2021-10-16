knitr::opts_hooks$set(dia = function(options){
  if (!identical(options$dia, NULL)) {
    if (identical(options$dia_hook_off, NULL) || !identical(options$dia_debug, NULL)) {
      options$results    <- "asis"
      options$echo       <- FALSE
    }

    if (identical(options$dia_hook_off, NULL)) {
      if (identical(options$fig.align, NULL) || (options$fig.align=="default")) {
        options$fig.align <- "center"
      }
    }

    if (!identical(options$out.width, NULL)) {
      if (knitr::is_html_output() && options$out.width == params$html_default_out_width) {
        options$out.width  <- NULL
      }
    }
  }
  options
})

to_diagram <- function(
    data = "", src = "",
    dformat = "", rawsvg = TRUE,
    downloadOnly = FALSE, downloadName = "",
    service="Kroki", serviceUrl="http://kroki:8000",
    engine=NULL
    ) {

  ##############################################################################
  # Renders diagram from textual description and inserts it into document.
  # Diagram is inserted with knitr::include_graphics
  # or as raw svg for HTML output (raw svg can be turned off via arguments).
  #
  ####                                                                         #
  # data          - Diagram description in text form (should be compatible with
  #                 rendering engine).
  #                 Ignored if value for `src` is sepcified.
  # src           - Path to outer file with diagram description in text form.
  #                 See `docs_src/diagrams/README.md` for details.
  #                 Should be omitted if `data` argument is to be used.
  # dformat       - Specify data format for downloaded diagram.
  #                 See https://kroki.io/#support for details.
  #                 `svg` would be used by default if value is empty string.
  #                 Sometimes SVG conversion to PDF/PNG not works good on client
  #                 side (default). In that case it's suggested to use PNG.
  #                 Take a NOTE: not all Kroki services provide diagrams
  #                 in PNG format.
  # rawsvg        - Option to insert SVG graphics as code right into HTML.
  #                 This way text on diagrams is searchable.
  #                 Enabled by default.
  #                 Aplicable only for HTML output and only if `dformat`
  #                 is "SVG" or empty string.
  # downloadName  - File name (part before extension) for local diagram's files.
  # downloadOnly  - Only generate and download diagram, don't insert into doc.
  #                 Use for custom diagram embedding later in the doc.
  #                 All the necessary format conversions will be completed.
  #                 Result would be in `docs_src/generated` dir.
  #                 If `downloadName` is specified then it would be used for
  #                 file name, otherwise label would be used if diagram is
  #                 specified via data, otherwise file name would be generated
  #                 from `src` path.
  #                 File extension would depend on `dformat` argument and on
  #                 `fix.ext` options for R chunk
  # service       - Rendering service (now it's sonly "Kroki")
  # serviceUrl    - Rendering service base url
  # engine        - Diagram rendering engine. Specify one of supported engines
  #                 (see Kroki for engines list)
  #                 Special value `from_src` for outer files SHOULD be used
  #                 to get engine from source file itself in case
  #                 if recomendations from `docs_src/diagrams/README.md`
  #                 are satisfied.
  #                 If ommitted then `dia` chunk option is treated as `engine`

  ##############################################################################
  # Implementation
  ####

  if (!identical(knitr::opts_current$get("dia_debug"), NULL)) {
    DEBUG <- TRUE
  } else {
    DEBUG <- FALSE
  }

  if (DEBUG) {
    str(knitr::opts_current$get())
  }

  # Common options
  ref     <- knitr::opts_current$get("label")

  format  <- knitr::opts_current$get("fig.ext")

  if (identical(engine, NULL)) {
    engine  <- knitr::opts_current$get("dia")
  }

  # File name for downloaded daigaram
  if (downloadName != "") {
    fname <- downloadName
  } else if (src != "") {
    # If source file is specified then it's path would be used for downloaded file name
    fname <-  gsub("[./: ]", "-", gsub("[.]+/", "", src, perl = TRUE))
  } else {
    # Otherwise use ref for file name
    fname <-  gsub("[./: ]", "-", ref, perl = TRUE)
  }

  # Select download and output formats
  if (dformat == "") {
    dformat <- "svg"      # If format is not specified - svg would be used
  }

  if (dformat == "svg") { # If download format is SVG then conversion for output format may be required
    if (identical(format, NULL)) { # If output format is not specified - use defaults
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

  # Raw SVG only options
  if (rawsvg) {
    caption <- knitr::opts_current$get("fig.cap")
    width   <- knitr::opts_current$get("out.width")
    height  <- knitr::opts_current$get("out.height")
    align   <- knitr::opts_current$get("fig.align")
    auto_fit_width  <- knitr::opts_current$get("auto_fit_width")
    auto_fit_height <- knitr::opts_current$get("auto_fit_height")

    if (identical(caption, NULL)) {
      caption <- ""
    }

    if (identical(width, NULL)) {
      width <- ""
    }

    if (identical(height, NULL)) {
      height <- ""
    }

    if (identical(align, NULL)) {
      align <- "center"
    }

    if (align == "default") {
      align <- "center"
    }

    if (identical(auto_fit_width, NULL)) {
      auto_fit_width  <- params$dia_auto_fit_width
    }

    if (identical(auto_fit_height, NULL)) {
      auto_fit_height <- params$dia_auto_fit_height
    }
  }

  # Render diagram
  if (service == "Kroki") {
    # by Kroki
    if (!file.exists(paste("'generated/",fname,".",dformat,"'", sep=""))) {

      # Options for kroki request
      if (src == "") {
        # Send string
        data_mode  <- " --data-raw"
        data_value <- paste(" \'",data,"\'", sep="")
      } else if (engine != "from_src") {
        # Send whole source file
        data_mode  <- "  --data-binary"
        data_value <- paste(" \'@",src,"\'", sep="")
      } else {
        # Extracted diagram description from source file (for engine='from_src')
        data_mode  <- " --data-binary"
        data_value <- " @-"
      }

      if (engine != "from_src" || src == "") {
        pipe    <- ""
        sengine <- engine
      } else {
        # Extract diagram data from source file
        pipe    <- paste("sed -n '/```\\sdiagram-/,/```/{/```\\sdiagram-/b;/```/b;p}' '",src,"' | ", sep="")
        # Extract diagram type (aka engine) from source file
        sengine <- paste("`cat '",src,"' | grep -oP '\\`\\`\\` diagram-\\K.*'`", sep="")
      }
      system(
              paste(pipe                                        # Input data for `from_src` case
              , "curl ", serviceUrl, "/", sengine, "/",dformat  # Request to server
              , " -o 'generated/",fname,".",dformat,"'"         # Output path
              , data_mode
              , data_value
              , sep="")
              , ignore.stdout=TRUE, ignore.stderr=TRUE
      )
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

  # Insert rendered diagram
  if (!downloadOnly) {
    if (!rawsvg) {
      # As Image
      knitr::include_graphics(paste("generated/",fname,".",format, sep=""))
    } else {
      # Raw SVG for HTML
      cat("\n\n")
      cat(paste('<div align="',align,'">', sep=""))
      cat(system2("python3", c(
        "../_resizeSvg.py",
        paste("'generated/",fname,".",format,"'", sep=""),  # Input file
        "-",                                                # Output to stdout
        paste('"',width, '"', sep=""),           # Required width
        paste('"',height,'"', sep=""),           # Required height
        paste('"',auto_fit_width, '"', sep=""),  # If width is not specified - don't exceed this value
        paste('"',auto_fit_height,'"', sep="")   # If height is not specified - don't exceed this value
        ), stdout=TRUE, stderr=NULL), sep="")
      cat('</div>')

      # Add a caption and reference
      if (caption != "") {
        if (ref!="") {
          opts <- paste("{","#",ref," .caption}",sep="")
        } else {
          opts <- paste("{#fig:",gsub(" ", "-", caption, fixed = TRUE)," .caption}",sep="")
        }

        # Caption and Link to rendered diagram so it can be saved by user
        cat(paste('<div align="',align,'">', sep=""))
        cat(paste("\n\n[", caption, "](","generated/",fname,".",format,")",opts, sep=""))
        cat('</div>')
      }

      cat("\n\n")
    }
  }
}
