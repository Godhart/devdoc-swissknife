import sys
import xml.etree.ElementTree as ET
import xml.dom.minidom as DOM
import re


def resizeSVG(svg, width, height):
    resize = width != "" or height != ""

    if resize:
        svg.removeAttribute("width")
        svg.removeAttribute("height")
        svg.setAttribute("prserveAspectRatio", "none")

    if svg.hasAttribute("style"):
        svg_style = svg.getAttribute("style")
        styles = svg_style.split(";")
        svg_style = ""
        for s in styles:
            if re.match(r"^(width|height):.*$", s) is None:
                svg_style += s + ";"
            elif not resize:
                svg_style += s + ";"
    else:
        svg_style = ""

    if "background:" not in svg_style:
        svg_style += "background:#FFFFFF;"

    if resize and width != "":
        svg.setAttribute("width", width)
        svg_style += "width:" + str(width) + ";"

    if resize and height != "":
        svg.setAttribute("height", height)
        svg_style += "height:" + str(height) + ";"

    svg.setAttribute("style", svg_style)
    svg.setAttribute("standalone", "yes")


def setDoctype(document, doctype):
    # source: https://stackoverflow.com/questions/1980380/how-to-render-a-doctype-with-pythons-xml-dom-minidom
    imp= document.implementation
    newdocument= imp.createDocument(doctype.namespaceURI, doctype.name, doctype)
    newdocument.xmlVersion= document.xmlVersion
    refel= newdocument.documentElement
    for child in document.childNodes:
        if child.nodeType==child.ELEMENT_NODE:
            newdocument.replaceChild(
                newdocument.importNode(child, True), newdocument.documentElement
            )
            refel= None
        elif child.nodeType!=child.DOCUMENT_TYPE_NODE:
            newdocument.insertBefore(newdocument.importNode(child, True), refel)
    return newdocument


if __name__ == "__main__":
    width = "100%"
    height = ""

    v = 3

    if len(sys.argv) > 3:
        width = sys.argv[3]
    if len(sys.argv) > 4:
        height = sys.argv[4]

    svg_doc = DOM.parse(sys.argv[1])
    svg = svg_doc.getElementsByTagName("svg")[0]

    resizeSVG(svg, width, height)

    if sys.argv[2] == "-":
        print(svg_doc.toxml())
    else:
        with open(sys.argv[2], "w") as f:
            f.write(svg_doc.toxml())

    exit(0)
