// Shared body styling. Template-specific values stay in each template's config.
#let apply(body, config: (:)) = {
  set text(..config.at("text"))
  show strong: set text(..config.at("strong"))

  set list(..config.at("list"))
  show list: set par(..config.at("list-par"))
  set enum(..config.at("enum"))
  show enum: set par(..config.at("enum-par"))
  show math.equation.where(block: true): set par(..config.at("block-equation-par"))

  // Display inline code in a small box that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Display block code in a larger block with more padding.
  show raw.where(block: true): block.with(
    fill: luma(240),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
  )

  let paragraph-config = config.at("paragraph", default: none)
  if paragraph-config == none {
    body
  } else {
    set par(..paragraph-config)
    body
  }
}

#let paragraph(body, config: (:)) = {
  set par(..config)
  body
}
