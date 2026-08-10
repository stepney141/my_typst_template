#import "../../template/thesis.typ": *

#show: master-thesis.with(
  title: "Pergamon fixture",
  author: "Test User",
  bibliography: (
    file: "/卒論・修論サンプル/references.bib",
    style: "pergamon",
  ),
)

= Citation

Typst is cited here #cite(<madje2022programmable>).

#metadata("pergamon") <test-checkpoint>
#metadata("end") <test-end>
