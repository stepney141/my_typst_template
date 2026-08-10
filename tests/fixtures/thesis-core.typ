#import "../../template/thesis.typ": *

#show: master-thesis.with(
  title: "Thesis fixture",
  author: "Test User",
  abstract-ja: [テスト用の和文概要です。],
  abstract-en: [An abstract for the test fixture.],
  keywords-ja: ("試験",),
  keywords-en: ("test",),
  enable-toc-of-image: true,
  enable-toc-of-table: true,
)

= Core chapter

See @core-equation, @core-image, @core-table, and @core-theorem.

$ x + y = z $ <core-equation>

#img(
  rect(width: 3cm, height: 1cm),
  caption: [Fixture image],
  label: <core-image>,
  placement: none,
)

#tbl(
  table(columns: 2, [A], [B]),
  caption: [Fixture table],
  label: <core-table>,
  placement: none,
)

#theorem[Fixture theorem.] <core-theorem>
#proof[Fixture proof.]

#appendix-start()

= Supporting material

$ a = b $ <appendix-equation>

#metadata("thesis-core") <test-checkpoint>
#metadata("end") <test-end>
