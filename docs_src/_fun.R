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

service_alias <- c(
  "krk" = "Kroki",
  "off" = "Office",
  "y4s" = "Yaml4Schm",
  "spl" = "Splash"
)

service_defaults <- c(
  "Kroki" = "http://127.0.0.1:8081",
  "Office" = "local",
  "Yaml4Schm" = "http://127.0.0.1:8088",
  "Splash" = "http://127.0.0.1:8050"
)

get_service_url <- function(service) {
  service_url <- get_param(paste("service_", tolower(service), sep = ""),
                          service_defaults[service])
}

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
    page=NULL,
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
# service       - Rendering service ("Kroki", "Office", "Splash", "Yaml4Schm")
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
# page          - Page for rendering. For use with multipage office documents
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

  if (service != "Kroki"
  &&  service != "Office"
  &&  service != "Yaml4Schm"
  &&  service != "Splash") {
    service_tmp <- service_alias[service]
  }
  if (service_tmp != "Kroki"
  &&  service_tmp != "Office"
  &&  service_tmp != "Yaml4Schm"
  &&  service_tmp != "Splash") {
    stop(paste("Service", as.character(service), "is not supported!"))
  } else {
    service <- service_tmp
  }

  if (identical(serviceUrl, NULL)) {
    serviceUrl <- get_service_url(service)
  }
  if (service == "Office") {
    serviceUrl <- "local"
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

  if (identical(page, NULL)) {
    page <- ""
  } else {
    page <- as.character(page)
    paste(fname, "-", page, sep = "")
  }

  # Select download and output formats
  if (dformat == "") {
    dformat <- "svg"      # If format is not specified - svg would be used
  }

  # Yaml4Schm is rendered with Splash
  if (service == "Yaml4Schm") {
    is_y4s      <- TRUE
    y4s_src     <- src
    src         <- paste(serviceUrl, engine, "show", src, sep = "/")
    service     <- "Splash"
    serviceUrl  <- get_service_url(service)
    engine      <- dformat
  } else {
    is_y4s      <- FALSE
    y4s_src     <- NULL
  }

  # for Splash SVGs are grabbed out of HTML
  if (service == "Splash") {
    if (engine == "svg") {
      engine <- "html"
      dformat <- "svg"
    }
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
        format <- "png"   # PNG for anything else
      }
    }
    # If it's office then dformat should be same as format
    if (service == "Office") {
      dformat <- format
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

  d_path <- paste(g_path, fname, ".", dformat, sep = "")  # TODO: add page to d_path
  if (TRUE || !file.exists(d_path)) {
    system(paste("echo 'Failed to get diagram image from ", service,
                 "(", serviceUrl, ")' > ", "'", d_path, "'", sep = ""))
  }

  # Render diagram
  if (TRUE || !file.exists(d_path)) {
    # by Splash
    if (service == "Splash") {
      if (src == "") {
        stop("Splash/Yaml4Schm supports data input from files only!")
      }
      d_url <- paste("?url=", src,
        "&render_all=1&wait=1", sep = "")

      vp_width   <- knitr::opts_current$get("vp_width")
      vp_height  <- knitr::opts_current$get("vp_height")
      if (!identical(vp_width, NULL) && !identical(vp_height, NULL)) {
        d_url <- paste(d_url, "&viewport=", width, "x", height, sep = "")
      }

      s_url <- paste(serviceUrl, "/", "render.", engine, d_url, sep = "")

      # URL to get image
      c_url <- paste("curl '", s_url   # Request to server
              , "' -o '", d_path, "'"  # Output path
              , sep = "")

      # Cache things
      cache <- as.logical(get_param("dia_cache", "TRUE"))
      cache_dir  <- get_param("dia_cache_path", ".dia-cache")
      if (cache) {
        if (is_y4s) {
          # TODO: replace ".." with root path for diagrams
          source_digest <- paste(digest(file = paste("..", y4s_src, sep = "/")),
                                "-", sep = "")
        } else {
          source_digest <- ""
        }
        cache_path <- paste(cache_dir, "/",
                            source_digest, digest(c_url), ".", dformat,
                            sep = "")
      } else {
        cache_path <- ""
      }

      # If image is not cached or forced - get image
      if (force || as.logical(get_param("dia_force", "FALSE"))
      || !cache || !file.exists(cache_path)) {
        system(paste("echo 'Failed to get diagram image from ", service,
                   "(", s_url, ")' > '", d_path, "'", sep = ""))
        system(c_url, ignore.stdout = TRUE, ignore.stderr = TRUE)

        # Store result to cache
        if (cache) {
          if (!dir.exists(cache_dir)) {
            dir.create(cache_dir)
          }
          file.copy(d_path, cache_path, overwrite = TRUE)
        }
      } else {
        # Otherwise copy cached data into destination path
        file.copy(cache_path, d_path, overwrite = TRUE)
      }

    }
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

      # URL to get image
      c_url <- paste(pipe               # Input data for `from_src` case
              , "curl '", s_url         # Request to server
              , "' -o '", d_path, "'"   # Output path
              , data_mode
              , data_value
              , sep = "")

      # Cache things
      cache <- as.logical(get_param("dia_cache", "TRUE"))
      cache_dir  <- get_param("dia_cache_path", ".dia-cache")
      if (cache) {
        cache_path <- paste(cache_dir, "/",
                            digest(c_url), ".", dformat, sep = "")
      } else {
        cache_path <- ""
      }

      # If image is not cached or forced - get image
      if (force || as.logical(get_param("dia_force", "FALSE"))
      || !cache || !file.exists(cache_path)) {
        system(paste("echo 'Failed to get diagram image from ", service,
                   "(", s_url, ")' > '", d_path, "'", sep = ""))
        system(c_url, ignore.stdout = TRUE, ignore.stderr = TRUE)

        # Store result to cache
        if (cache) {
          if (!dir.exists(cache_dir)) {
            dir.create(cache_dir)
          }
          file.copy(d_path, cache_path, overwrite = TRUE)
        }
      } else {
        # Otherwise copy cached data into destination path
        file.copy(cache_path, d_path, overwrite = TRUE)
      }
    }
    # by Libre Office
    if (service == "Office") {
      if (src == "") {
        stop("Office supports data input from files only!")
      }

      # Command line for converting image with Libre Office
      if (page == "") {
        cformat <- paste(dformat,":",knitr::opts_current$get("dia"),
                         "_", dformat, "_Export", sep = "")
      } else {
        cformat <- paste("'", dformat, ":", knitr::opts_current$get("dia"),
                         "_", dformat,
          '_Export:{"PageRange":{"type":"string", "value":"', page, '"}}\'',
          sep = "")
      }

      c_url <- paste(
        # "LD_LIBRARY_PATH=/usr/lib/libreoffice/program:$LD_LIBRARY_PATH",
        "soffice", "--headless", "--convert-to", cformat,
        "--outdir", g_path, src)

      # Cache things
      cache <- as.logical(get_param("dia_cache", "TRUE"))
      cache_dir  <- get_param("dia_cache_path", ".dia-cache")
      if (cache) {
        if (page == "") {
          c_page <- ""
        } else {
          c_page <- paste("-", page, sep = "")
        }
        cache_path <- paste(cache_dir, "/",
                          digest(file = src), c_page, ".", dformat,
                          sep = "")
      } else {
        cache_path <- ""
      }

      # There is a issue with shared libraries
      # so it's required update LD_LIBRARY_PATH
      # with /usr/lib/libreoffice/program going first
      Sys.setenv(LD_LIBRARY_PATH =
        paste("/usr/lib/libreoffice/program",
        Sys.getenv("LD_LIBRARY_PATH"), sep = ":"))

      if (page != "") {
        office_version <- system("soffice --version", intern = TRUE)
        office_version <- gsub("^.*?\\s(\\d+\\.\\d+).*$", "\\1",
                               office_version[1], perl = TRUE)
        office_version <- as.numeric(office_version)
        if (office_version < 7.4) {
          warn_office_version <- paste(
            "Pages support for Office is coming with version 7.4",
            " of Libre Office\n(expecting Aug 21, 2022 ).",
            " Your version is ", as.character(office_version),
            ".\nShowing only default page of diagram file.", sep = "")
          warning(warn_office_version)
        }
      }

      # If image is not cached or forced - get image
      if (force || as.logical(get_param("dia_force", "FALSE"))
      || !cache || !file.exists(cache_path)) {
        system(paste("echo 'Failed to get diagram image from ", service,
                   "' > '", d_path, "'", sep = ""))

        # Libre Office don't allows to set output file name,
        # so we need to do more actions than usual

        ## First - lets see where output file is saved by Libre Office
        ### get only file name
        r_path <- gsub("^.*/", "", src, perl = TRUE)
        ### replace source's file name extension according to dformat
        r_path <- gsub(".[^.]*$", paste(".", dformat, sep = ""), r_path, perl = TRUE)
        ### join generated path and filename
        r_path <- paste(g_path, r_path, sep = "")

        # Unlink existing Libre Office's output file
        if (file.exists(r_path)) {
          file.remove(r_path)
        }

        # Convert
        system(c_url) #, ignore.stdout = TRUE, ignore.stderr = TRUE)

        ## Rename Libre Office's output file
        if (r_path != d_path) {
          file.copy(r_path, d_path, overwrite = TRUE)
          file.remove(r_path)
        }

        # Store result to cache
        if (cache) {
          if (!dir.exists(cache_dir)) {
            dir.create(cache_dir)
          }
          file.copy(d_path, cache_path, overwrite = TRUE)
        }
      } else {
        # Otherwise copy cached data into destination path
        file.copy(cache_path, d_path, overwrite = TRUE)
      }
    }
  }

  # Get SVG out of HTML
  if (dformat == "svg" && service == "Splash") {
    rip_svg <- "_resizeSvg.py"
    # NOTE: resizeSvg works well with ripping SVGs too
    for (i in 1:10) {
      # NOTE: path depends on location of rendered file.
      #       so look for necessary file few levels up
      if (file.exists(rip_svg)) {
        break
      }
      rip_svg <- paste("../", rip_svg, sep = "")
    }
    system(
      paste(
        "python3",
        rip_svg,
        paste("'", d_path, "'", sep = ""),  # Input file
        paste("'", d_path, "'", sep = ""),  # Output file (same as input)
        "-", "-"        # width and height are set to '-' to avoid resize
      )
    )
  }

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
