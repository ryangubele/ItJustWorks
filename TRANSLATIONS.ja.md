# 翻訳

It Just Works™ は、ゲーム内メニュー（MCM）とマニュアルを10言語で提供しています。

**このページをあなたの言語で読む：** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## 重要：英語以外はすべて機械翻訳です

英語は作者が自ら執筆しています。**それ以外のすべての言語は、母語話者ではなくAI（大規模言語モデル）によって翻訳されました。** これらの翻訳は慎重で技術的に一貫しており、ファイル名、設定、そして `Editor ID`、`Form ID`、`Papyrus` といった用語は、相互参照できるよう意図的に未翻訳のまま残されています——ただし、流暢な人間による校閲は一切受けていません。

これらの言語のいずれかを話せる方で、どこかが不自然、ぎこちない、あるいは明らかに間違っていると感じたら：**どうか改善にご協力ください。** それこそがオープンソースと共有可能なライセンスの意義そのものです。pull request を出すか、あなたに都合のよい方法で修正を送ってください——功績はあなたのもの、感謝は保証されています。母語による仕上げは機械がこのプロジェクトに与えられない唯一のものであり、英語を含むすべての言語で歓迎します。

流暢でなくても手伝えます。メニュー内のある行が**途切れている**ように見えたり、パネルの端からはみ出していたら——文字幅の広い中国語や日本語で最も起こりやすいのですが——それは本当に役立つ報告であり、送るのも簡単です：スクリーンショットと言語名だけで十分です。メニューの列は狭いため、たまに現れる長すぎる行は、翻訳の誤りではなく、切り詰めるべき表示上の収まりの問題です。

## 翻訳されているもの

- **MCM メニュー**——完全に翻訳済み：すべての選択肢のラベル、すべてのヘルプ説明、そしてスクリプトがメニューに送り込む動的なステータス文字列（Stop の起動/取り消しのヒント、ウォッチドッグの状態、直近の自己修復の文言）。
- **マニュアル**（`docs/manual.<lang>.md`）——完全に翻訳済み。
- **ゲーム内のポップアップ通知**——翻訳済み。ウォッチドッグの警告、「名前がオフになっている」という通知、Stop の結果、そしてホットキーの読み上げは、MCM の **Settings** ページにある **Notification language** 設定に従い、10言語すべてに対応します；インストーラーは、あなたが選んだメニュー言語からその初期値を設定します。

## あえて英語のままにしているもの

- **`See? It Just Works!` の締めの一言**——このジョークは英語ならではのものです。制約ではなく、趣味の問題です。
- **Papyrus 診断ログ**——ログ記録をオンにしたときにMODが書き出す任意の `[fth_IJW] …` 行は、あえて英語のままにしています。これらは、検索してバグ報告に貼り付けるために設計された、構造化された grep 可能な `key=value` の方言です；翻訳すればその grep 可能性が損なわれ、言語ごとに保守不能な行列へと膨れ上がり、誰の得にもなりません。

## 言語

**Notification language** 設定は、この10言語をそれぞれの英語名で一覧表示します。そうすることで、どんなフォントを使っていてもドロップダウンが読みやすいままになります。ここであなたの言語を見つけてください（上から下の順序がドロップダウンの並び順と一致します）：

| メニュー内 | あなたの言語 | Skyrim コード |
|-------------|---------------|-------------|
| English | English | `ENGLISH` |
| French | Français | `FRENCH` |
| German | Deutsch | `GERMAN` |
| Italian | Italiano | `ITALIAN` |
| Spanish | Español | `SPANISH` |
| Polish | Polski | `POLISH` |
| Russian | Русский | `RUSSIAN` |
| Chinese | 简体中文 | `CHINESE` |
| Japanese | 日本語 | `JAPANESE` |
| Czech | Čeština | `CZECH` |

**メニュー**の言語は、あなたの Skyrim のゲーム言語（インストール時に選択）に従います；上記の **Notification language** は、Settings ページにある別個のコントロールです。

## マニュアル

- [English](docs/manual.md)
- [Chinese / 简体中文](docs/manual.zh.md)
- [Czech / Čeština](docs/manual.cs.md)
- [French / Français](docs/manual.fr.md)
- [German / Deutsch](docs/manual.de.md)
- [Italian / Italiano](docs/manual.it.md)
- [Japanese / 日本語](docs/manual.ja.md)
- [Polish / Polski](docs/manual.pl.md)
- [Russian / Русский](docs/manual.ru.md)
- [Spanish / Español](docs/manual.es.md)
