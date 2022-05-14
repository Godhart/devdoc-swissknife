quiet = "--quiet" %in% commandArgs(FALSE)
formats = commandArgs(TRUE)

# provide default formats if necessary
if (length(formats) == 0) formats = c('bookdown::gitbook', 'bookdown::pdf_book')
# render the book to all formats unless they are specified via command-line args
for (fmt in formats) {
  cmd = sprintf("bookdown::render_book('index.Rmd', '%s', quiet = %s)", fmt, quiet)
  res = bookdown:::Rscript(c('-e', shQuote(cmd)))
  if (res != 0) stop('Failed to compile the book to ', fmt)
}

if (length(formats) > 1 && Sys.getenv('USER') == '<author>') {
  bookdown::publish_book(account = '<author>', server = '<server>.org')
}
