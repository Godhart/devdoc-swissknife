# Diagrams Folder

The purpose of this folder is to contain diagrams for documentation.

### Raw content for Kroki

Diagrams content can be placed in RAW text form - in from that rendering engine would accept it and nothing more.
When embedding such file into documentation you'll have to explicitly specify rendering engine.

This is the case if you already have such files and you don't wont to modify them for any reason.
Otherwise it's suggested to use an approach described in next section.

### R Markdown content for Kroki with special fenced section

If a diagram is intended to be rendered with Kroki then it's recommended describe them in Rmd (R Markdown) files and
to follow rules described below. This way diagrams may be edited with [Keenwrite](https://github.com/DaveJarvis/keenwrite)
which provides live rendering.

**NOTE** that for this approach rendering engine for a diagram SHOULD be specified along with diagrams (see template below).

Also, in this case diagrams description may be supplied with additional information like explanation, comments, decisions history,
TODOs, etc. which would stay in this file and won't be added into documentation.

The rules are:

#. Use `.Rmd` as extension for filename
#. Only one diagram per file
#. Use following template for the file content:\
````
<info>

``` diagram-<engine>
<content>
```

<more>
```` \
where:

  * `<info>`    - information about this diagram in R Markdown format (optional)
  * `<engine>`  - name of diagram rendering engine (as defined in Kroki project)
  * `<content>` - plain text description of diagram in a native rendering engine format
  * `<more>`    - more information about this diagram in R Markdown format (optional)

> *Take a NOTE: there SHOULD be a SINGLE SPACE symbol between triple backticks and `diagram` word*

> *Take a NOTE: <info> and <more> are not included into documnetation, but you can use them*
> *to add work notes, descriptions, TODOs etc.*

**NOTE:** There is following limitations for file sections content:
  * `<info>` and `<more>` SHOULD NOT contain string with ``````` diagram-` content
  * `<diagram content>` SHOULD NOT contain triple backticks (\`\`\`)
