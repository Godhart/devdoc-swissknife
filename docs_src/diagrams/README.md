# Diagrams Folder

The purpose of this folder is to contain diagrams for documentation.

# Diagrams for Kroki!

If diagram is intened to be renderd with Kroki! then it's recomended to follow next rules below.
This way diagrams may be edited with Keenwriter which provides live rendering,
supplied with addition information and rendering engine name is always comes along with diagram.

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

  * `<info>`- information about this diagram in RMarkdown format (optional)
  * `<engine>` - name of Kroki! engine to render diagram
  * `<content>` - plain text description of diagram in a native rendering engine format
  * `<more>` - more information about this diagram in RMarkdown format (optional)

> *Take a NOTE: there SHOULD be SINGLE SPACE symbol between triple backticks and `diagram` word*

> *Take a NOTE: <info> and <more> are not included into documnetation, but you can use them*
> *to add work notes, descriptions, TODOs etc.*

Following limitations:
  * `<info>` and `<more>` SHOULD NOT contain string with ``````` diagram-` content
  * `<diagram content>` SHOULD NOT contain tripple backticks (\`\`\`)
