#import "../../template/report.typ": *

#show: report.with()

= Report fixture

#name-box(id: "A0000000", name: "Test User")

== Section

A paragraph with an #link("https://typst.app/")[external link],
`inline code`, and a reference to @report-equation.

- First item
- Second item

+ First item
+ Second item

```typ
#let value = 42
```

$ integral_0^1 x dif x = 1 / 2 $ <report-equation>

=== Subsection

#metadata("report-core") <test-checkpoint>
#pagebreak()
Second page.
#metadata("end") <test-end>
