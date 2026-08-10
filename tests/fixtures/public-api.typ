#import "../../template/report.typ" as report-template
#import "../../template/thesis.typ" as thesis-template

#let report-api = (
  report-template.report,
  report-template.name-box,
  report-template.mathbf,
)

#let thesis-api = (
  thesis-template.master-thesis,
  thesis-template.img,
  thesis-template.tbl,
  thesis-template.cite,
  thesis-template.thm-box,
  thesis-template.thm-plain,
  thesis-template.definition,
  thesis-template.theorem,
  thesis-template.lemma,
  thesis-template.proof,
  thesis-template.appendix,
  thesis-template.appendix-start,
  thesis-template.latex,
)

#metadata((report: report-api.len(), thesis: thesis-api.len())) <test-checkpoint>
#metadata("end") <test-end>
