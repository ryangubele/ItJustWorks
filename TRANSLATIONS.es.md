# Traducciones

It Just Works™ ofrece su menú dentro del juego (el MCM) y su manual en diez idiomas.

**Lee esta página en tu idioma:** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## Importante: todo salvo el inglés fue traducido por una máquina

El inglés lo escribe el autor. **Todos los demás idiomas fueron traducidos por una IA (un modelo de lenguaje grande), no por un hablante nativo.** Las traducciones son cuidadosas y técnicamente coherentes - los nombres de archivo, los ajustes y términos como `Editor ID`, `Form ID` y `Papyrus` se dejan deliberadamente sin traducir para que aún puedas cotejarlos - pero ningún humano con fluidez las ha revisado.

Si hablas uno de estos idiomas y algo se lee mal, forzado o directamente incorrecto: **mejóralo, por favor.** De eso trata todo el código abierto y una licencia que se puede compartir. Abre una pull request, o envía correcciones como mejor te venga - el crédito es tuyo, y la gratitud está garantizada. Una revisión nativa es lo único que una máquina no puede aportar aquí, y es bienvenida para todos los idiomas, incluido el inglés.

Tampoco hace falta tener fluidez para ayudar. Si una línea del menú aparece **cortada** o se sale del borde del panel - lo más probable en chino o japonés, donde los caracteres son más anchos - ese es un informe genuinamente útil, y fácil de enviar: basta con una captura de pantalla y el idioma. La columna del menú es estrecha, así que la línea demasiado larga ocasional es un ajuste de visualización que recortar, no una traducción rota.

## Qué está traducido

- **El menú MCM** - traducido por completo: cada etiqueta de opción, cada descripción de ayuda y las cadenas de estado dinámicas que los scripts envían al menú (avisos de armar/cancelar Stop, estado del vigilante, últimas frases de autorreparación).
- **El manual** (`docs/manual.<lang>.md`) - traducido por completo.
- **Las notificaciones emergentes dentro del juego** - traducidas. La alerta del vigilante, el aviso de "los nombres están mal", los resultados de Stop y la lectura de la tecla de acceso rápido siguen el ajuste **Notification language** de la página **Settings** del MCM, en los diez idiomas; el instalador lo inicializa a partir de tu elección de idioma de menú.

## Qué es deliberadamente inglés

- **La despedida `See? It Just Works!`** - el chiste es nativo del inglés. Cuestión de gusto, no una limitación.
- **El registro de diagnóstico de Papyrus** - las líneas opcionales `[fth_IJW] …` que el mod escribe cuando activas el registro se quedan en inglés a propósito. Son un dialecto `key=value` estructurado y apto para grep, pensado para buscarse y pegarse en un informe de errores; traducirlo rompería esa capacidad de grep y se ramificaría en una matriz por idioma inmantenible, sin beneficio para nadie.

## Idiomas

El ajuste **Notification language** lista los diez idiomas por sus nombres en inglés, para que el desplegable siga siendo legible con cualquier fuente que tengas. Encuentra el tuyo aquí (de arriba abajo coincide con el orden del desplegable):

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

El idioma del **menú** sigue el idioma de tu juego Skyrim (elegido durante la instalación); el **Notification language** de arriba es un control independiente en la página Settings.

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
