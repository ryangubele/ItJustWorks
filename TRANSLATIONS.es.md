# Traducciones

It Just Works™ ofrece su menú dentro del juego (el MCM) y su manual en diez idiomas.

**Lee esta página en tu idioma:** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## Importante: todo salvo el inglés fue traducido automáticamente

El inglés lo escribe el autor. Todos los demás idiomas fueron traducidos por un modelo de lenguaje grande, no por un hablante nativo. Las traducciones son cuidadosas y técnicamente coherentes - los nombres de archivo, los ajustes y términos como `Editor ID`, `Form ID` y `Papyrus` se dejan deliberadamente sin traducir para que aún puedas cotejarlos - pero ningún humano con fluidez las ha revisado.

Si hablas uno de estos idiomas y algo se lee mal, forzado o simplemente incorrecto: **mejóralo, por favor.** Abre una pull request, o envía correcciones de la forma que te resulte más cómoda - el crédito es tuyo, y la gratitud está garantizada. Una revisión nativa es lo único que una máquina no puede aportar aquí, y es bienvenida para todos los idiomas, incluido el inglés.

Tampoco hace falta tener fluidez para ayudar. Si una línea del menú se ve **cortada** o se sale del borde del panel - lo más probable en chino o japonés, donde los caracteres son más anchos - ese es un informe genuinamente útil, y fácil de enviar: basta con una captura de pantalla y el idioma.

## Qué está traducido

- **El menú MCM**
- **El manual** (`docs/manual.<lang>.md`)
- **Las notificaciones emergentes dentro del juego** - siguen el ajuste **Idioma de las notificaciones** de la página **Ajustes** del MCM; el instalador lo inicializa a partir de tu elección de idioma de menú.

## Qué es deliberadamente inglés

- **La despedida `See? It Just Works!`** - el chiste es nativo del inglés. Cuestión de gusto, no una limitación.
- **El registro de diagnóstico de Papyrus** - las líneas que el mod escribe cuando activas el registro se quedan en inglés a propósito. Son un dialecto `key=value` estructurado y apto para grep, pensado para buscarse y pegarse en un informe de errores; traducirlas rompería gran parte de su utilidad para poco beneficio.

## Idiomas

La fuente por defecto de Skyrim para jugadores en inglés no puede representar alfabetos no latinos, así que usar los endónimos de cada idioma en el MCM hace que el mod parezca roto. Como solución alternativa, el ajuste **Idioma de las notificaciones** lista los diez idiomas por sus nombres en inglés. Encuentra el tuyo aquí si aún no lo sabes:

| En el menú | Tu idioma | Código de Skyrim |
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

El idioma del **menú** sigue el archivo de idioma del juego de Skyrim a menos que lo anules (el paso de menú predeterminado del instalador, o un renombrado a mano sobre `fth_ItJustWorks_ENGLISH.txt`). El control **Idioma de las notificaciones** de Ajustes es independiente: el instalador lo inicializa cuando eliges un idioma de menú predeterminado, pero un renombrado de menú a mano no lo hace. Ponlo para que coincida si las notificaciones están en el idioma equivocado.

## Manuales

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
