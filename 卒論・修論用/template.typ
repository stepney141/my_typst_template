// https://github.com/ut-khanlab/master_thesis_template_for_typst

// Keep Typst's default cite for Hayagriva; route through a wrapper based on bibliography style.
#let typst-cite = cite
#import "@preview/pergamon:0.6.0": *
// Hooked cite by Pergamon
#let pergamon-cite = cite

// Settings for Pergamon
#let pergamon_style = format-citation-numeric()
#let is_ja = reference => {
  let lang = reference.fields.at("language", default: none)
  lang != none and (lang == "ja" or lang == "ja-JP" or lang == "japanese" or lang == "jp")
}
#let format_reference_en = format-reference(
  reference-label: pergamon_style.reference-label,
  print-url: true,
  suppress-fields: ("language",),
  bibstring: ("in": none),
)
#let format_reference_ja = format-reference(
  reference-label: pergamon_style.reference-label,
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
#let format_reference_by_lang = (index, reference) => {
  if is_ja(reference) {
    format_reference_ja(index, reference)
  } else {
    format_reference_en(index, reference)
  }
}

// Set font sizes
#let font_sizes = (
  h1: 18pt,
  h2: 16pt,
  h3: 14pt,
  under_h4: 12pt,
  normal: 11pt,
  math: 12pt,
)
#let font_sizes_cover = (
  title: 22pt,
  subtitle: 20pt,
  normal: 17pt,
)

// Configure paragraph properties.
#let par-distance = 0.9em

// Set fonts.
// TeX Gyre Pagella is a free alternative to Palatino.
#let body-fonts = ("Nimbus Roman", "Source Han Serif JP") // serif
#let strong-fonts = ("Nimbus Roman", "IPAPGothic") // en: serif, ja: sans serif
#let section-fonts = ("Inter", "UDEV Gothic 35JPDOC") // sans serif
#let title-fonts = ("Nimbus Roman", "UDEV Gothic 35JPDOC") // en: serif, ja: sans serif

// Store theorem environment numbering
#let thmcounters = state("thm", (
  "counters": ("heading": ()),
  "latest": (),
))

// Track prefix mode for chapter headings (used for headings, TOC, refs).
// Values: "main" | "appendix" | "none"
#let prefix_mode = state("prefix-mode", "main")

#let heading_label(loc) = {
  let vals = counter(heading).at(loc)
  if vals.len() == 0 {
    return none
  }
  let mode = prefix_mode.at(loc)
  if mode == "none" {
    return none
  } else if mode == "appendix" {
    let letter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(vals.at(0) - 1)
    if vals.len() == 1 {
      [付録 #letter]
    } else {
      [#(letter + "." + vals.slice(1).map(str).join(".")) #h(0.5em)]
    }
  } else {
    if vals.len() == 1 {
      [第#vals.first()章]
    } else {
      [#vals.map(str).join(".") #h(0.1em)]
    }
  }
}

// Setting theorem environment
#let thmenv(identifier, base, base_level, fmt) = {
  let global_numbering = numbering

  return (
    ..args,
    body,
    number: auto,
    numbering: "1.1",
    refnumbering: auto,
    supplement: identifier,
    base: base,
    base_level: base_level,
  ) => {
    let name = none
    if args != none and args.pos().len() > 0 {
      name = args.pos().first()
    }
    if refnumbering == auto {
      refnumbering = numbering
    }
    let result = none
    if number == auto and numbering == none {
      number = none
    }
    if number == auto and numbering != none {
      result = context {
        let heading-counter = counter(heading).get()
        return thmcounters.update(thmpair => {
          let counters = thmpair.at("counters")
          // Manually update heading counter
          counters.at("heading") = heading-counter
          if not identifier in counters.keys() {
            counters.insert(identifier, (0,))
          }

          let tc = counters.at(identifier)
          if base != none {
            let bc = counters.at(base)

            // Pad or chop the base count
            if base_level != none {
              if bc.len() < base_level {
                bc = bc + (0,) * (base_level - bc.len())
              } else if bc.len() > base_level {
                bc = bc.slice(0, base_level)
              }
            }

            // Reset counter if the base counter has updated
            if tc.slice(0, -1) == bc {
              counters.at(identifier) = (..bc, tc.last() + 1)
            } else {
              counters.at(identifier) = (..bc, 1)
            }
          } else {
            // If we have no base counter, just count one level
            counters.at(identifier) = (tc.last() + 1,)
            let latest = counters.at(identifier)
          }

          let latest = counters.at(identifier)
          return (
            "counters": counters,
            "latest": latest,
          )
        })
      }

      number = context {
        global_numbering(numbering, ..thmcounters.get().at("latest"))
      }
    }

    return figure(
      result
        + // hacky!
        fmt(name, number, body, ..args.named())
        + [#metadata(identifier) <meta:thmenvcounter>],
      kind: "thmenv",
      outlined: false,
      caption: none,
      supplement: supplement,
      numbering: refnumbering,
    )
  }
}

// Definition of theorem box
#let thmbox(
  identifier,
  head,
  ..blockargs,
  supplement: auto,
  padding: (top: 0.5em, bottom: 0.5em),
  namefmt: x => [(#x)],
  titlefmt: strong,
  bodyfmt: x => x,
  separator: [#h(0.1em):#h(0.2em)],
  base: "heading",
  base_level: none,
) = {
  if supplement == auto {
    supplement = head
  }
  let boxfmt(name, number, body, title: auto) = {
    if not name == none {
      name = [ #namefmt(name)]
    } else {
      name = []
    }
    if title == auto {
      title = head
    }
    if not number == none {
      title += " " + number
    }
    title = titlefmt(title)
    body = bodyfmt(body)
    pad(
      ..padding,
      block(
        width: 100%,
        inset: 1.2em,
        radius: 0.3em,
        breakable: false,
        ..blockargs.named(),
        [#title#name#separator#body],
      ),
    )
  }
  return thmenv(
    identifier,
    base,
    base_level,
    boxfmt,
  ).with(
    supplement: supplement,
  )
}

// Setting plain version
#let thmplain = thmbox.with(
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  inset: (top: 0em, left: 1.2em, right: 1.2em),
  namefmt: name => emph([(#name)]),
  titlefmt: emph,
)

#let definition = thmbox(
  "definition", //identifier
  "定義",
  base_level: 1,
  // stroke: black + 1pt,
)

// Counting equation number
#let equation_num(_) = {
  context {
    let chapt = counter(heading).get().at(0)
    let c = counter(math.equation)
    let n = c.get().at(0)
    "(" + str(chapt) + "." + str(n) + ")"
  }
}

// Counting table number
#let table_num(_) = {
  context {
    let chapt = counter(heading).get().at(0)
    let c = counter("table-chapter" + str(chapt))
    let n = c.get().at(0)
    str(chapt) + "." + str(n)
  }
}

// Counting image number
#let image_num(_) = {
  context {
    let chapt = counter(heading).get().at(0)
    let c = counter("image-chapter" + str(chapt))
    let n = c.get().at(0)
    str(chapt) + "." + str(n)
  }
}

// Definition of table format
#let tbl(tbl, caption: "", label: none, placement: auto) = {
  context {
    let chapt = counter(heading).get().at(0)
    counter("table-chapter" + str(chapt)).step()
    [
      #set figure.caption(separator: [ -- ])
      // To prevent page break between figure body and caption
      // https://github.com/typst/typst/issues/5357
      #show figure: it => {
        set block(sticky: true)
        it
      }
      // reference statements are unavailable with custom elements
      // https://forum.typst.app/t/how-to-reference-styled-figures/5947
      #figure(
        tbl,
        caption: caption,
        supplement: [表],
        numbering: table_num,
        kind: "table",
        placement: placement,
      )#label
    ]
  }
}

// Definition of image format
#let img(img, caption: "", label: none, placement: auto) = {
  context {
    let chapt = counter(heading).get().at(0)
    counter("image-chapter" + str(chapt)).step()

    [
      #show figure: set par(spacing: 2em)
      #set figure.caption(separator: [ --- ])
      // To prevent page break between figure body and caption
      // https://github.com/typst/typst/issues/5357
      #show figure: it => {
        set block(sticky: true)
        it
      }
      // reference statements are unavailable with custom elements
      // https://forum.typst.app/t/how-to-reference-styled-figures/5947
      #figure(
        img,
        caption: caption,
        supplement: [図],
        numbering: image_num,
        kind: "image",
        placement: placement,
      )#label
    ]
  }
}

// Definition of abstruct page
#let abstract_page(abstract_ja, abstract_en, keywords_ja: (), keywords_en: ()) = {
  if abstract_ja != [] {
    show <_ja_abstract_>: {
      align(center)[
        #text(
          font: section-fonts,
          size: 20pt,
          weight: "bold",
        )[
          概 #h(5pt) 要
        ]
      ]
    }

    [= 概要 <_ja_abstract_>]

    v(10pt)

    // Configure paragraph properties.
    set text(size: 12pt)
    set par(leading: 0.8em, first-line-indent: (all: true, amount: 20pt), justify: true)
    set par(spacing: 1.2em)
    abstract_ja

    if keywords_ja != () {
      par(first-line-indent: 0em)[
        #text(
          font: body-fonts,
          weight: "bold",
          size: 12pt,
        )[
          キーワード:
          #keywords_ja.join(", ")
        ]
      ]
    }
    // pagebreak()
  }

  if abstract_en != [] {
    show <_en_abstract_>: {
      align(center)[
        #text(
          font: body-fonts,
          size: 18pt,
          "Abstruct",
        )
      ]
    }
    [= Abstract <_en_abstract_>]

    set text(size: 12pt)
    h(1em)
    abstract_en
    par(first-line-indent: 0em)[
      #text(
        font: body-fonts,
        weight: "bold",
        size: 12pt,
      )[
        Key Words:
        #keywords_en.join("; ")
      ]
    ]
    // pagebreak()
  }
}

// Definition of content to string
#let to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// Definition of chapter outline
#let toc() = {
  align(center)[
    #text(
      font: section-fonts,
      size: 20pt,
      weight: "bold",
    )[
      #v(20pt)
      目 #h(5pt) 次
      #v(10pt)
    ]
  ]

  set text(size: 12pt)
  set par(leading: 1em, first-line-indent: 0pt)
  context {
    let elements = query(heading.where(outlined: true))
    for el in elements {
      // Use roman numerals only for headings physically before the TOC call.
      let before_toc = query(heading.where(outlined: true).before(here())).find(one => one == el) != none
      let page_num = if before_toc {
        numbering("i", counter(page).at(el.location()).first())
      } else {
        counter(page).at(el.location()).first()
      }

      link(el.location())[#{
        let chapt_num = if el.numbering != none {
          heading_label(el.location())
        } else { none }

        if el.level == 1 {
          set text(
            font: section-fonts,
            weight: "regular",
          )
          if chapt_num == none {} else {
            chapt_num
            h(1em)
          }
          let rebody = to-string(el.body)
          rebody
        } else if el.level == 2 {
          set text(
            font: body-fonts,
            weight: "regular",
          )
          h(1.5em)
          chapt_num
          h(0.5em)
          let rebody = to-string(el.body)
          rebody
        } else if el.level == 3 {
          set text(
            font: body-fonts,
            weight: "regular",
          )
          h(3em)
          chapt_num
          h(0.5em)
          let rebody = to-string(el.body)
          rebody
        } else {
          continue
        }
      }]
      box(width: 1fr, h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em))
      [p. #page_num]
      linebreak()
    }
  }
}

// Definition of image outline
#let toc_image() = {
  align(center)[
    #text(
      font: section-fonts,
      size: 20pt,
      weight: "bold",
    )[
      #v(20pt)
      図 #h(5pt) 目 #h(5pt) 次
      #v(10pt)
    ]
  ]

  set text(size: 12pt)
  set par(leading: 1em, first-line-indent: 0pt)
  context {
    let elements = query(figure.where(outlined: true, kind: "image"))
    for el in elements {
      let loc = el.location()
      let chapt = counter(heading).at(loc).at(0)
      let num = counter(el.kind + "-chapter" + str(chapt)).at(loc).at(0)
      let page_num = counter(page).at(loc).first()
      let caption_body = to-string(el.caption.body)
      [図 #(str(chapt) + "." + str(num))]
      h(1em)
      caption_body
      box(width: 1fr, h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em))
      [p. #page_num]
      linebreak()
    }
  }
}

// Definition of table outline
#let toc_table() = {
  align(center)[
    #text(
      font: section-fonts,
      size: 20pt,
      weight: "bold",
    )[
      #v(20pt)
      表 #h(5pt) 目 #h(5pt) 次
      #v(10pt)
    ]
  ]

  set text(size: 12pt)
  set par(leading: 1em, first-line-indent: 0pt)
  context {
    let elements = query(figure.where(outlined: true, kind: "table"))
    for el in elements {
      let chapt = counter(heading).at(el.location()).at(0)
      let num = counter(el.kind + "-chapter" + str(chapt)).at(el.location()).at(0)
      let page_num = counter(page).at(el.location()).first()
      let caption_body = to-string(el.caption.body)
      [表 #(str(chapt) + "." + str(num))]
      h(1em)
      caption_body
      box(width: 1fr, h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em))
      [p. #page_num]
      linebreak()
    }
  }
}

// Setting header
// ref: https://stackoverflow.com/questions/76363935/typst-header-that-changes-from-page-to-page-based-on-state
#let custom_header() = context [
  #set par(first-line-indent: 0pt)
  #let i = counter(page).get().first()
  #let ht-first = state("page-first-section", [])
  #let ht-last = state("page-last-section", [])

  // find first heading of level 1 on current page
  #let first-heading = query(heading.where(level: 1)).find(h => h.location().page() == locate(here()).page())

  // find last heading of level 1 on current page
  #let last-heading = query(heading.where(level: 1)).rev().find(h => h.location().page() == locate(here()).page())

  // don't show chapter numbering in header of bibliography page
  #let header-chapt-num(content) = {
    if content.numbering == none {
      return none
    }
    let label = heading_label(content.location())
    if label == none { none } else { [#label #h(10pt)] }
  }

  // test if the find function returned none (i.e. no headings on this page)
  #{
    if first-heading != none {
      ht-first.update([
        // change style here if update needed section per section
        #header-chapt-num(first-heading)
        #first-heading.body
      ])
      ht-last.update([
        // change style here if update needed section per section
        #header-chapt-num(last-heading)
        #last-heading.body
      ])
      // if one or more headings on the page, use first heading
      // change style here if update needed page per page
      context [#ht-first.get() #h(1fr)]
    } else {
      // no headings on the page, use last heading from variable
      // change style here if update needed page per page
      context [#ht-last.get() #h(1fr)]
    }
  }
  #v(3pt, weak: true)
  #line(length: 100%, stroke: 0.5pt + black)
]

#let bibliography_state = state("bibliography-state", (
  "file": none,
  "csl": none,
  "style": "hayagriva",
  "shown": false,
))

#let configure_bibliography(config) = {
  bibliography_state.update(_ => (
    "file": config.at("file", default: none),
    "csl": config.at("csl", default: none),
    "style": config.at("style", default: "hayagriva"),
    "shown": false,
  ))
}

// Route citations to the correct backend (hayagriva or pergamon) while allowing string keys everywhere.
#let cite(..args) = context {
  let style = bibliography_state.get().at("style", default: "hayagriva")
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
      // Adjacent citations are grouped by Typst; join with a space.
      cites.join([ ])
    }
  }
}

#let show-bibliography-hayagriva(bibfile, csl) = {
  // Bibliography headings should have no chapter prefix.
  prefix_mode.update("none")
  set par(
    leading: par-distance,
    spacing: par-distance,
    first-line-indent: 0pt,
    justify: true,
  )

  show bibliography: set text(12pt)
  show heading.where(level: 1): it => {
    pagebreak()
    counter(math.equation).update(0)
    set text(
      font: section-fonts,
      size: font_sizes.at("h1"),
    )
    text(weight: "bold")[
      #v(0.5em)
      #it.body
      #v(0.5em)
    ]
  }
  heading(level: 1, numbering: none)[参考文献]

  bibliography(
    bibfile,
    title: none,
    full: true,
    style: if csl != none {
      csl
    } else {
      "ieee"
    },
  )
}

#let show-bibliography-pergamon(bibliography-file) = {
  prefix_mode.update("none")
  set par(
    leading: par-distance,
    spacing: par-distance,
    first-line-indent: 0pt,
    justify: true,
  )

  show bibliography: set text(12pt)
  show heading.where(level: 1): it => {
    pagebreak()
    counter(math.equation).update(0)
    set text(
      font: section-fonts,
      size: font_sizes.at("h1"),
    )
    text(weight: "bold")[
      #v(0.5em)
      #it.body
      #v(0.5em)
    ]
  }

  print-bibliography(
    format-reference: format_reference_by_lang,
    label-generator: pergamon_style.label-generator,
    sorting: reference => reference.fields.at("sortkey", default: reference.entry_key),
    title: "参考文献",
  )
}

#let render_bibliography_if_needed() = context {
  let config = bibliography_state.get()
  if config.at("file") == none or config.at("shown") {
    return none
  }

  // Bibliography may be rendered outside appendix; ensure header & numbering stay in main style.
  set page(header: custom_header(), numbering: "1")

  let bibfile = config.at("file")
  let bibstyle = config.at("style", default: "hayagriva")
  if bibstyle == "hayagriva" {
    show-bibliography-hayagriva(bibfile, config.at("csl"))
  } else if bibstyle == "pergamon" {
    show-bibliography-pergamon(bibfile)
  }
  bibliography_state.update(conf => {
    conf.at("shown") = true
    conf
  })
}

#let set_common_subheadings(body) = {
  show heading.where(level: 2): it => block({
    set par(first-line-indent: 0pt)
    set text(
      font: section-fonts,
      size: font_sizes.at("h2"),
    )
    [
      #text(weight: "semibold")[#heading_label(it.location())]
      #h(0.8em)
      #text(weight: "regular")[ #it.body ]
    ]
  })

  show heading.where(level: 3): it => block({
    set par(first-line-indent: 0pt)
    set text(
      font: section-fonts,
      weight: "regular",
      size: font_sizes.at("h3"),
    )
    text()[
      #heading_label(it.location()) #h(0.8em) #it.body
    ]
  })

  show heading.where(level: 4): it => block({
    set par(first-line-indent: 0pt)
    set text(
      font: section-fonts,
      weight: "regular",
      size: font_sizes.at("under_h4"),
    )
    text()[
      #it.body
    ]
  })

  show heading: it => (
    {
      set par(first-line-indent: 0pt)
      set text(
        font: section-fonts,
        weight: "regular",
        size: font_sizes.at("under_h4"),
      )
      set block(above: 2em, below: 1.5em)
      it
    }
  )

  body
}

#let appendix_setup() = context {
  render_bibliography_if_needed()

  // Switch to appendix mode globally and restart heading/equation numbering.
  prefix_mode.update("appendix")
  counter(heading).update(0)
  counter(math.equation).update(0)

  set page(header: custom_header(), numbering: "1")
}

#let appendix(body) = {
  appendix_setup()
  [#body]
}

// Start appendix mode from this point onward without needing a closing bracket.
#let appendix_start() = {
  appendix_setup()
  none
}

// Zero-width marker for the new syntax: write `#Appendix` (or `#Appendix[]`) where
// the appendix should start. The old `#appendix[ ... ]` form still works.
#let Appendix = {
  appendix_start()
  []
}

#let main-chapter-pages(body) = {
  set page(
    header: custom_header(),
    numbering: "1",
  )

  counter(page).update(1)

  set math.equation(supplement: [式], numbering: equation_num)

  let before_h1(it) = {
    let label = heading_label(it.location())
    if label != none {
      text()[#label #h(1em)]
    }
  }

  show heading.where(level: 1): it => {
    set par(first-line-indent: 0pt)
    pagebreak()
    counter(math.equation).update(0)
    set text(
      font: section-fonts,
      size: font_sizes.at("h1"),
    )
    set block(spacing: 1.5em)
    let label = before_h1(it)
    text(weight: "bold", size: font_sizes.h2)[
      #v(10pt)
      #if label != none { label + linebreak() }
    ]
    text(weight: "bold", size: font_sizes.h1 + 2pt)[
      #it.body
      #v(10pt)
    ]
  }

  set_common_subheadings(body)
}

// Construction of paper
#let master_thesis(
  // The master thesis title.
  title: "ここにtitleが入る",
  subtitle: none,
  // The paper`s author
  author: "ここに著者が入る",
  // The author's information
  university: "",
  school: "",
  department: "",
  id: "",
  mentor: "",
  mentor-post: "",
  class: "修士",
  date: (datetime.today().year(), datetime.today().month(), datetime.today().day()),
  year: datetime.today().year(), // 提出年度（提出日時が必要ない場合に使う）
  paper-type: "論文",
  // Abstruct
  abstract_ja: [],
  abstract_en: [],
  keywords_ja: (),
  keywords_en: (),
  // The paper size to use.
  paper-size: "a4",
  // The path to a bibliography file if you want to cite some external works.
  bibliography: (
    file: none,
    style: "hayagriva", // "hayagriva" or "pergamon"
    csl: none,
  ),
  enable_toc_of_image: false,
  enable_toc_of_table: false,
  // The paper's content.
  body,
) = {
  // Set the document's metadata.
  set document(title: title, author: author)

  configure_bibliography(bibliography)
  let bibliography_file = bibliography.at("file", default: none)
  let bibliography_style = bibliography.at("style", default: "hayagriva")

  // Set the body font.
  set text(font: body-fonts, size: font_sizes.at("normal"))
  show strong: set text(font: strong-fonts)

  // Set font size.
  show footnote: set text(15pt)
  show footnote.entry: set text(size: 10pt)
  show math.equation: set text(font_sizes.at("math"))

  // Set indents.
  set list(indent: 25pt)
  set enum(indent: 25pt)
  show list: set par(spacing: 2em)
  show math.equation.where(block: true): set par(spacing: 1.5em)

  // https://github.com/typst/typst/discussions/4448?utm_source=chatgpt.com#discussioncomment-9913935
  show footnote: it => {
    let num = numbering(it.numbering, ..counter(footnote).at(here()))
    box(width: measure[1].width, super(num))
  }
  show footnote.entry: it => {
    set par(justify: false)
    let loc = it.note.location()
    let num = numbering("注1.", ..counter(footnote).at(loc))
    [#h(1em) #num #it.note.body]
  }

  // Configure the page properties.
  set page(
    paper: paper-size,
    margin: (
      top: 3cm,
      left: 3cm,
      right: 3cm,
      bottom: 2.5cm,
    ),
  )

  // citation number
  show ref: it => {
    if it.element != none and it.element.func() == figure {
      let el = it.element
      let loc = el.location()
      let chapt = counter(heading).at(loc).at(0)

      link(loc)[#if el.kind == "image" or el.kind == "table" {
          // counting
          let num = counter(el.kind + "-chapter" + str(chapt)).at(loc).at(0)
          it.element.supplement
          " "
          str(chapt)
          "."
          str(num)
        } else if el.kind == "thmenv" {
          let thms = query(selector(<meta:thmenvcounter>))
          let number = thmcounters.at(thms.first().location()).at("latest")
          it.element.supplement
          " "
          numbering(it.element.numbering, ..number)
        } else {
          it
        }
      ]
    } else if it.element != none and it.element.func() == math.equation {
      let el = it.element
      let loc = el.location()
      let chapt = counter(heading).at(loc).at(0)
      let num = counter(math.equation).at(loc).at(0)

      it.element.supplement
      " ("
      str(chapt)
      "."
      str(num)
      ")"
    } else if it.element != none and it.element.func() == heading {
      let el = it.element
      heading_label(el.location())
    } else {
      it
    }
  }

  // Display inline code in a small box
  // that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Display block code in a larger block
  // with more padding.
  show raw.where(block: true): block.with(
    fill: luma(240),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
  )

  // The first page.
  align(center)[
    #set text(font: body-fonts)

    #v(80pt)
    #text(size: font_sizes_cover.at("normal"))[
      #class#paper-type
    ]
    #v(40pt)
    #text(font: title-fonts, weight: "medium")[
      #text(size: font_sizes_cover.at("title"))[#title]
      #if subtitle != none {
        v(10pt)
        text(size: font_sizes_cover.at("subtitle"))[#subtitle]
      }
    ]
    #v(150pt)
    #text(size: font_sizes_cover.at("normal"))[
      #if (year != none) {
        text()[#year 年度]
      }

      #university #school #department

      #id #v(0pt) #author
    ]

    #if (mentor != "" or mentor-post != "") {
      text(size: font_sizes_cover.at("normal"))[
        指導教員 : #mentor #mentor-post
      ]
    }

    #v(40pt)
    #if (date != none) {
      text(size: font_sizes_cover.at("normal"))[#date.at(0) 年 #date.at(1) 月 #date.at(2) 日 提出]
    }

    #pagebreak()
  ]

  set page(numbering: "i")

  counter(page).update(1)

  // Show abstruct
  abstract_page(abstract_ja, abstract_en, keywords_ja: keywords_ja, keywords_en: keywords_en)

  set heading(numbering: "1.")

  // Start with a chapter outline.
  toc()
  if enable_toc_of_image or enable_toc_of_table {
    pagebreak()
  }
  if enable_toc_of_image {
    toc_image()
  }
  if enable_toc_of_table {
    toc_table()
  }

  if bibliography_file != none and bibliography_style == "pergamon" {
    add-bib-resource(read(bibliography_file))

    refsection(format-citation: pergamon_style.format-citation)[
      // 本文だけに段落設定を適用
      #context {
        set par(
          leading: par-distance,
          spacing: par-distance,
          first-line-indent: (all: true, amount: 20pt),
          justify: true,
        )
        main-chapter-pages(body)
      }

      #render_bibliography_if_needed()
    ]
  } else {
    // 本文だけに段落設定を適用
    context {
      set par(
        leading: par-distance,
        spacing: par-distance,
        first-line-indent: (all: true, amount: 20pt),
        justify: true,
      )
      main-chapter-pages(body)
    }

    if bibliography_file != none and bibliography_style == "hayagriva" {
      render_bibliography_if_needed()
    }
  }
}

// LATEX character
#let LATEX = {
  [L]
  box(move(
    dx: -4.2pt,
    dy: -1.2pt,
    box(scale(65%)[A]),
  ))
  box(move(
    dx: -5.7pt,
    dy: 0pt,
    [T],
  ))
  box(move(
    dx: -7.0pt,
    dy: 2.7pt,
    box(scale(100%)[E]),
  ))
  box(move(
    dx: -8.0pt,
    dy: 0pt,
    [X],
  ))
  h(-8.0pt)
}
