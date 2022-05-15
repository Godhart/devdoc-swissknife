# References

* [R chunks and knitr options](https://yihui.org/knitr/options/)
* [R chunks hooks](https://yihui.org/knitr/hooks/)
* [Landscape](https://j-wang.blogspot.com/2015/03/landscape-and-portrait-in-rmarkdown.html)\
[more here](https://stackoverflow.com/questions/21840878/rotate-a-table-from-r-markdown-in-pdf)\
```
\usepackage{lscape}
\usepackage{pdfpages}

Some text on a portrait page.

\newpage
\blandscape

## Title, lorem ipsum

```{r, results = "asis"}
kable(iris[1:5,], caption = "Lorem again")
```
Lorem ipsum...

\elandscape

Some other text on a portrait page.
```
*

# Output Formats - https://bookdown.org/yihui/rmarkdown/output-formats.html#output-formats

# https://bookdown.org/yihui/rmarkdown/r-code.html
# https://bookdown.org/yihui/rmarkdown/language-engines.html




# TODO:

Python Image - https://docs.docker.com/language/python/build-images/ - https://hub.docker.com/_/python/
Node Image - ...

* https://kevinpt.github.io/symbolator/ - https://github.com/kevinpt/symbolator
* https://github.com/Nic30/d3-hwschematic
* https://github.com/Nic30/sphinx-hwt
* https://schemdraw.readthedocs.io/en/latest/


# Check this out:

* https://github.com/freechipsproject/diagrammer
* https://github.com/nturley/netlistsvg
* https://github.com/davidthings/hdelk
* https://github.com/kieler/elkjs
* https://github.com/LaurentCabaret/pyVhdl2Sch
* https://github.com/Nic30/d3-wave
* https://github.com/Nic30/sphinx-hwt
* https://github.com/shioyadan/Konata
* https://github.com/wavedrom/logidrom
* https://github.com/emsec/hal
* https://github.com/LaurentCabaret/pyVhdl2Sch

* https://github.com/umarcor/hwstudio
* https://github.com/dkilfoyle/logic