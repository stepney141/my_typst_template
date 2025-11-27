// https://github.com/ut-khanlab/master_thesis_template_for_typst

// Set font sizes
#let font_sizes = (
  h1: 18pt,
  h2: 16pt,
  h3: 14pt,
  under_h4: 12pt,
  normal: 11pt,
  math: 12pt,
)

// Store theorem environment numbering
#let thmcounters = state("thm", (
  "counters": ("heading": ()),
  "latest": (),
))

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
    str(chapt) + "." + str(n + 1)
  }
}

// Counting image number
#let image_num(_) = {
  context {
    let chapt = counter(heading).get().at(0)
    let c = counter("image-chapter" + str(chapt))
    let n = c.get().at(0)
    str(chapt) + "." + str(n + 1)
  }
}

// Definition of table format
#let tbl(tbl, caption: "") = {
  figure(
    tbl,
    caption: caption,
    supplement: [表],
    numbering: table_num,
    kind: "table",
  )
}

// Definition of image format
#let img(img, caption: "") = {
  figure(
    img,
    caption: caption,
    supplement: [図],
    numbering: image_num,
    kind: "image",
  )
}

// Definition of abstruct page
#let abstract_page(abstract_ja, abstract_en, keywords_ja: (), keywords_en: ()) = {
  if abstract_ja != [] {
    show <_ja_abstract_>: {
      align(center)[
        #text(
          font: (
            "Times New Roman",
            "IPAPGothic",
          ),
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
    set par(leading: 0.8em, first-line-indent: 20pt, justify: true)
    set par(spacing: 1.2em)
    abstract_ja

    if keywords_ja != () {
      par(first-line-indent: 0em)[
        #text(
          font: (
            "Times New Roman",
            "Source Han Serif JP",
          ),
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
          font: (
            "Times New Roman"
          ),
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
        font: (
          "Times New Roman"
        ),
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
      font: (
        "Times New Roman",
        "IPAPGothic",
      ),
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
      let before_toc = query(heading.where(outlined: true).before(here())).find(one => { one.body == el.body }) != none
      let page_num = if before_toc {
        numbering("i", counter(page).at(el.location()).first())
      } else {
        counter(page).at(el.location()).first()
      }

      link(el.location())[#{
        // acknoledgement has no numbering
        let chapt_num = if el.numbering != none {
          numbering(el.numbering, ..counter(heading).at(el.location()))
        } else { none }

        if el.level == 1 {
          set text(
            font: (
              "Times New Roman",
              "UDEV Gothic",
            ),
            weight: "bold",
          )
          if chapt_num == none {} else {
            set text(
              font: (
                "Times New Roman",
                "UDEV Gothic",
              ),
              weight: "bold",
            )
            chapt_num
            h(1em)
          }
          let rebody = to-string(el.body)
          rebody
        } else if el.level == 2 {
          set text(
            font: (
              "Times New Roman",
              "Source Han Serif JP",
            ),
            weight: "regular",
          )
          h(2em)
          chapt_num
          let rebody = to-string(el.body)
          rebody
        } else {
          set text(
            font: (
              "Times New Roman",
              "Source Han Serif JP",
            ),
            weight: "regular",
          )
          h(4em)
          chapt_num
          let rebody = to-string(el.body)
          rebody
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
      font: (
        "Times New Roman",
        "IPAPGothic",
      ),
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
      let num = counter(el.kind + "-chapter" + str(chapt)).at(loc).at(0) + 1
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
      font: (
        "Times New Roman",
        "IPAPGothic",
      ),
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
      let num = counter(el.kind + "-chapter" + str(chapt)).at(el.location()).at(0) + 1
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

// Setting empty par
#let empty_par() = {
  v(-1em)
  box()
}

// Setting header
// ref: https://stackoverflow.com/questions/76363935/typst-header-that-changes-from-page-to-page-based-on-state
#let custom_header() = context [
  #let i = counter(page).get().first()
  #let ht-first = state("page-first-section", [])
  #let ht-last = state("page-last-section", [])

  // find first heading of level 1 on current page
  #let first-heading = query(heading.where(level: 1)).find(h => h.location().page() == locate(here()).page())

  // find last heading of level 1 on current page
  #let last-heading = query(heading.where(level: 1)).rev().find(h => h.location().page() == locate(here()).page())

  // don't show chapter numbering in header of bibliography page
  #let header-chapt-num(content) = {
    let bibliography-content = query(bibliography).at(0)

    if not content.at("body") == bibliography-content.at("title") {
      return [
        #numbering(content.numbering, ..counter(heading).at(content.location()))
        #h(10pt)
      ]
    } else {
      return none
    }
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

#let appendix(body) = {
  counter(heading).update(0)
  counter("appendix").update(1)

  set heading(numbering: (..nums) => {
    let vals = nums.pos()
    let value = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(vals.at(0) - 1)
    if vals.len() == 1 {
      return [付録 #value]
    } else {
      return [#(value + "." + nums.pos().slice(1).map(str).join(".")) #h(0.5em)]
    }
  })

  set page(
    header: custom_header(),
  )

  let before_h1(it) = if it.numbering != none {
    text()[
      #v(10pt)
      #numbering(it.numbering, ..counter(heading).at(it.location()))
    ]
  } else {
    none
  }

  show heading.where(level: 1): it => {
    pagebreak()
    counter(math.equation).update(0)
    set text(
      font: ("Times New Roman", "UDEV Gothic"),
      weight: "bold",
      size: font_sizes.at("h1"),
    )
    set block(spacing: 1.5em)
    text()[
      #before_h1(it) #linebreak() #it.body #v(0pt)
    ]
  }

  show heading.where(level: 2): it => block({
    set text(
      font: ("Times New Roman", "UDEV Gothic"),
      weight: "medium",
      size: font_sizes.at("h2"),
    )
    text()[
      #it
    ]
  })

  [#body]
}

#let show-bibliography-default(bibliography-file, bibliography-csl-path) = {
  show bibliography: set text(12pt)
  show heading.where(level: 1): it => {
    pagebreak()
    counter(math.equation).update(0)
    set text(
      font: ("Times New Roman", "UDEV Gothic"),
      size: font_sizes.at("h1"),
    )
    text(weight: "bold")[#it.body]
  }

  bibliography(
    bibliography-file,
    title: "参考文献",
    style: if bibliography-csl-path != none {
      bibliography-csl-path
    } else {
      "ieee"
    },
  )
}

// Construction of paper
#let master_thesis(
  // The master thesis title.
  title: "ここにtitleが入る",
  // The paper`s author.
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
  paper-type: "論文",
  // Abstruct
  abstract_ja: [],
  abstract_en: [],
  keywords_ja: (),
  keywords_en: (),
  // The paper size to use.
  paper-size: "a4",
  // The path to a bibliography file if you want to cite some external
  // works.
  bibliography-file: none,
  bibliography-csl-path: none,
  enable_toc_of_image: true,
  enable_toc_of_table: true,
  // The paper's content.
  body,
) = {
  // Set the document's metadata.
  set document(title: title, author: author)

  // Set the body font. TeX Gyre Pagella is a free alternative
  // to Palatino.
  set text(
    font: ("Times New Roman", "Source Han Serif JP"),
    size: font_sizes.at("normal"),
  )
  show strong: set text(
    font: ("Times New Roman", "IPAPGothic"),
  )

  // Set font size
  show footnote.entry: set text(10pt)
  show footnote: set text(15pt)
  show math.equation: set text(font_sizes.at("math"))


  set list(indent: 7pt)
  set enum(indent: 7pt)

  // Configure the page properties.
  set page(
    paper: paper-size,
    margin: (
      bottom: 1.75cm,
      top: 2.5cm,
      left: 2cm,
      right: 2cm,
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
          let num = counter(el.kind + "-chapter" + str(chapt)).at(loc).at(0) + 1
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
      let loc = el.location()
      let num = numbering(el.numbering, ..counter(heading).at(loc))
      if el.level == 1 {
        str(num)
        "章"
      } else if el.level == 2 {
        str(num)
        "節"
      } else if el.level == 3 {
        str(num)
        "項"
      }
    } else {
      it
    }
  }

  // counting caption number
  show figure: it => {
    set align(center)
    if it.kind == "image" {
      set text(size: 12pt)
      it.body
      it.supplement
      " " + it.counter.display(it.numbering)
      " " + it.caption.body
      context {
        let chapt = counter(heading).at(it.location()).at(0)
        let c = counter("image-chapter" + str(chapt))
        c.step()
      }
    } else if it.kind == "table" {
      set text(size: 12pt)
      it.supplement
      " " + it.counter.display(it.numbering)
      " " + it.caption.body
      set text(size: 10.5pt)
      it.body
      context {
        let chapt = counter(heading).at(it.location()).at(0)
        let c = counter("table-chapter" + str(chapt))
        c.step()
      }
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
    #set text(
      font: ("Times New Roman", "Source Han Serif JP"),
    )

    #v(80pt)
    #text(size: 16pt)[
      #university #school #department
    ]

    #text(size: 16pt)[
      #class#paper-type
    ]
    #v(40pt)
    #text(
      size: 22pt,
      font: ("Times New Roman", "IPAPGothic"),
      weight: "bold",
    )[
      #title
    ]
    #v(50pt)
    #text(size: 16pt)[
      #id #v(0pt) #author
    ]

    #if (mentor != "" or mentor-post != "") {
      text(size: 16pt)[
        指導教員: #mentor #mentor-post
      ]
    }

    #v(40pt)
    #text(size: 16pt)[
      #date.at(0) 年 #date.at(1) 月 #date.at(2) 日 提出
    ]

    #pagebreak()
  ]

  set page(
    numbering: "i",
  )

  counter(page).update(1)

  // Show abstruct
  abstract_page(abstract_ja, abstract_en, keywords_ja: keywords_ja, keywords_en: keywords_en)

  // Configure paragraph properties.
  set par(leading: 0.8em, first-line-indent: 20pt, justify: true)
  set par(spacing: 1.2em)

  // Configure chapter headings.
  set heading(numbering: (..nums) => {
    if nums.pos().len() == 1 {
      return [第 #nums.pos().map(str).join(".") 章]
    } else {
      return [#nums.pos().map(str).join(".") #h(0.5em)]
    }
  })

  let before_h1(it) = if it.numbering != none {
    text()[
      #numbering(it.numbering, ..counter(heading).at(it.location()))
      #h(1em)
    ]
  }

  show heading.where(level: 1): it => {
    pagebreak()
    counter(math.equation).update(0)
    set text(
      font: ("Times New Roman", "UDEV Gothic"),
      size: font_sizes.at("h1"),
    )
    set block(spacing: 1.5em)
    text(weight: "bold")[
      #v(10pt)
      #before_h1(it)
      #linebreak()
    ]
    text(weight: "bold")[#it.body]
  }

  show heading.where(level: 2): it => block({
    set text(
      font: ("Times New Roman", "UDEV Gothic"),
      weight: "medium",
      size: font_sizes.at("h2"),
    )
    text()[
      #it
    ]
  })

  show heading.where(level: 3): it => block({
    set text(
      font: ("Times New Roman", "UDEV Gothic"),
      weight: "medium",
      size: font_sizes.at("h3"),
    )
    text()[
      #it
    ]
  })

  show heading: it => (
    {
      set text(
        font: ("Times New Roman", "UDEV Gothic"),
        weight: "bold",
        size: font_sizes.at("under_h4"),
      )
      set block(above: 2em, below: 1.5em)
      it
    }
      + empty_par()
  ) // 最初の段落のインデントを下げるためにダミーの段落を設置する


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

  // Start main pages.
  set page(
    header: custom_header(),
    numbering: "1",
  )

  counter(page).update(1)

  set math.equation(supplement: [式], numbering: equation_num)

  body

  // Display bibliography.
  if bibliography-file != none {
    show-bibliography-default(bibliography-file, bibliography-csl-path)
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
