# 翻訳

It Just Works™ は、ゲーム内メニュー（MCM）とマニュアルを 10 言語で提供しています。

**このページをあなたの言語で読む：** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## 重要：英語以外はすべて機械翻訳です

英語は作者自身が執筆しています。それ以外のすべての言語は、母語話者ではなく大規模言語モデルによって翻訳されました。翻訳は注意深く、技術的に一貫しています - ファイル名や設定、`Editor ID`、`Form ID`、`Papyrus` といった用語は、相互参照できるよう意図的に未翻訳のまま残されています - ただし、流暢な人間による校閲は一切受けていません。

これらの言語のいずれかを話せる方で、どこかが不自然、ぎこちない、あるいは明らかに間違っていると感じたら：**どうか改善にご協力ください。** pull request を送るか、都合の良い方法で修正を送ってください - 功績はあなたのもの、感謝は保証されています。母語による仕上げは機械がこのプロジェクトに与えられない唯一のものであり、英語を含むすべての言語で歓迎します。

流暢である必要もありません。メニュー内のある行が**途切れている**ように見えたり、パネルの端からはみ出していたら - 文字幅の広い中国語や日本語で最も起こりやすいのですが - それは本当に役立つ報告であり、送るのも簡単です：スクリーンショットと言語名だけで十分です。

## 翻訳されているもの

- **MCM メニュー**
- **マニュアル**（`docs/manual.<lang>.md`）
- **ゲーム内のポップアップ通知** - MCM の **設定** ページにある **通知の言語** 設定に従います。インストーラーが、選んだメニュー言語からこの初期値を設定します。

## あえて英語のままにしているもの

- **`See? It Just Works!` の締めの一言** - このジョークは英語ならではのものです。制約ではなく、趣味の問題です。
- **Papyrus 診断ログ** - ログ記録をオンにしたときに MOD が書き出す行は、あえて英語のままにしています。これらは、検索してバグ報告に貼り付けるために作られた、構造化された grep 可能な `key=value` の方言です。翻訳すると、その有用性の多くが失われてしまいます。

## 言語

英語版プレイヤー向けの Skyrim 標準フォントは非ラテン文字を描画できないため、MCM で言語の自称名（エンドニム）を使うと MOD が壊れているように見えてしまいます。その回避策として、**通知の言語** 設定はこの 10 言語を英語名で一覧表示します。まだ分からない場合は、ここであなたの言語を見つけてください：

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

**メニュー**の言語は、あなたが上書きしない限り、Skyrim のゲーム言語ファイルに従います（インストーラの既定メニュー手順、または `fth_ItJustWorks_ENGLISH.txt` への手作業の改名）。**設定** ページにある **通知の言語** コントロールは別物です：インストーラは既定のメニュー言語を選んだときにこれを初期設定しますが、手作業のメニュー改名では設定されません。通知が違う言語で出ているなら、これを一致するように設定してください。

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
