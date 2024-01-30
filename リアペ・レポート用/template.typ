#let empty_par() = {
  v(-1em)
  box()
}

#let report(body) = {
  set text(
    font: (
      "Times New Roman",
      // "UDEV Gothic",
      "Source Han Serif JP"
    ),
    size: 13pt
  )

  set page(
    paper: "a4",
    margin: (
      bottom: 1.75cm, top: 2.5cm,
      left: 2cm, right: 2cm
    ),
  )

  set par(leading: 0.8em, first-line-indent: 20pt, justify: true)
  show par: set block(spacing: 1.4em)

  show heading.where(level: 1): it => {
    set text(
      weight: "bold",
      size: 20pt
    )
    text()[
      #it.body
    ]
  }

  show heading.where(level: 2): it => block({
    set text(
      weight: "medium",
      size: 17pt
    )
    text()[
      #it.body
    ]
  })

  show heading.where(level: 3): it => block({
    set text(
      weight: "medium",
      size: 15pt
    )
    text()[
      #it.body
    ]
  })

  show heading: it => {
    set text(
      weight: "medium",
      size: 12pt,
    )
    set block(above: 2em, below: 1.5em)
    it
  } + empty_par()

  set page(numbering: "1")

  body

}
