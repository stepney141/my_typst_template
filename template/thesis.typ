// https://github.com/ut-khanlab/master_thesis_template_for_typst

#import "./common/body.typ" as common-body
#import "./common/page.typ" as common-page
#import "./bibliography.typ" as bibliography-support

// Set font sizes
#let font-sizes = (
  h1: 18pt,
  h2: 16pt,
  h3: 14pt,
  under-h4: 12pt,
  normal: 11pt,
  math: 12pt,
)
#let font-sizes-cover = (
  title: 22pt,
  subtitle: 20pt,
  normal: 17pt,
)

// Configure paragraph properties.
#let par-distance = 0.9em
// 字下げ; 日本語は1文字分
#let first-line-indent = (
  ja: 1em,
  en: 20pt,
)

// Set fonts.
// TeX Gyre Pagella is a free alternative to Palatino.
#let body-fonts = ("Nimbus Roman", "Source Han Serif JP") // serif
#let strong-fonts = ("Nimbus Roman", "IPAPGothic") // en: serif, ja: sans serif
#let section-fonts = ("Inter", "UDEV Gothic 35JPDOC") // sans serif
#let title-fonts = ("Nimbus Roman", "UDEV Gothic 35JPDOC") // en: serif, ja: sans serif

#let thesis-body-config = (
  text: (
    font: body-fonts,
    size: font-sizes.at("normal"),
  ),
  strong: (font: strong-fonts),
  list: (indent: 25pt),
  list-par: (spacing: 2em),
  enum: (indent: 25pt),
  enum-par: (spacing: 2em),
  block-equation-par: (spacing: 1.5em),
)

#let thesis-paragraph-config = (
  leading: par-distance,
  spacing: par-distance,
  first-line-indent: (all: true, amount: first-line-indent.ja),
  justify: true,
)

#let thesis-page-config(paper-size) = (
  paper: paper-size,
  margin: (
    top: 3cm,
    left: 3cm,
    right: 3cm,
    bottom: 2.5cm,
  ),
)

// Store theorem environment numbering
#let thm-counters = state("thm", (
  "counters": ("heading": ()),
  "latest": (),
))

// Track prefix mode for chapter headings (used for headings, TOC, refs).
// Values: "main" | "appendix" | "none"
#let prefix-mode = state("prefix-mode", "main")

#let heading-label(loc) = {
  let vals = counter(heading).at(loc)
  if vals.len() == 0 {
    return none
  }
  let mode = prefix-mode.at(loc)
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

// Chapter prefix for numbering (e.g. "1" in main, "A" in appendix).
#let chapter-prefix(loc) = {
  let vals = counter(heading).at(loc)
  if vals.len() == 0 {
    return "0"
  }
  let head = vals.at(0)
  let mode = prefix-mode.at(loc)
  if mode == "appendix" {
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(head - 1)
  } else {
    str(head)
  }
}

// Format theorem numbers with appendix-aware chapter prefix.
#let thm-numbering(numbering-spec, nums, loc) = {
  if numbering-spec == none {
    return none
  }
  if prefix-mode.at(loc) == "appendix" {
    if nums.len() == 0 {
      return none
    }
    let head = chapter-prefix(loc)
    if nums.len() == 1 {
      head
    } else {
      head + "." + nums.slice(1).map(str).join(".")
    }
  } else {
    numbering(numbering-spec, ..nums)
  }
}

// Setting theorem environment
#let thm-env(identifier, base, base-level, fmt) = {
  let global-numbering = numbering

  return (
    ..args,
    body,
    number: auto,
    numbering: "1.1",
    ref-numbering: auto,
    supplement: identifier,
    base: base,
    base-level: base-level,
  ) => {
    let name = none
    if args != none and args.pos().len() > 0 {
      name = args.pos().first()
    }
    if ref-numbering == auto {
      ref-numbering = numbering
    }
    let result = none
    if number == auto and numbering == none {
      number = none
    }
    if number == auto and numbering != none {
      result = context {
        let heading-counter = counter(heading).get()
        return thm-counters.update(thm-pair => {
          let counters = thm-pair.at("counters")
          // Manually update heading counter
          counters.at("heading") = heading-counter
          if not identifier in counters.keys() {
            counters.insert(identifier, (0,))
          }

          let tc = counters.at(identifier)
          if base != none {
            let bc = counters.at(base)

            // Pad or chop the base count
            if base-level != none {
              if bc.len() < base-level {
                bc = bc + (0,) * (base-level - bc.len())
              } else if bc.len() > base-level {
                bc = bc.slice(0, base-level)
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
        let nums = thm-counters.get().at("latest")
        thm-numbering(numbering, nums, here())
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
      numbering: ref-numbering,
    )
  }
}

// Definition of theorem box
#let thm-box(
  identifier,
  head,
  ..block-args,
  supplement: auto,
  padding: (top: 0.5em, bottom: 0.5em),
  name-fmt: x => [(#x)],
  title-fmt: strong,
  body-fmt: x => x,
  separator: [#h(0.1em):#h(0.2em)],
  base: "heading",
  base-level: none,
) = {
  if supplement == auto {
    supplement = head
  }
  let box-fmt(name, number, body, title: auto) = {
    if not name == none {
      name = [ #name-fmt(name)]
    } else {
      name = []
    }
    if title == auto {
      title = head
    }
    if not number == none {
      title += " " + number
    }
    title = title-fmt(title)
    body = body-fmt(body)
    set par(first-line-indent: 0pt)
    pad(
      ..padding,
      block(
        width: 100%,
        inset: 1.2em,
        radius: 0.3em,
        breakable: false,
        ..block-args.named(),
        [#title#name#separator#body],
      ),
    )
  }
  return thm-env(
    identifier,
    base,
    base-level,
    box-fmt,
  ).with(
    supplement: supplement,
  )
}

// Setting plain version
#let thm-plain = thm-box.with(
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  inset: (top: 0em, left: 1.2em, right: 1.2em),
  name-fmt: name => emph([(#name)]),
  title-fmt: emph,
  body-fmt: body => {
    // fix indents in the theorems
    set list(indent: 10pt)
    set enum(indent: 10pt)
    body
  },
)

#let definition = thm-plain(
  "definition", //identifier
  "定義",
  base-level: 1,
  // stroke: black + 1pt,
  title-fmt: strong,
  name-fmt: name => [(#name)],
  // inset: (left: 20pt, right: 0em),
  padding: (top: 0.5em, bottom: 1em),
)

#let theorem = thm-plain(
  "theorem", //identifier
  "定理",
  title-fmt: strong,
  base-level: 1,
  // inset: (left: 20pt, right: 0em),
  padding: (top: 0.5em),
)

#let lemma = thm-plain(
  "lemma", //identifier
  "補題",
  title-fmt: strong,
  base-level: 1,
  // inset: (left: 20pt, right: 0em),
  padding: (top: 0.5em),
)

#let proof = thm-plain(
  "proof", // identifier
  "証明",
  title-fmt: strong,
  base-level: 1,
  // inset: (left: 20pt, right: 0em),
  padding: (bottom: 0.5em),
).with(
  numbering: none,
)

// Counting equation number
#let equation-num(_) = {
  context {
    let chapt = chapter-prefix(here())
    let c = counter(math.equation)
    let n = c.get().at(0)
    "(" + str(chapt) + "." + str(n) + ")"
  }
}

// Counting table number
#let table-num(_) = {
  context {
    let chapt = chapter-prefix(here())
    let c = counter("table-chapter" + chapt)
    let n = c.get().at(0)
    chapt + "." + str(n)
  }
}

// Counting image number
#let image-num(_) = {
  context {
    let chapt = chapter-prefix(here())
    let c = counter("image-chapter" + chapt)
    let n = c.get().at(0)
    chapt + "." + str(n)
  }
}

#let gap-between-figures = 1.5em

// Definition of image format
#let img(img, caption: "", label: none, placement: auto, gap: 1em) = {
  context {
    let chapt = chapter-prefix(here())
    counter("image-chapter" + chapt).step()

    set figure.caption(separator: [ ^---^ ])
    // To prevent page break between figure body and caption
    // https://github.com/typst/typst/issues/5357
    show figure: it => {
      set block(sticky: true)
      it
    }

    // reference statements are unavailable with custom elements
    // https://forum.typst.app/t/how-to-reference-styled-figures/5947
    let fig-body = [
      #figure(
        img,
        caption: caption,
        supplement: [図],
        numbering: image-num,
        kind: "image",
        placement: none,
        gap: gap,
      )#label
    ]
    let fig-block = block(width: 100%)[
      #align(center)[#fig-body]
    ]

    if placement == none {
      block(above: gap-between-figures, below: gap-between-figures)[#fig-block]
    } else {
      place(placement, float: true, clearance: gap-between-figures)[#fig-block]
    }
  }
}

// Definition of table format
#let tbl(tbl, caption: "", label: none, placement: auto) = {
  context {
    let chapt = chapter-prefix(here())
    counter("table-chapter" + chapt).step()

    set figure.caption(separator: [ ^---^ ])
    // To prevent page break between figure body and caption
    // https://github.com/typst/typst/issues/5357
    show figure: it => {
      set block(sticky: true)
      it
    }
    let tbl-body = [
      #figure(
        tbl,
        caption: caption,
        supplement: [表],
        numbering: table-num,
        kind: "table",
        placement: placement,
        gap: 1em,
      )#label
    ]

    let tbl-block = block(width: 100%)[
      #align(center)[#tbl-body]
    ]

    if placement == none {
      block(above: gap-between-figures, below: gap-between-figures)[#tbl-block]
    } else {
      place(placement, float: true, clearance: gap-between-figures)[#tbl-block]
    }
  }
}

// Definition of abstruct page
#let abstract-page(abstract-ja, abstract-en, keywords-ja: (), keywords-en: ()) = {
  if abstract-ja != [] {
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
    set par(leading: 0.8em, first-line-indent: (all: true, amount: first-line-indent.ja), justify: true)
    set par(spacing: 1.2em)
    abstract-ja

    if keywords-ja != () {
      par(first-line-indent: 0em)[
        #text(
          font: body-fonts,
          weight: "bold",
          size: 12pt,
        )[
          キーワード:
          #keywords-ja.join(", ")
        ]
      ]
    }
    // pagebreak()
  }

  if abstract-en != [] {
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
    abstract-en
    par(first-line-indent: 0em)[
      #text(
        font: body-fonts,
        weight: "bold",
        size: 12pt,
      )[
        Key Words:
        #keywords-en.join("; ")
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
      let before-toc = query(heading.where(outlined: true).before(here())).find(one => one == el) != none
      let page-num = if before-toc {
        numbering("i", counter(page).at(el.location()).first())
      } else {
        counter(page).at(el.location()).first()
      }

      link(el.location())[#{
        let chapt-num = if el.numbering != none {
          heading-label(el.location())
        } else { none }

        if el.level == 1 {
          set text(
            font: section-fonts,
            weight: "regular",
          )
          v(0.5em)
          if chapt-num == none {} else {
            chapt-num
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
          chapt-num
          h(0.5em)
          let rebody = to-string(el.body)
          rebody
        } else if el.level == 3 {
          set text(
            font: body-fonts,
            weight: "regular",
          )
          h(3em)
          chapt-num
          h(0.5em)
          let rebody = to-string(el.body)
          rebody
        } else {
          continue
        }
      }]
      box(width: 1fr, h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em))
      [p. #page-num]
      linebreak()
    }
  }
}

// Definition of image outline
#let toc-image() = {
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
      let chapt = chapter-prefix(loc)
      let num = counter(el.kind + "-chapter" + chapt).at(loc).at(0)
      let page-num = counter(page).at(loc).first()
      let caption-body = to-string(el.caption.body)
      [図 #(chapt + "." + str(num))]
      h(1em)
      caption-body
      box(width: 1fr, h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em))
      [p. #page-num]
      linebreak()
    }
  }
}

// Definition of table outline
#let toc-table() = {
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
      let loc = el.location()
      let chapt = chapter-prefix(loc)
      let num = counter(el.kind + "-chapter" + chapt).at(loc).at(0)
      let page-num = counter(page).at(el.location()).first()
      let caption-body = to-string(el.caption.body)
      [表 #(chapt + "." + str(num))]
      h(1em)
      caption-body
      box(width: 1fr, h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em))
      [p. #page-num]
      linebreak()
    }
  }
}

// Setting header
// ref: https://stackoverflow.com/questions/76363935/typst-header-that-changes-from-page-to-page-based-on-state
#let custom-header() = context [
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
    let label = heading-label(content.location())
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

#let configure-bibliography(config) = bibliography-support.configure(config)

#let cite(..args) = bibliography-support.cite(..args)

#let render-bibliography-if-needed() = bibliography-support.render(
  prefix-mode: prefix-mode,
  paragraph-config: thesis-paragraph-config,
  section-fonts: section-fonts,
  heading-size: font-sizes.at("h1"),
  header: custom-header(),
)

#let set-common-subheadings(body) = {
  show heading.where(level: 2): it => block({
    set par(first-line-indent: 0pt)
    set text(
      font: section-fonts,
      size: font-sizes.at("h2"),
    )
    [
      #text(weight: "semibold")[#heading-label(it.location())]
      #h(0.8em)
      #text(weight: "regular")[ #it.body ]
    ]
  })

  show heading.where(level: 3): it => block({
    set par(first-line-indent: 0pt)
    set text(
      font: section-fonts,
      weight: "regular",
      size: font-sizes.at("h3"),
    )
    text()[
      #heading-label(it.location()) #h(0.8em) #it.body
    ]
  })

  show heading.where(level: 4): it => block({
    set par(first-line-indent: 0pt)
    set text(
      font: section-fonts,
      weight: "regular",
      size: font-sizes.at("under-h4"),
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
        size: font-sizes.at("under-h4"),
      )
      set block(above: 2em, below: 1.5em)
      it
    }
  )

  body
}

#let appendix-setup() = context {
  render-bibliography-if-needed()

  // Switch to appendix mode globally and restart heading/equation numbering.
  prefix-mode.update("appendix")
  counter(heading).update(0)
  counter(math.equation).update(0)

  set page(header: custom-header(), numbering: "1")
}

#let appendix(body) = {
  appendix-setup()
  [#body]
}

// Start appendix mode from this point onward without needing a closing bracket.
#let appendix-start() = {
  appendix-setup()
  none
}

#let main-chapter-pages(body) = {
  set page(
    header: custom-header(),
    numbering: "1",
  )

  counter(page).update(1)

  set math.equation(supplement: [式], numbering: equation-num)

  let before-h1(it) = {
    let label = heading-label(it.location())
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
      size: font-sizes.at("h1"),
    )
    set block(spacing: 0.5em)
    let label = before-h1(it)
    text(weight: "bold", size: font-sizes.h2)[
      #v(0.5em)
      #if label != none { label + linebreak() }
    ]
    text(weight: "bold", size: font-sizes.h1 + 2pt)[
      #it.body
      #v(0.5em)
    ]
  }

  set-common-subheadings(body)
}

// Construction of paper
#let master-thesis(
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
  abstract-ja: [],
  abstract-en: [],
  keywords-ja: (),
  keywords-en: (),
  // The paper size to use.
  paper-size: "a4",
  // The path to a bibliography file if you want to cite some external works.
  bibliography: (
    file: none,
    style: "hayagriva", // "hayagriva" or "pergamon"
    csl: none,
  ),
  enable-toc-of-image: false,
  enable-toc-of-table: false,
  // The paper's content.
  body,
) = {
  // Set the document's metadata.
  set document(title: title, author: author)

  configure-bibliography(bibliography)
  let bibliography-file = bibliography.at("file", default: none)
  let bibliography-style = bibliography.at("style", default: "hayagriva")

  show: common-body.apply.with(config: thesis-body-config)

  // Set font size.
  show footnote: set text(13pt)
  show footnote.entry: set text(size: 10pt)
  show math.equation: set text(font-sizes.at("math"))

  // https://zenn.dev/akamimi/articles/04d28e2f4fd602#comment-a90a634a9a321a
  show "^": h(0.25em, weak: true)

  // https://github.com/typst/typst/discussions/4448?utm_source=chatgpt.com#discussioncomment-9913935
  show footnote: it => {
    let num = numbering(it.numbering, ..counter(footnote).at(here()))
    box(width: measure["1"].width, super([注#num]))
  }
  show footnote.entry: it => {
    set par(justify: false)
    let loc = it.note.location()
    let num = numbering("注1.", ..counter(footnote).at(loc))
    [#h(1em) #num #it.note.body]
  }

  // Configure the page properties.
  show: common-page.apply.with(config: thesis-page-config(paper-size))

  // citation number
  show ref: it => {
    if it.element != none and it.element.func() == figure {
      let el = it.element
      let loc = el.location()
      let chapt = chapter-prefix(loc)

      link(loc)[#if el.kind == "image" or el.kind == "table" {
          // counting
          let num = counter(el.kind + "-chapter" + chapt).at(loc).at(0)
          it.element.supplement
          " "
          chapt
          "."
          str(num)
        } else if el.kind == "thmenv" {
          let meta = query(selector(<meta:thmenvcounter>).after(loc)).first()
          let number = if meta != none {
            thm-counters.at(meta.location()).at("latest")
          } else {
            thm-counters.at(loc).at("latest")
          }
          it.element.supplement
          " "
          thm-numbering(it.element.numbering, number, loc)
        } else {
          it
        }
      ]
    } else if it.element != none and it.element.func() == math.equation {
      let el = it.element
      let loc = el.location()
      let chapt = chapter-prefix(loc)
      let num = counter(math.equation).at(loc).at(0)

      it.element.supplement
      " ("
      chapt
      "."
      str(num)
      ")"
    } else if it.element != none and it.element.func() == heading {
      let el = it.element
      heading-label(el.location())
    } else {
      it
    }
  }

  // The first page.
  align(center)[
    #set text(font: body-fonts)

    #v(80pt)
    #text(size: font-sizes-cover.at("normal"))[
      #class#paper-type
    ]
    #v(40pt)
    #text(font: title-fonts, weight: "medium")[
      #text(size: font-sizes-cover.at("title"))[#title]
      #if subtitle != none {
        v(10pt)
        text(size: font-sizes-cover.at("subtitle"))[#subtitle]
      }
    ]
    #v(150pt)
    #text(size: font-sizes-cover.at("normal"))[
      #if (year != none) {
        text()[#year 年度]
      }

      #university #school #department

      #id #v(0pt) #author
    ]

    #if (mentor != "" or mentor-post != "") {
      text(size: font-sizes-cover.at("normal"))[
        指導教員 : #mentor #mentor-post
      ]
    }

    #v(40pt)
    #if (date != none) {
      text(size: font-sizes-cover.at("normal"))[#date.at(0) 年 #date.at(1) 月 #date.at(2) 日 提出]
    }

    #pagebreak()
  ]

  set page(numbering: "i")

  counter(page).update(1)

  // Show abstruct
  abstract-page(abstract-ja, abstract-en, keywords-ja: keywords-ja, keywords-en: keywords-en)

  set heading(numbering: "1.")

  // Start with a chapter outline.
  toc()
  if enable-toc-of-image or enable-toc-of-table {
    pagebreak()
  }
  if enable-toc-of-image {
    toc-image()
  }
  if enable-toc-of-table {
    toc-table()
  }

  if bibliography-file != none and bibliography-style == "pergamon" {
    bibliography-support.with-pergamon(
      {
      // 本文だけに段落設定を適用
      context {
        common-body.paragraph(
          main-chapter-pages(body),
          config: thesis-paragraph-config,
        )
      }

      render-bibliography-if-needed()
      },
      file: bibliography-file,
    )
  } else {
    // 本文だけに段落設定を適用
    context {
      common-body.paragraph(
        main-chapter-pages(body),
        config: thesis-paragraph-config,
      )
    }

    if bibliography-file != none and bibliography-style == "hayagriva" {
      render-bibliography-if-needed()
    }
  }
}

// latex character
#let latex = {
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
