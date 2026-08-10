#import "../../template/thesis.typ": *

#show: master-thesis.with(
  title: "Hayagriva fixture",
  author: "Test User",
  bibliography: (
    file: "/卒論・修論サンプル/references.bib",
    style: "hayagriva",
  ),
)

= Citation

Typst is cited here #cite(<madje2022programmable>).

#metadata("hayagriva") <test-checkpoint>
#metadata("end") <test-end>
