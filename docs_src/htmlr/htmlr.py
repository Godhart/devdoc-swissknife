import sys
import getopt
import json
import requests
import re

"""
Renders schematic from it's textual definition:
    Takes as input YAML definition for top level
    Converts into d3-schematic representation
    Renders to HTML via Splash (https://splash.readthedocs.io/en/stable/, docker pull scrapinghub/splash)
    Saves rendered HTML to SVG/image/partial HTML to file or return via STDOUT
"""

VERSION = "1.0.0"
USAGE = "TODO: usage information"   # TODO: usage information

_SUPPORTED_FORMATS = ("html", "png", "jpeg", "har")
_TEXT_FORMAT = ("html", "har")
_JSON_FORMAT = "json:"

def render(renderer: str, url: str, rformat: str = "png",
           post: dict = None, headers: dict = None, params: dict = None):
    """
    :param renderer: url to rendering service (Splash expected)
    :param url:      url to be rendered
    :param rformat:  output data format - html, png, jpeg, har, json
    :param post:     JSON data for post request. If None then get request is issued
    :param headers:  headers data for request
    :param params:   misc options as size etc.
    :return:         data as text/binary or dict format depending on rformat
    """

    to_json = rformat[:len(_JSON_FORMAT)] == _JSON_FORMAT

    if rformat not in _SUPPORTED_FORMATS and not to_json:
        raise ValueError("rformat is expected to be one of "+", ".join(f"'{k}'" for k in _SUPPORTED_FORMATS)+
                         " or 'json:<necessary formats list>'")

    if params is not None:
        params = {**params}
    else:
        params = {}
    params["url"] = url

    if to_json:
        for k in _SUPPORTED_FORMATS:
            if k in rformat:
                params[k] = 1
    if to_json:
        rurl = renderer+"/render.json"
    else:
        rurl = renderer+"/render."+rformat

    if headers is None:
        headers = {}

    if post is not None and len(post) > 0:
        r = requests.post(rurl, params=params, headers=headers, data=post)
    else:
        r = requests.get(rurl, params=params, headers=headers)

    if r.status_code == 200:
        if rformat in _TEXT_FORMAT:
            return r.text
        elif to_json:
            return json.loads(r.text)
        else:
            return r.content
    else:
        return None


if __name__ == "__main__":
    _RENDER = "render"
    _URL = "url"
    _FORMAT = "format"
    _POST = "post"
    _OUTPUT = "output"
    _SIZE = "size"
    _HEADERS = "headers-"
    _OPTIONS = "options-"

    opts = {
        _RENDER: None,
        _URL: None,
        _FORMAT: "",
        _POST: {},
        _OUTPUT: "-",
        _SIZE: "",
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
            specs[k] = ("-"+k[0], "--"+k)
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

    if not isinstance(opts[_POST], dict):
        try:
            opts[_POST] = json.loads(opts[_POST])
        except Exception as e:
            raise SystemExit(f"Failed to parse POST data.\nIt should be a valid JSON.\nGot exception: {e}")

    if opts[_SIZE] != "":
        if re.match(r"^\d+x\d+$", opts[_SIZE]) is None:
            raise SystemExit(r"Size should be in format '\d+x\d+', '1024x768' for example")
        opts[_OPTIONS]["viewport"] = opts[_SIZE]

    if opts[_OUTPUT] in ("", "-"):
        if opts[_FORMAT] == "":
            opts[_FORMAT] = "html"
        if opts[_FORMAT] not in _TEXT_FORMAT and opts[_FORMAT][:len(_JSON_FORMAT)] != _JSON_FORMAT:
            raise SystemExit(f"Output file should be specified for binary formats!")
    else:
        if opts[_FORMAT] == "":
            m = re.search(r"\.(\w+)$", opts[_OUTPUT])
            if m is not None:
                fc = m.groups()[0].lower()
                if fc not in _SUPPORTED_FORMATS:
                    raise SystemExit("Can't guess format from output file name. Specify 'format' explicitly!")
                else:
                    opts[_FORMAT] = fc

    result = render(
        renderer=opts[_RENDER],
        url=opts[_URL],
        rformat=opts[_FORMAT],
        post=opts[_POST],
        headers=opts[_HEADERS],
        params=opts[_OPTIONS]
    )

    if result is None:
        raise ConnectionError("Failed to obtain rendered HTML")

    if isinstance(result, dict):
        result = json.dumps(result, indent=2)

    if isinstance(result, str):
        if opts[_OUTPUT] in ("", "-"):
            print(result)
        else:
            with open(opts[_OUTPUT], "w") as f:
                f.writelines([result])
    else:
        with open(opts[_OUTPUT], "wb") as f:
            f.write(result)
