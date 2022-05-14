library(digest)

get_param   <- function(param, fallback) {
  if (!exists("params")
  ||  !exists(param, params)) {
    result <- Sys.getenv(toupper(param), as.character(fallback))
  } else {
    result  <- get(param, params)
  }
  result
}

knitr::opts_hooks$set(dia = function(options) {
  if (!identical(options$dia, NULL)) {
    if (identical(options$dia_hook_off, NULL)
    || !identical(options$dia_debug, NULL)) {
      options$results    <- "asis"
      options$echo       <- FALSE
    }

    if (identical(options$dia_hook_off, NULL)) {
      if (identical(options$fig.align, NULL)
      || (options$fig.align == "default")) {
        options$fig.align <- "center"
      }
    }

    if (!identical(options$out.width, NULL)) {
      html_default_out_width <- get_param("html_default_out_width", "672")
      if (knitr::is_html_output()
      && as.character(options$out.width) == html_default_out_width) {
          options$out.width  <- NULL
      }
    }
  }
  options
})

grab_start  <- function() {
  ""
}

grab_stop   <- function() {
  ""
}

to_diagram  <- function(
    data = "", src = "",
    dformat = "", rawsvg = TRUE,
    downloadOnly = FALSE, downloadName = "",
    service="Kroki", serviceUrl=NULL,
    engine=NULL,
    force=FALSE
    ) {

##############################################################################
# Renders diagram from textual description and inserts it into document.
# Diagram is inserted with knitr::include_graphics
# or as raw SVG code for HTML output (raw svg can be turned off via arguments)
#
####                                                                         #
# data          - Diagram description in text form (should be compatible with
#                 rendering engine).
#                 Ignored if value for `src` is specified.
# src           - Path to outer file with diagram description in text form.
#                 See `docs_src/diagrams/README.md` for details.
#                 Should be omitted if `data` argument is to be used.
# dformat       - Specify data format for downloaded diagram.
#                 See https://kroki.io/#support for details.
#                 `svg` would be used by default if value is empty string.
#                 Sometimes SVG conversion to PDF/PNG not works good on client
#                 side (default). In that case it's suggested to use PNG or PDF.
#                 Take a NOTE: not all Kroki services provide diagrams
#                 in PNG / PDF format.
# rawsvg        - Option to insert SVG as code right into HTML.
#                 This way text on diagrams is searchable.
#                 Enabled (TRUE) by default.
#                 Set to FALSE to embed SVG as image.
#                 Applicable only for HTML output and only if `dformat`
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
#                 `fig.ext` options for R chunk
# service       - Rendering service (now it's sonly "Kroki")
# serviceUrl    - Rendering service base url.
#                 This is starting part of url for service access.
#                 Default is path `http://kroki:8000` to local Kroki
#                 instance that is started with `make_doc.sh`
# engine        - Diagram rendering engine. Specify one of supported engines
#                 (see Kroki for engines list)
#                 Special value `from_src` for outer files SHOULD be used
#                 to get engine from source file itself in case
#                 if recommendations from `docs_src/diagrams/README.md`
#                 are satisfied.
#                 If omitted or NULL then value of R chunk option named `dia`
#                 is treated as `engine`
# force         - If FALSE(default) then existing downloaded diagram data
#                 would be used. Set to TRUE to regenerate diagram from scratch


##############################################################################
# Implementation
####

# TODO: try different tex templates
# TODO: test pages for every feature, also could be used as examples

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

  if (identical(serviceUrl, NULL)) {
    serviceUrl <- get_param(paste("service_", tolower(service), sep = ""),
                            "http://127.0.0.1:8081")
  }

  # File name for downloaded diagram
  if (downloadName != "") {
    fname <- downloadName
  } else if (src != "") {
    # If source file is specified
    # then it's path would be used for downloaded file name
    fname <-  gsub("[./: ]", "-", gsub("[.]+/", "", src, perl = TRUE))
  } else {
    # Otherwise use ref for file name
    fname <-  gsub("[./: ]", "-", ref, perl = TRUE)
  }

  # Select download and output formats
  if (dformat == "") {
    dformat <- "svg"      # If format is not specified - svg would be used
  }

  # If download format is SVG then conversion for output format may be required
  if (dformat == "svg") {
    # If output format is not specified - use defaults
    if (identical(format, NULL)) {
      if (knitr::is_latex_output()) {
        format <- "pdf"   # PDF for PDF
      } else if (knitr::is_html_output()) {
        format <- "svg"   # SVG for HTML
      } else {
        format <- "png"   # PDF for anything else
      }
    }
  } else {                # If download format is other than SVG
    format <- dformat     # then output format should be same as download format
  }

  # If output format is not svg then rawsvg is impossible
  if (format != "svg") {
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
      auto_fit_width <- get_param("dia_auto_fit_width", "84%")
    }

    if (identical(auto_fit_height, NULL)) {
      auto_fit_height <- get_param("dia_auto_fit_height", "800px")
    }
  }

  g_path <- get_param("dia_generated_path", ".dia-generated")
  if (!dir.exists(g_path)) {
    dir.create(g_path)
  }

  g_path <- paste(g_path, "/", sep = "")

  d_path <- paste(g_path, fname, ".", dformat, sep = "")
  if (TRUE || !file.exists(d_path)) {
    system(paste("echo 'Failed to get diagram image from ", service,
                 "(", serviceUrl, ")' > ", "'", d_path, "'", sep = ""))
  }

  # Render diagram
  if (TRUE || !file.exists(d_path)) {
    # by Kroki
    if (service == "Kroki") {

      # Options for kroki request
      if (src == "") {
        # Send string
        data_mode  <- " --data-raw"
        data_value <- paste(" \'", data, "\'", sep = "")
      } else if (engine != "from_src") {
        # Send whole source file
        data_mode  <- "  --data-binary"
        data_value <- paste(" \'@", src, "\'", sep = "")
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
        pipe    <- paste(
          "sed -n '/grab_start/,/grab_stop/{/grab_start/b;/grab_stop/b;p}' '",
          src, "' | ", sep = "")
        # Extract diagram type (aka engine) from source file
        sengine <- paste(
          "`cat '", src,
          "' | grep -oP 'grab.*?dia\\s*=\\s*\"\\K\\w+'`", sep = "")
      }
      s_url <- paste(serviceUrl, "/", sengine, "/", dformat, sep = "")

      c_url <- paste(pipe             # Input data for `from_src` case
              , "curl ", s_url        # Request to server
              , " -o '", d_path, "'"  # Output path
              , data_mode
              , data_value
              , sep = "")

      cache <- as.logical(get_param("dia_cache", "TRUE"))
      cache_dir  <- get_param("dia_cache_path", ".dia-cache")
      cache_path <- paste(cache_dir, "/",
                          digest(c_url), sep = "")

      if (force || as.logical(get_param("dia_force", "FALSE"))
      || !cache || !file.exists(cache_path)) {
        system(paste("echo 'Failed to get diagram image from ", service,
                   "(", s_url, ")' > '", d_path, "'", sep = ""))
        system(c_url, ignore.stdout = TRUE, ignore.stderr = TRUE)
        if (cache) {
          if (!dir.exists(cache_dir)) {
            dir.create(cache_dir)
          }
          file.copy(d_path, cache_path, overwrite = TRUE)
        }
      } else {
        file.copy(cache_path, d_path, overwrite = TRUE)
      }
    }
  }

  # TODO: arbitrary renderer


  # Convert SVG to necessary format
  if (dformat == "svg" && format != "svg"
  && !file.exists(paste(g_path, fname, ".", format, sep = ""))) {
    # TODO: use https://pypi.org/project/html2image/ or Splash!
      system(
          paste(
            "rsvg-convert -f ", format, " -o '",
            g_path, fname, ".", format, "' '",
            g_path, fname, ".svg'"
          , sep = "")
          , ignore.stdout = TRUE, ignore.stderr = TRUE
      )
  }

  # Insert rendered diagram
  if (!downloadOnly) {
    if (!rawsvg) {
      # As Image
      knitr::include_graphics(paste(g_path, fname, ".", format, sep = ""))
    } else {
      # Raw SVG for HTML
      cat("\n\n")
      cat(paste('<div align="', align, '">', sep = ""))
      resize_svg <- "_resizeSvg.py"
      for (i in 1:10) {
        # NOTE: path depends on location of rendered file.
        #       so look for necessary file few levels up
        if (file.exists(resize_svg)) {
          break
        }
        resize_svg <- paste("../", resize_svg, sep = "")
      }
      cat(system2("python3", c(
        resize_svg,
        paste("'", g_path, fname, ".", format, "'", sep = ""),  # Input file
        "-",                                         # Output to stdout
        paste('"', width,  '"', sep = ""),           # Required width
        paste('"', height, '"', sep = ""),           # Required height
        paste('"', auto_fit_width,  '"', sep = ""),  # If width is not specified - don't exceed this value
        paste('"', auto_fit_height, '"', sep = "")   # If height is not specified - don't exceed this value
        ), stdout = TRUE, stderr = NULL), sep = "")
      cat("</div>")

      if (as.logical(get_param("dia_break_on_err", "FALSE"))
      &&  file.exists(paste(g_path, fname, ".", format, ".err", sep = ""))) {
        stop(paste("There were errors while generating diagram '",
                   g_path, fname, ".", format, "'!"))
      }

      # Add a caption and reference
      if (caption != "") {
        if (ref != "") {
          opts <- paste("{", "#", ref, " .caption}", sep = "")
        } else {
          opts <- paste(
            "{#fig:", gsub(" ", "-", caption, fixed = TRUE), " .caption}",
            sep = "")
        }

        # Caption and Link to rendered diagram so it can be saved by user
        cat(paste('<div align="', align, '">', sep = ""))
        cat(paste(
          "\n\n[", caption, "](", g_path, fname, ".", format, ")", opts,
          sep = ""))
        cat("</div>")
      }

      cat("\n\n")
    }
  }
}


dia_src    <- function(src) {
  cat(system(paste(
  "sed -n '/grab_start/,/grab_stop/{/grab_start/b;/grab_stop/b;p}' '",
  src, "'", sep = ""), intern = TRUE), sep = "\n")
}
