#import "./common/body.typ" as common-body
#import "./common/page.typ" as common-page

#let font-mincho = "Source Han Serif JP"
#let font-gothic = ("Noto Sans", "UDEV Gothic")
#let font-latin = "Times New Roman"

#let font-size-default = 12pt
#let font-size-heading = 16pt

#let report-body-config = (
  text: (
    font: (font-latin, font-mincho),
    size: font-size-default,
  ),
  strong: (
    font: font-gothic,
    weight: "medium",
  ),
  list: (indent: 25pt),
  list-par: (spacing: 2em),
  enum: (indent: 25pt),
  enum-par: (spacing: 2em),
  block-equation-par: (spacing: 1.5em),
  paragraph: (
    leading: 0.9em,
    spacing: 0.9em,
    first-line-indent: (all: true, amount: 1em),
    justify: true,
  ),
)

#let report-page-config = (
  paper: "a4",
  margin: (
    top: 2.5cm,
    left: 2cm,
    right: 2cm,
    bottom: 2.5cm,
  ),
)

// ヘルパー関数
#let mathbf(str) = $ upright(bold(str)) $

#let empty-par() = {
  v(-1em)
  box()
}

#let name-box(id: "", name: "") = {
  set align(left)
  set text(size: 13pt)
  [
    #text(font: font-gothic)[*学籍番号*] : #text(font: (font-latin, font-mincho))[#id]
    #parbreak()
    #text(font: font-gothic)[*氏名*] : #text(font: (font-latin, font-mincho))[#name]
  ]
}

#let report(body) = {
  show: common-body.apply.with(config: report-body-config)
  show: common-page.apply.with(config: report-page-config)

  set par(spacing: 1.2em)

  show link: underline
  show link: set text(fill: rgb("#125ee0"))

  // 数式関係のスタイル
  set math.equation(numbering: "(1)", number-align: bottom)
  show math.qed: math.square.stroked.big
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      numbering(
        "式 " + el.numbering,
        ..counter(eq).at(el.location()),
      )
    } else {
      // Other references as usual.
      it
    }
  }

  show heading.where(level: 1): it => block({
    set text(
      font: font-gothic,
      weight: "bold",
      size: 22pt,
    )
    text()[
      #it.body
    ]
  })

  show heading.where(level: 2): it => block(
    above: 2em,
    below: 1em,
    {
      set text(
        font: font-gothic,
        weight: "semibold",
        size: font-size-heading,
      )
      text()[
        #it.body
      ]
    },
  )

  show heading.where(level: 3): it => block({
    set text(
      font: font-gothic,
      weight: "medium",
      size: font-size-default + 2pt,
    )
    text()[
      #it.body
    ]
  })

  show heading: it => (
    {
      set text(
        weight: "medium",
        size: font-size-default,
      )
      it
    }
      + empty-par()
  )

  set page(numbering: "1 / 1")

  body
}
