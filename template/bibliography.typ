// Keep Typst's default cite for Hayagriva; route through a wrapper based on bibliography style.
#let typst-cite = cite
#import "@preview/pergamon:0.6.0": *
#let pergamon-cite = cite

// Settings for Pergamon.
#let pergamon-style = format-citation-numeric()
#let is-ja = reference => {
  let lang = reference.fields.at("language", default: none)
  lang != none and (lang == "ja" or lang == "ja-JP" or lang == "japanese" or lang == "jp")
}
#let format-reference-en = format-reference(
  reference-label: pergamon-style.reference-label,
  print-url: true,
  suppress-fields: ("language",),
  bibstring: ("in": none),
)
#let format-reference-ja = format-reference(
  reference-label: pergamon-style.reference-label,
  name-format: "{family}{given}",
  list-end-delim-two: "、",
  list-end-delim-many: "、",
  format-fields: (
    // 日本語文献に`translator`の指定があるなら{訳者名}(訳)とする
    "parsed-translator": (dffmt, value, reference, field, options, style) => {
      if value == none {
        none
      } else {
        let names = value.map(d => format-name(d, name-type: "translator", format: options.at("name-format")))
        let joined = concatenate-names(names, options: options, minnames: options.minnames, maxnames: options.maxnames)
        [#joined (訳)]
      }
    },
    // 日本語文献に`editor`の指定があるなら{編者名}(編)とする
    "parsed-editor": (dffmt, value, reference, field, options, style) => {
      if value == none {
        none
      } else {
        let names = value.map(d => format-name(d, name-type: "editor", format: options.at("name-format")))
        let joined = concatenate-names(names, options: options, minnames: options.minnames, maxnames: options.maxnames)
        [#joined (編)]
      }
    },
  ),
  format-journaltitle: it => it,
  format-issuetitle: it => it,
  format-maintitle: it => it,
  format-booktitle: it => it,
  print-url: true,
  suppress-fields: ("language",),
  bibstring: (
    "in": none,
    "editor": none,
  ),
)
#let format-reference-by-lang = (index, reference) => {
  if is-ja(reference) {
    format-reference-ja(index, reference)
  } else {
    format-reference-en(index, reference)
  }
}

#let bibliography-state = state("bibliography-state", (
  "file": none,
  "csl": none,
  "style": "hayagriva",
  "shown": false,
))

#let configure(config) = {
  bibliography-state.update(_ => (
    "file": config.at("file", default: none),
    "csl": config.at("csl", default: none),
    "style": config.at("style", default: "hayagriva"),
    "shown": false,
  ))
}

#let cite(..args) = context {
  let style = bibliography-state.get().at("style", default: "hayagriva")
  let pos = args.pos()
  let named = args.named()

  if style == "pergamon" {
    let keys = pos.map(k => if type(k) == str { k } else { str(k) })
    pergamon-cite(..keys, ..named)
  } else {
    let keys = pos.map(k => if type(k) == str { label(k) } else { k })
    let cites = keys.map(k => typst-cite(k))
    if cites.len() == 0 {
      none
    } else if cites.len() == 1 {
      cites.first()
    } else {
      cites.join([ ])
    }
  }
}

#let with-pergamon(body, file: none) = {
  add-bib-resource(read(file))
  refsection(body, format-citation: pergamon-style.format-citation)
}

#let show-hayagriva(
  bib-file,
  csl,
  prefix-mode: none,
  paragraph-config: (:),
  section-fonts: (),
  heading-size: 12pt,
) = {
  prefix-mode.update("none")
  set par(
    leading: paragraph-config.at("leading"),
    spacing: paragraph-config.at("spacing"),
    first-line-indent: 0pt,
    justify: paragraph-config.at("justify"),
  )

  show bibliography: set text(12pt)
  show heading.where(level: 1): it => {
    pagebreak()
    counter(math.equation).update(0)
    set text(font: section-fonts, size: heading-size)
    text(weight: "bold")[
      #v(0.2em)
      #it.body
      #v(0.5em)
    ]
  }
  heading(level: 1, numbering: none)[参考文献]

  bibliography(
    bib-file,
    title: none,
    style: if csl != none { csl } else { "ieee" },
  )
}

#let show-pergamon(
  prefix-mode: none,
  paragraph-config: (:),
  section-fonts: (),
  heading-size: 12pt,
) = {
  prefix-mode.update("none")
  set par(
    leading: paragraph-config.at("leading"),
    spacing: paragraph-config.at("spacing"),
    first-line-indent: 0pt,
    justify: paragraph-config.at("justify"),
  )

  show bibliography: set text(12pt)
  show heading.where(level: 1): it => {
    pagebreak()
    counter(math.equation).update(0)
    set text(font: section-fonts, size: heading-size)
    text(weight: "bold")[
      #v(0.5em)
      #it.body
      #v(0.5em)
    ]
  }

  print-bibliography(
    format-reference: format-reference-by-lang,
    label-generator: pergamon-style.label-generator,
    sorting: reference => reference.fields.at("sortkey", default: reference.entry_key),
    title: "参考文献",
  )
}

#let render(
  prefix-mode: none,
  paragraph-config: (:),
  section-fonts: (),
  heading-size: 12pt,
  header: none,
) = context {
  let config = bibliography-state.get()
  if config.at("file") == none or config.at("shown") {
    return none
  }

  set page(header: header, numbering: "1")

  let bib-file = config.at("file")
  let bib-style = config.at("style", default: "hayagriva")
  if bib-style == "hayagriva" {
    show-hayagriva(
      bib-file,
      config.at("csl"),
      prefix-mode: prefix-mode,
      paragraph-config: paragraph-config,
      section-fonts: section-fonts,
      heading-size: heading-size,
    )
  } else if bib-style == "pergamon" {
    show-pergamon(
      prefix-mode: prefix-mode,
      paragraph-config: paragraph-config,
      section-fonts: section-fonts,
      heading-size: heading-size,
    )
  }
  bibliography-state.update(conf => {
    conf.at("shown") = true
    conf
  })
}
