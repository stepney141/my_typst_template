#let fontMincho = "Source Han Serif JP"
#let fontGothic = ("Noto Sans", "UDEV Gothic")
#let fontLatin = "Times New Roman"

#let fontSizeDefault = 12pt
#let fontSizeHeading = 16pt

// ヘルパー関数
#let mathbf(str) = $ upright(bold(str)) $

#let empty_par() = {
  v(-1em)
  box()
}

#let name_box(id: "", name: "") = {
  set align(left)
  set text(size: 13pt)
  [
    #text(font: fontGothic)[*学籍番号*] : #text(font: (fontLatin, fontMincho))[#id]
    #parbreak()
    #text(font: fontGothic)[*氏名*] : #text(font: (fontLatin, fontMincho))[#name]
  ]
}

#let report(body) = {
  set text(
    font: (fontLatin, fontMincho),
    size: fontSizeDefault,
  )

  set page(
    paper: "a4",
    margin: (
      bottom: 1.75cm,
      top: 2.5cm,
      left: 2cm,
      right: 2cm,
    ),
  )

  set par(leading: 0.8em, first-line-indent: 20pt, justify: true)
  set par(spacing: 1.2em)

  show link: underline
  show link: set text(fill: rgb("#125ee0"))

  show strong: set text(
    font: fontGothic,
    weight: "medium",
  )

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

  show heading.where(level: 1): it => {
    set text(
      font: fontGothic,
      weight: "bold",
      size: 22pt,
    )
    text()[
      #it.body
    ]
  }

  show heading.where(level: 2): it => block({
    set text(
      font: fontGothic,
      weight: "semibold",
      size: fontSizeHeading,
    )
    text()[
      #it.body
    ]
  })

  show heading.where(level: 3): it => block({
    set text(
      font: fontGothic,
      weight: "medium",
      size: fontSizeDefault + 2pt,
    )
    text()[
      #it.body
    ]
  })

  show heading: it => (
    {
      set text(
        weight: "medium",
        size: fontSizeDefault,
      )
      set block(above: 2em, below: 1.5em)
      it
    }
      + empty_par()
  )

  set page(numbering: "1 / 1")

  body
}
