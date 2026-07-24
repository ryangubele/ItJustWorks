# Usar It Just Works™

## Qué hace

Skyrim usa *escenas* para conversaciones, cinemáticas y otros momentos con script. A veces una escena no termina nunca. Eso puede bloquear en silencio las escenas posteriores: una misión que no avanza, sin error, sin cuelgue. Este mod vigila la escena en la que estás, te avisa si llevas demasiado tiempo en una, te muestra cuál es y te deja detenerla si está atascada.

**Versión corta:** deja los valores por defecto y sigue jugando. Si llega una alerta, abre **Menú de configuración de mods > It Just Works**.

Necesita **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** y **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (con `Load EditorIDs = true` si quieres nombres en lugar de números de ID). Las notas de instalación están en la [página del mod](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Cinco páginas: **Escena**, **Vigilante**, **Ajustes**, **Diagnóstico**, **Desinstalar**.

---

## Ver el menú en otro idioma

El mod incluye traducciones del menú: elígelas en el instalador. Skyrim carga el archivo que coincide con el **ajuste de idioma** del juego. Un juego en inglés + otro idioma instalado sigue leyendo el archivo de menú en inglés hasta que lo sustituyas.

**Instalador:** marca el idioma en el paso 1 y luego configúralo como idioma de menú predeterminado en el paso 2 (escribe sobre el archivo inglés; guarda un `.bak` en inglés).

**A mano:** renombra `Interface\Translations\fth_ItJustWorks_SPANISH.txt` a `fth_ItJustWorks_ENGLISH.txt` (sustituye el archivo inglés).

---

## Escena

### En qué estás

Lectura en vivo de la escena actual, o **None**. Abre el menú para una lectura fresca.

- **Tiempo en la escena** - aproximadamente cuánto tiempo llevas en esta escena; recargar el juego lo reinicia. Es la señal de atascado o no.
- **Escena** - el nombre cuando hay nombres disponibles; si no, un número de ID.
- **Form ID** - el ID en bruto, siempre visible. Útil para la consola o un informe de error.
- **Misión propietaria** - a qué misión pertenece esa escena.

### Detener escena

Si crees que la escena está atascada, esto la termina.

1. Pulsa **Detener escena** una vez: una línea confirma que está armada.
2. Pulsa de nuevo para cancelar, o **cierra el menú** para detener.

Solo detén una escena que creas atascada. Detener una normal puede romper cosas. Detener una atascada puede (raramente) soltar una breve ráfaga de eventos retrasados mientras el juego se pone al día.

**Actualizar** vuelve a leer la escena actual sin cerrar el menú. En Skyrim estándar, el juego suele estar en pausa en los menús, así que es poco probable que **Actualizar** sea útil. Si usas un mod que quita la pausa como [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), esto te permite actualizar el menú sin volver a abrirlo.

### Escenas recientes

Las últimas diez escenas, la más reciente primero, con duración aproximada. El mismo tipo de tiempo aproximado que arriba.

---

## Vigilante

Vigila para que no tengas que hacerlo tú.

- **Avisarme tras** - minutos en una escena antes de una alerta. Por defecto **3**. **0** = no avisar nunca.
- **Comprobar cada** - segundos entre comprobaciones. Por defecto **30**. **0** = apagar el vigilante.

La alerta son dos líneas en la esquina, por ejemplo:

> scene blocking others ~3m  
> See? It Just Works!

Una vez por escena hasta que la dejes o la escena cambie. ¿Perdiste el toast? Abre el menú: la lectura sigue mostrando en qué estás y durante cuánto tiempo. El mod no detiene la escena por ti; eso es **Detener escena**.

---

## Ajustes

- **Activado** - activado por defecto. Apágalo para dejar el mod inactivo sin desinstalarlo.
- **Ligereza** - activado por defecto. Las notificaciones mantienen un tono desenfadado; desactívalo para un texto sencillo. Solo cambia el texto, nunca cómo funciona el mod.
- **Nombrar la escena actual** - vincula una tecla; púlsala para ver el nombre de la escena actual sin abrir el menú.
- **Borrar tecla** - quita la vinculación.
- **Registro de diagnóstico** - cuánto va al registro de Papyrus. Deja **Apagado** para el juego normal. Usa **Eventos** al reportar un error; **Cada comprobación** solo si persigues un problema de temporización, y luego vuélvelo a apagar. Puede afectar al rendimiento, sobre todo en **Cada comprobación**.

  El registro solo funciona si el juego está escribiendo registros de Papyrus. En `Documents\My Games\Skyrim Special Edition\`, edita `Skyrim.ini` o `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Reinicia. Archivo de registro: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Busca `fth_IJW`.

---

## Diagnóstico

- **Editor ID cargados** - un indicador. Nombres en **Escena** y misión propietaria cuando está encendida; números de ID cuando está apagada. **Form ID** sigue siendo el `0x…` en bruto en cualquier caso.

  Para activar los nombres: en `po3_Tweaks.ini`, pon `Load EditorIDs = true` y reinicia Skyrim. El mod también lo dice una vez la primera vez que nota que los nombres están desactivados. Los gestores de mods pueden sobrescribir ese archivo al desplegar o actualizar: edita la copia *dentro* del mod Tweaks (o un pequeño mod de override que gane), no solo un archivo suelto en `Data`. **MO2:** carpeta del mod en el panel izquierdo, o Overwrite / mod de mayor prioridad. **Vortex:** carpeta de staging de Tweaks, o un mod de override; vuelve a comprobarlo tras las actualizaciones.

- **Vigilante** - si la comprobación en segundo plano está activa:
  - **En marcha** - bien
  - **Despertando** - normal justo después de una recarga
  - **Con retraso** - sigue funcionando, pero las comprobaciones son más lentas de lo habitual (juego ocupado)
  - **Apagado (comprobaciones desactivadas)** - pusiste **Comprobar cada** en 0
  - **Inactivo (apagado)** - **Activado** está desactivado en **Ajustes**

- **Última autorreparación** - el mod a veces corrige su propia contabilidad (a menudo tras una recarga). Una línea aquí es normal.

- **Versión**

---

## Desinstalar

**Quitarlo de forma definitiva:**

1. En la página **Ajustes**, desactiva **Activado**.
2. Guarda y sal al escritorio.
3. Quita el mod en tu gestor (o a mano).

Seguro de quitar a mitad de partida. Skyrim puede dejar un pequeño stub de script inerte en la partida, como otros mods con scripts; el juego lo ignora. Opcional: un limpiador de partidas (p. ej. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** en FallrimTools) puede borrar stubs tras la eliminación: usa los limpiadores con cuidado, solo sobre lo que querías quitar. Puedes dejar este mod instalado mientras limpias basura de *otros* mods.
