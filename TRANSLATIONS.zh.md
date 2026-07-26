# 翻译

It Just Works™ 的游戏内菜单（MCM）与手册提供十种语言版本。

**用你的语言阅读本页：** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## 重要提示：除英语外均为机器翻译

英语由作者亲自撰写。其余所有语言均由大语言模型翻译，而非母语者翻译。这些译文力求严谨，并在技术上保持一致——文件名、设置项，以及 `Editor ID`、`Form ID`、`Papyrus` 等术语都刻意保留未译，以便你仍能相互对照——但尚未有流利的母语者审校过它们。

如果你会说其中某种语言，并发现某处读起来不对、生硬，或干脆是错的：**请帮忙改进它。** 提交一个 pull request，或以任何方便你的方式发送修正——署名归你，感谢必至。母语润色是机器无法给予这个项目的唯一一样东西，欢迎任何语言的改进，包括英语。

你也不必流利才能帮忙。如果菜单里某一行看起来被**截断**，或溢出了面板边缘——在中文或日文里最容易出现，因为字符更宽——这也是一份真正有用的报告，而且很容易发送：一张截图加上语言名称就足够了。

## 已翻译的内容

- **MCM 菜单**
- **手册**（`docs/manual.<lang>.md`）
- **游戏内弹出通知** - 遵循 MCM **设置** 页面上的 **通知语言** 设置；安装器会根据你选择的菜单语言为其写入初始值。

## 刻意保留英语的内容

- **`See? It Just Works!` 结束语** - 这个玩笑是英语本土的。是品味使然，而非局限。
- **Papyrus 诊断日志** - 当你开启日志记录时，模组写入的日志行故意保持英语。它们是一种结构化、可 grep 的 `key=value` 方言，专为搜索并粘贴进错误报告而设计；翻译它们会损失很多实用性，却几乎没有好处。

## 语言

英语玩家使用的 Skyrim 默认字体无法渲染非拉丁字母的文字，因此如果在 MCM 中使用各语言的本名，会让模组看起来像出了故障。作为变通办法，**通知语言** 设置以英文名称列出这十种语言。如果你还不知道自己语言对应哪个英文名，可以在这里查找：

| 菜单中显示 | 你的语言 | Skyrim 代码 |
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

**菜单** 语言遵循 Skyrim 的游戏语言文件，除非你覆盖它（安装器的默认菜单步骤，或手动重命名为 `fth_ItJustWorks_ENGLISH.txt`）。设置页面上的 **通知语言** 控制项是独立的：当你选择默认菜单语言时，安装器会为其写入初始值，但手动重命名菜单文件则不会。如果通知语言不对，请手动将其设为匹配。

## 手册

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
