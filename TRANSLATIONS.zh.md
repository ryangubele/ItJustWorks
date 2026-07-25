# 翻译

It Just Works™ 的游戏内菜单（MCM）和手册提供十种语言。

**用你的语言阅读本页：** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## 重要提示：除英语外均为机器翻译

英语由作者亲自撰写。**其余所有语言均由 AI（大型语言模型）翻译，而非母语者翻译。** 这些译文力求严谨且在技术上保持一致——文件名、设置以及 `Editor ID`、`Form ID`、`Papyrus` 等术语都刻意保留未译，以便你仍能相互对照——但没有任何流利的人工审校过它们。

如果你会说其中某种语言，且发现某处读起来不对、生硬或干脆错误：**请帮忙改进它。** 这正是开源与可共享许可的全部意义所在。提交一个 pull request，或以任何方便你的方式发送修正——署名归你，感激必至。母语润色是机器无法赋予本项目的唯一一样东西，任何语言都欢迎，包括英语。

你也不必流利才能帮忙。如果菜单里某一行看起来被**截断**，或溢出面板边缘——在中文或日文里最可能出现，因为字符更宽——那是一份真正有用的报告，而且很容易发送：一张截图加上语言名称就足够了。菜单栏很窄，因此偶尔出现的过长行是需要修剪的显示适配问题，而非翻译错误。

## 已翻译的内容

- **MCM 菜单**——完全翻译：每个选项标签、每条帮助说明，以及脚本推送进菜单的动态状态字符串（Stop 的启用/取消提示、看门狗状态、最近一次自我修复的措辞）。
- **手册**（`docs/manual.<lang>.md`）——完全翻译。
- **游戏内弹出通知**——已翻译。看门狗提醒、"名称未开启"提示、Stop 结果以及热键读数，均遵循 MCM **Settings** 页面上的 **通知语言** 设置，涵盖全部十种语言；安装程序会根据你选择的菜单语言为其设定初始值。

## 刻意保留英语的内容

- **`See? It Just Works!` 结束语**——这个玩笑以英语为本。是品味使然，而非局限。
- **Papyrus 诊断日志**——当你开启日志记录时，模组写入的可选 `[fth_IJW] …` 行会刻意保持英语。它们是一种结构化、可 grep 的 `key=value` 方言，专为搜索并粘贴进错误报告而设计；翻译它们会破坏这种可 grep 性，并扩散成一套无法维护的按语言划分的矩阵，对任何人都没有好处。

## 语言

**通知语言** 设置以各语言的英文名称列出这十种语言，这样无论你使用何种字体，下拉列表都保持可读。在这里找到你的语言（自上而下与下拉列表顺序一致）：

| 菜单中 | 你的语言 | Skyrim 代码 |
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

**菜单**语言跟随 Skyrim 的游戏语言文件，除非你将其覆盖（安装器的默认菜单步骤，或手动重命名覆盖 `fth_ItJustWorks_ENGLISH.txt`）。Settings 页面上的 **通知语言** 控制项则是独立的：当你选择默认菜单语言时安装器可为其设定初始值，但手动重命名菜单文件则不会——若 toast 仍为英语，请将该枚举设为相匹配。

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
