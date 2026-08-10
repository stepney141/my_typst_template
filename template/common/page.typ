// Shared page setup. Numbering, headers, and document shells remain template-specific.
#let apply(body, config: (:)) = {
  set page(..config)
  body
}
