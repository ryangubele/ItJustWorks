# Usar It Just Works™

## Qué hace

Skyrim usa *escenas* para conversaciones, cinemáticas y otros momentos con script. A veces una escena no termina nunca. Eso puede bloquear en silencio las escenas posteriores: una misión que no avanza, sin error, sin cuelgue. Este mod vigila la escena en la que estás, te avisa si llevas demasiado tiempo en una, te muestra cuál es y te deja detenerla si está atascada.

**Versión corta:** deja los valores por defecto y sigue jugando. Si llega una alerta, abre **Menú de configuración de mods > It Just Works**.

Necesita **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** y **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (con `Load EditorIDs = true` si quieres nombres en lugar de números de ID). Las notas de instalación están en la [página del mod](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Cinco páginas: **Escena**, **Vigilante**, **Ajustes**, **Diagnóstico**, **Desinstalar**.

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
- **Idioma de las notificaciones** - el idioma de las notificaciones emergentes del mod (los toasts de la esquina). Ponlo igual que el idioma de tu menú. Inglés por defecto; independiente del ajuste de idioma del juego.
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

- **Vigilante** - si la comprobación en segundo plano está activa:
  - **En marcha** - bien
  - **Despertando** - normal justo después de una recarga
  - **Con retraso** - sigue funcionando, pero las comprobaciones son más lentas de lo habitual (juego ocupado)
  - **Apagado (comprobaciones desactivadas)** - pusiste **Comprobar cada** en 0
  - **Inactivo (apagado)** - **Activado** está desactivado en **Ajustes**

- **Última autorreparación** - el mod a veces corrige su propia contabilidad (a menudo tras una recarga). Una línea aquí es normal.

- **Versión**

---

## Solución de problemas

### Las escenas se muestran como números de ID, no como nombres

po3 Tweaks no está cargando los Editor ID. En `po3_Tweaks.ini`, pon `Load EditorIDs = true` y reinicia Skyrim; la luz *Editor ID cargados* de la página **Diagnóstico** lo confirma. Los gestores de mods pueden sobrescribir ese archivo al desplegar o actualizar, así que edita la copia *dentro* del mod Tweaks (o un pequeño mod de override que gane), no solo un archivo suelto en `Data`:

- **MO2:** la carpeta del mod Tweaks en el panel izquierdo, o Overwrite / un mod de mayor prioridad.
- **Vortex:** la carpeta de staging de Tweaks, o un mod de override. Vuelve a comprobarlo tras cada actualización.

El **Form ID** se muestra en cualquier caso, así que nunca te quedas del todo a ciegas.

### Las notificaciones están en el idioma equivocado

El mod tiene dos ajustes de idioma independientes; este es el de sus propias notificaciones emergentes. Pon **Ajustes > Idioma de las notificaciones** en tu idioma: controla los toasts de la esquina (la alerta de escena atascada, la pista de nombres, los resultados de Detener). Es independiente del idioma del juego y del idioma del menú de abajo. El inglés es el valor por defecto y el de reserva, así que una línea sin traducir se lee en inglés en lugar de romperse.

### El menú está en el idioma equivocado

El menú MCM sigue el **ajuste de idioma** del juego, no el idioma de las notificaciones de arriba. Skyrim carga el archivo de traducción que coincide con el idioma del juego, así que un juego en inglés muestra el menú en inglés aunque hayas instalado otro idioma. Dos formas de cambiarlo:

- **Instalador:** marca tu idioma en el paso 1 y luego elígelo como idioma de menú predeterminado en el paso 2 (escribe sobre el archivo inglés y guarda un `.bak` en inglés).
- **A mano:** renombra `Interface\Translations\fth_ItJustWorks_SPANISH.txt` a `fth_ItJustWorks_ENGLISH.txt`, sustituyendo el archivo inglés.

### El menú o las notificaciones muestran caracteres ilegibles o corruptos

El texto es correcto - lo que pasa es que tu juego no tiene ninguna fuente capaz de dibujar esos caracteres, así que se ve como basura. La fuente de serie de Skyrim cubre las letras latinas y de Europa occidental, pero no el cirílico, el chino, el japonés ni algunos signos de Europa central. Si usas el menú o las notificaciones en uno de esos idiomas, instala un **mod de fuente** que los incluya; la mayoría de las configuraciones no inglesas ya tienen uno. Si el tuyo no, busca en Nexus una fuente que cubra tu idioma - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) es un buen punto de partida general.

### Nunca aparece ninguna alerta

Comprueba el estado del **Vigilante** en la página **Diagnóstico** y luego los controles del **Vigilante**:

- Estado **Inactivo** - el mod está apagado. Activa **Activado** (Ajustes).
- Estado **Apagado** - **Comprobar cada** está en 0. Vuelve a ponerlo en 10-240s.
- **Avisarme tras** está en **0** - eso desactiva la alerta. Pon los minutos que quieras.

**Tiempo en la escena** se reinicia al recargar, así que una escena solo alerta una vez que llevas en ella, sin interrupción, más tiempo del de aviso en esta sesión. Incluso sin toast, el menú siempre muestra la escena actual y cuánto tiempo llevas en ella.

### Detener escena no eliminó la escena

Una detención no ha fallado ni una sola vez - ni en 14 años de desatascar partidas, primero con versiones improvisadas y ahora con esta. Así que si alguna vez informa de que la escena no terminó, has encontrado algo genuinamente nuevo - lo cual es emocionante, no alarmante. La sorpresa es donde ocurre el aprendizaje. Aún no hay causa conocida, y no se promete nada, pero un registro completo es la mejor opción para dar con ella. Activa el registro de Papyrus, pon **Ajustes > Registro de diagnóstico** en **Cada comprobación** y activa todas las opciones de registro o depuración que encuentres en tu orden de carga, para que, si vuelve a ocurrir, quede capturado. Luego envía el `Papyrus.0.log` completo como informe de error (canales abajo). Mientras tanto, recarga desde antes de que se atascara para seguir jugando.

### Enviar un informe de error o pedir ayuda

Para un error, pon **Ajustes > Registro de diagnóstico** en **Eventos**, reproduce el problema y luego sal. Con el registro de Papyrus activado (las líneas de `Skyrim.ini` están en **Ajustes**), abre `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` y busca `fth_IJW`. Incluye eso, el **Form ID** de la escena y la **Misión propietaria**, y qué estabas haciendo cuando se atascó.

Dónde enviarlo:

- **Informes de error:** la [Bugs tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) en la página del mod, o [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Preguntas y ayuda general:** la [Posts tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) en la página del mod.

---

## Desinstalar

**Quitarlo de forma definitiva:**

1. En la página **Ajustes**, desactiva **Activado**.
2. Guarda y sal al escritorio.
3. Quita el mod en tu gestor (o a mano).

Seguro de quitar a mitad de partida. Skyrim puede dejar un pequeño stub de script inerte en la partida, como otros mods con scripts; el juego lo ignora. Opcional: un limpiador de partidas (p. ej. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** en FallrimTools) puede borrar stubs tras la eliminación: usa los limpiadores con cuidado, solo sobre lo que querías quitar. Puedes dejar este mod instalado mientras limpias basura de *otros* mods.
