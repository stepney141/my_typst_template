#import "../template/thesis.typ": *

#show: master-thesis.with(
  title: "Typstで書く修論のテンプレ",
  subtitle: "(An Example of a Master Thesis in Typst)",
  author: "右往 左往",
  university: "東京大学大学院",
  school: "工学系研究科",
  department: "航空宇宙工学専攻",
  id: "12-345678",
  mentor: "魚 竿",
  mentor-post: "准教授",
  class: "修士",
  abstract-ja: [
    近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい. 近年の宇宙ってほんますごい.
  ],
  keywords-ja: ("宇宙", "異常検知"),
  bibliography: (file: "/卒論・修論サンプル/references.bib"),
  enable-toc-of-image: true,
  enable-toc-of-table: true,
)

= 序論

Typst #cite(<madje2022programmable>) は、Markdownのような分かりやすい記法で、PDF文書・ポスター・スライド等の各種ドキュメントを簡単に作成できます。Rust言語で書かれており、#latex に比べてコンパイルが極めて高速なのが特長です.

== Typstは優秀だ

=== 簡単に書ける

```typ $ mat(1, 2; 3, 4) $ <eq1>```
と書くと、@eq1 を書くことができます。```typ <eq1>```はラベル名で、コンパイルすると数式への文書内リンクに置換されます。
$ A = mat(1, 2; 3, 4) $ <eq1>
実にシンプルですね。`\begin{pmatrix}` みたいなことを書く必要はなく、Markdown + MathJaxのように `$ $` だけで良いんです。

分数やカッコもお手の物。`\frac{a}{b}` なんてややこしい記法は使わず、ただ ```typ $ a / b $``` と書けば分数になります。`\left(` とか `\right)` とかを自分で書かなくても、Typstはカッコの対応関係を自動で検知し、良い感じにサイズを合わせてくれます。

```typ
$ F_n = 1 / sqrt(5) dot ( ( (1 + sqrt(5)) / 2) ^ n - ((1 - sqrt(5)) / 2) ^ n ) $
```

$ F_n = 1 / sqrt(5) dot ( ( (1 + sqrt(5)) / 2)^n - ((1 - sqrt(5)) / 2)^n ) $

```typ $ f(x, y) := cases(
  1 "if" (x dot y)/2 <= 0,
  2 "if" x "is even",
  3 "if" x in NN,
  4 "else",
) $```

$
  f(x, y) := cases(
    1 "if" (x dot y)/2 <= 0,
    2 "if" x "is even",
    3 "if" x in NN,
    4 "else",
  )
$\

画像や表の挿入も簡単です。次のようにすると @img1 を表示できます。

```typ
#img(
  image("Figures/typst.svg", width: 20%),
  caption: [Typstのロゴ],
  label: <img1>,
  placement: none, // LaTeXの \begin{figure}[H] に相当。auto に指定すると [tb] 相当の挙動になる
)
```

#img(
  image("Figures/typst.svg", width: 20%),
  caption: [Typstのロゴ],
  label: <img1>,
  placement: none, // LaTeXの \begin{figure}[H] に相当。auto に指定すると [tb] 相当の挙動になる
)

@tbl1 はこんな感じ。

```typ
#tbl(
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
  caption: [テーブル #cite(<madje2022programmable>)],
  label: <tbl1>,
  placement: none, // LaTeXの \begin{figure}[H] に相当。auto に指定すると [tb] 相当の挙動になる
)
```

#tbl(
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
  caption: [テーブル #cite(<madje2022programmable>)],
  label: <tbl1>,
  placement: none, // LaTeXの \begin{figure}[H] に相当。auto に指定すると [tb] 相当の挙動になる
) \

こんな感じで #cite(<ss8843592>) と引用できます。引用方式も数十種類の中から選べます。

```typ
こんな感じで #cite(<ss8843592>) と引用できます。
```

また、文中に簡単なプログラムを直接埋め込むことも可能です（コンパイル時に評価されて計算結果がテキストに変換される）。

他にも ```typ #include path.typ``` とすれば他ファイルを参照できます。テンプレートファイルを作って別のファイルから呼び出したり、長い分量の本などを作成する際に章ごとにファイルを分けることなどができます。

#latex は世界中のユーザによる膨大な資産と、長年かけて築いてきた圧倒的なシェアがあるため、すぐにTypstに取って代わることはないでしょう。しかし講義ノート・卒論/修論・学会の予稿等の作成などの場面では、少しずつ Typst に置き換わっていくでしょう（願望）。
#img(
  image("Figures/typst-github.svg", width: 20%),
  caption: [Typst + git #cite(<madje2022programmable>)],
) <img2>

== グラフィックスも色々できるよ

このように、Typstはデフォルトでも様々なグラフィックス機能を備えていますが、他にも「CetZ」というパッケージがあります（TikZのTypst版のようなもの）。これを使うと、もっと自由度の高い図を色々と描くことができます。

```typ
#import "@preview/cetz:0.4.2": canvas, draw, vector, matrix

// #set page(width: auto, height: auto, margin: .5cm)

#canvas({
  import draw: *

  ortho(y: -30deg, x: 30deg, {
    on-xz({
      grid((0,-2), (8,2), stroke: gray + .5pt)
    })

    // Draw a sine wave on the xy plane
    let wave(amplitude: 1, fill: none, phases: 2, scale: 8, samples: 100) = {
      line(..(for x in range(0, samples + 1) {
        let x = x / samples
        let p = (2 * phases * calc.pi) * x
        ((x * scale, calc.sin(p) * amplitude),)
      }), fill: fill)

      let subdivs = 8
      for phase in range(0, phases) {
        let x = phase / phases
        for div in range(1, subdivs + 1) {
          let p = 2 * calc.pi * (div / subdivs)
          let y = calc.sin(p) * amplitude
          let x = x * scale + div / subdivs * scale / phases
          line((x, 0), (x, y), stroke: rgb(0, 0, 0, 150) + .5pt)
        }
      }
    }

    on-xy({
      wave(amplitude: 1.6, fill: rgb(0, 0, 255, 50))
    })
    on-xz({
      wave(amplitude: 1, fill: rgb(255, 0, 0, 50))
    })
  })
})
```

#import "@preview/cetz:0.4.2": canvas, draw, matrix, vector

#img(
  canvas({
    import draw: *

    ortho(y: -30deg, x: 30deg, {
      on-xz({
        grid(
          (0, -2),
          (8, 2),
          stroke: gray + .5pt,
        )
      })

      // Draw a sine wave on the xy plane
      let wave(amplitude: 1, fill: none, phases: 2, scale: 8, samples: 100) = {
        line(
          ..(
            for x in range(0, samples + 1) {
              let x = x / samples
              let p = (2 * phases * calc.pi) * x
              ((x * scale, calc.sin(p) * amplitude),)
            }
          ),
          fill: fill,
        )

        let subdivs = 8
        for phase in range(0, phases) {
          let x = phase / phases
          for div in range(1, subdivs + 1) {
            let p = 2 * calc.pi * (div / subdivs)
            let y = calc.sin(p) * amplitude
            let x = x * scale + div / subdivs * scale / phases
            line((x, 0), (x, y), stroke: rgb(0, 0, 0, 150) + .5pt)
          }
        }
      }

      on-xy({
        wave(amplitude: 1.6, fill: rgb(0, 0, 255, 50))
      })
      on-xz({
        wave(amplitude: 1, fill: rgb(255, 0, 0, 50))
      })
    })
  }),
  caption: [CetZで描いた図の例（公式GitHubリポジトリより引用）],
)

= 自分でスタイルを定義する

Typstでは定理の書き方などをカスタマイズできます.

== 実例

`thm-box`関数を作ってカスタマイズをできるようにしました.
```typ
#let theorem = thm-box(
  "theorem", //identifier
  "定理",
  base-level: 1
)

#theorem("オイラー")[
  Typst はすごいのである.
] <theorem>
```

#let theorem = thm-box(
  "theorem",
  "定理",
  base-level: 1,
)

#theorem("湯川")[
  セガなんてダッセーよな！
] <theorem>

```typ
#let lemma = thm-box(
  "theorem", //identifier
  "補題",
  base-level: 1,
)

#lemma[
  帰ってTypstやろーぜー！
] <lemma>
```
#let lemma = thm-box(
  "theorem",
  "補題",
  base-level: 1,
)

#lemma[
  帰ってTypstやろーぜー！
] <lemma>

このように, @theorem , @lemma を定義できます.

カッコ内の引数に人名などを入れることができます.また, identifierを変えれば, カウントはリセットされます。
identifier毎にカウントを柔軟に変えられるようにしてあるので, 様々な論文の形式に対応できるはずです.

```typ
#let definition = thm-box(
  "definition", //identifier
  "定義",
  base-level: 1,
  stroke: black + 1pt
)
#definition("Prime numbers")[
  A natural number is called a _prime number_ if it is greater than $1$ and
  cannot be written as the product of two smaller natural numbers.
] <definition>
```

#let definition = thm-box(
  "definition",
  "定義",
  base-level: 1,
  stroke: black + 1pt,
)

#definition[
  Typst is a new markup-based typesetting system for the sciences.
] <definition>

このように、「@definition」のカウントは「2.1」にリセットされていますね。

```typ
#let corollary = thm-box(
  "corollary",
  "Corollary",
  base: "theorem",
)

#corollary[
  If $n$ divides two consecutive natural numbers, then $n = 1$.
] <corollary>
```

#let corollary = thm-box(
  "corollary",
  "Corollary",
  base: "theorem",
)

#corollary[
  If $n$ divides two consecutive natural numbers, then $n = 1$.
] <corollary>

baseにidentifierを入れることで@corollary のようにサブカウントを実現できます.

```typ
#let example = thm-plain(
  "example",
  "Example"
).with(numbering: none)

#example[
  数式は\$\$で囲む
] <example>
```

#let example = thm-plain(
  "example",
  "例",
).with(numbering: none)

#example[
  数式は\$\$で囲む
] <example>

thm-plain関数を使ってplain表現も可能です.

#appendix-start()

= こういう機能もいるよね

== 概要

このテンプレートでは、付録を始めたい場所に `#appendix-start()` と一行書くだけで、以降が付録セクションになります。ヘッダの表示やナンバリング方式も自動でアルファベットに切り替わります。

```typ
#appendix-start()

= こういう機能もいるよね

== 概要

このテンプレートでは、付録を始めたい場所に `#appendix-start()` と一行書くだけで、以降が付録セクションになります。ヘッダの表示やナンバリング方式も自動でアルファベットに切り替わります。
```
