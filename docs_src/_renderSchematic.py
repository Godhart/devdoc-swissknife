import sys
import getopt
import json
from schconv import schconv
from htmlr import htmlr
import base64
import re

"""
Renders schematic from it's textual definition:
    Takes as input YAML definition for top level
    Converts into d3-schematic representation
    Renders to HTML via Splash (https://splash.readthedocs.io/en/stable/)
    Saves rendered HTML to SVG/image/partial HTML to file or return via STDOUT
"""

VERSION = "1.0.0"
USAGE = "TODO: usage information"   # TODO: usage information


def rip_svg(content: str, embed_styles: bool = False) -> str:
    """
    Rips SVG content (single diagram) out of HTML
    :param content:      HTML page content in text format
    :param embed_styles: If specified as True then mentioned styles would be downloaded and embedded into SVG
    :return: SVG node
    """
    return content


def rip_svgi(content: str, embed_styles: bool = False) -> str:
    """
    Rips SVG content (single diagram) and scripts for interaction out of HTML
    :param content:      HTML page content in text format
    :param embed_styles: If specified as True then mentioned styles would be downloaded and embedded into SVG
    :return: text with content for HTML page containing all the scripts and SVG node
    """
    return content


if __name__ == "__main__":

    _TOP = "top"
    _LOCATION = "location"
    _RENDER = "render"
    _URL = "url"
    _FORMAT = "format"
    _OUTPUT = "output"
    _SIZE = "size"
    _EMBED_STYLES = "embed_styles"
    _HEADERS = "headers-"
    _OPTIONS = "options-"

    _SVG = "svg"
    _SVGI = "svgi"
    _HTML = "html"
    _HAR = "har"
    _PNG = "png"
    _JPEG = "jpeg"

    _TEXT_FORMAT = (_SVG, _SVGI, _HTML, _HAR)
    _HTML_FORMAT = (_SVG, _SVGI, _HTML)

    opts = {
        _TOP: None,
        _LOCATION: None,
        _RENDER: None,
        _URL: None,
        _FORMAT: _SVG,
        _OUTPUT: "-",
        _SIZE: "",
        _EMBED_STYLES: False,
        _HEADERS: {},
        _OPTIONS: {}
    }

    opts_len = len(opts)

    options, arguments = getopt.getopt(
        sys.argv[1:],
        "vh"+"".join(f"{k[0]}:" for k in opts if k[-1] != "-"),
        ["version", "help"]
        + [f"{k}=" for k in opts if k[-1] != "-"]
        + [f"{k[:-1]}=" for k in opts if k[-1] == "-"]
    )

    specs = {}
    for k in opts:
        if k[-1] == "-":
            specs[k] = ("--"+k[:-1],)
        else:
            specs[k] = ("-"+k[1], "--"+k)
    for o, a in options:
        if o in ("-v", "--version"):
            print(VERSION)
            sys.exit()
        if o in ("-h", "--help"):
            print(USAGE)
            sys.exit()
        for opt, spec in specs.items():
            if o in spec:
                opts[opt] = a
                continue

    if opts_len != len(opts):
        print(USAGE)
        sys.exit()

    opts_not_defined = []
    for o in opts:
        if opts[o] is None:
            opts_not_defined.append("'"+o+"'")

    if len(opts_not_defined) > 0:
        raise SystemExit(f"Value should be specified for following options: {' '.join(opts_not_defined)}!\n{USAGE}")
    # if not arguments or len(arguments) > opts_len:
    #     raise SystemExit(USAGE)

    if not isinstance(opts[_OPTIONS], dict):
        try:
            opts[_OPTIONS] = json.loads(opts[_OPTIONS])
        except Exception as e:
            raise SystemExit(f"Failed to parse options.\nIt should be a valid JSON.\nGot exception: {e}")

    if not isinstance(opts[_HEADERS], dict):
        try:
            opts[_HEADERS] = json.loads(opts[_HEADERS])
        except Exception as e:
            raise SystemExit(f"Failed to parse headers.\nIt should be a valid JSON.\nGot exception: {e}")

    if opts[_SIZE] != "":
        if re.match(r"^\d+x\d+$", opts[_SIZE]) is None:
            raise SystemExit(r"Size should be in format '\d+x\d+', '1024x768' for example")
        opts[_OPTIONS]["viewport"] = opts[_SIZE]

    if not isinstance(opts[_EMBED_STYLES], bool):
        opts[_EMBED_STYLES] = opts[_EMBED_STYLES].lower() not in ("false", "0")

    json_data = schconv.conv_yaml_to_d3ch(opts[_TOP], opts[_LOCATION])
    json_html = htmlr.render(
        renderer=opts[_RENDER],
        url=opts[_URL],
        rformat="json:"+_HTML if opts[_FORMAT] in _HTML_FORMAT
            else _PNG if opts[_FORMAT] == _PNG
            else _JPEG if opts[_FORMAT] == _JPEG
            else _HAR if opts[_FORMAT] == _HAR
            else "",
        post={"data": json_data},
        headers=opts[_HEADERS],
        params=opts[_OPTIONS],
    )
    if json_html is None:
        raise ConnectionError("Failed to obtain rendered HTML")

    content = None
    if opts[_FORMAT] in _HTML_FORMAT:
        content = json_html['html']
    if opts[_FORMAT] == _PNG:
        content = json_html['png']
    if opts[_FORMAT] == _JPEG:
        content = json_html['jpeg']
    if opts[_FORMAT] == _HAR:
        content = json_html['har']

    assert content is not None, "Shouldn't be that way"

    if opts[_OUTPUT] == _SVG:
        content = rip_svg(content, opts[_EMBED_STYLES])

    if opts[_OUTPUT] == _SVGI:
        content = rip_svgi(content, opts[_EMBED_STYLES])

    if opts[_OUTPUT] in ("", "-"):
        print(content)
    else:
        if opts[_FORMAT] in _TEXT_FORMAT:
            with open(opts[_OUTPUT], "w") as f:
                f.writelines([content])
        else:
            with open(opts[_OUTPUT], "wb") as f:
                f.write(base64.b64decode(content))
