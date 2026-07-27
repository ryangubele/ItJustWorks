# Usar It Just Works™

## Qué hace

Skyrim usa *escenas* para conversaciones, cinemáticas y otros momentos con script. A veces una escena no termina nunca. Eso puede bloquear en silencio las escenas posteriores - una misión que no avanza, sin error, sin cuelgue. Este mod vigila la escena en la que estás, te avisa si llevas un rato en ella, te muestra cuál es y te deja detenerla si está atascada.

**Versión corta:** deja los valores por defecto y sigue jugando. Si recibes un aviso, abre **Mod Configuration Menu > It Just Works**.

No edita los registros de otros mods ni necesita parches, así que su posición en el orden de carga respecto a tu lista de contenido no importa. No cambiará una escena a menos que le digas que la detenga.

Necesita **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** y **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (con `Load EditorIDs = true` si quieres nombres en lugar de números de ID). Las notas de instalación están en la [página del mod](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Cinco páginas: **Escena**, **Vigilante**, **Ajustes**, **Diagnóstico**, **Desinstalar**.

---

## Escena

### En qué estás

Lectura de la escena actual, o **Ninguna**. El menú se actualiza al abrirse.

- **Tiempo en la escena** - aproximadamente cuánto tiempo llevas en esta escena.
- **Escena** - el nombre cuando está disponible; si no, un número de ID.
- **Form ID** - el ID en bruto, siempre visible. Útil para la consola o un informe de error.
- **Misión propietaria** - a qué misión pertenece esa escena.

### Detener escena

Si crees que la escena está atascada, esto la termina.

1. Pulsa **Detener escena** una vez - una línea confirma que está armada.
2. Pulsa de nuevo para cancelar, o cierra el menú para detener.

Solo detén una escena que creas atascada. Detener una normal puede romper cosas. Detener una atascada puede (raramente) disparar una breve ráfaga de eventos retrasados mientras el juego se pone al día.

**Actualizar** vuelve a leer la escena actual sin cerrar el menú. En el Skyrim vanilla, es poco probable que actualizar sea útil, ya que el juego se pausa en los menús. Si usas un mod que quita la pausa como [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), esto te permite actualizar sin volver a abrir el menú.

### Escenas recientes

Las últimas diez escenas, la más reciente primero, con duración aproximada.

---

## Vigilante

Vigila para que no tengas que hacerlo tú.

- **Avisarme tras** - cuánto puede durar una escena antes de que recibas un aviso. Por defecto, **6** minutos. **0** = nunca.  
  Nada en el juego marca una escena como atascada, y nada en el juego nos dice cuánto se supone que debe durar una escena. Así que fijamos un umbral y te avisamos. Combinamos el reloj del juego y el tiempo jugado de un modo que representa aproximadamente "tiempo dedicado a jugar de verdad", para que el control sea intuitivo.
- **Comprobar cada** - segundos entre comprobaciones. Por defecto, **30**. **0** = apaga el vigilante (y borra la vigilancia actual).
- **Repetir alertas** - desactivado por defecto, así que recibes un aviso por escena. Actívalo para seguir recibiendo avisos mientras sigas por encima del umbral.
- **Repetir cada** - minutos entre avisos, se usa solo cuando repetir alertas está activado. Por defecto, **5**.

Un aviso son dos líneas en la esquina, por ejemplo:

> escena bloqueando otras ~6m  
> See? It Just Works!

Un aviso por escena por defecto, hasta que la dejes o la escena cambie. ¿Te lo perdiste? Abre el menú - la lectura sigue mostrando en qué escena estás y durante cuánto tiempo. El mod no detiene la escena por ti; usa Detener escena en la página Escena para eso.

Las configuraciones sin pausa (p. ej. [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859)) deberían funcionar; el tiempo jugado sigue el contador de partida guardado del juego.

---

## Ajustes

- **Activado** - activado por defecto. Desactívalo para dejar el mod inactivo sin desinstalarlo.
- **Ligereza** - activado por defecto. Las notificaciones mantienen un tono desenfadado; desactívala para un texto sencillo. Solo cambia el texto, nunca cómo funciona el mod.
- **Idioma de las notificaciones** - el idioma de las notificaciones propias del mod en la esquina. El instalador puede inicializarlo cuando eliges un idioma de menú predeterminado; cámbialo cuando quieras en esta página. Inglés por defecto y como reserva; independiente del ajuste de idioma del juego.
- **Nombrar la escena actual** - vincula una tecla; púlsala para ver el nombre de la escena actual sin abrir el menú.
- **Borrar tecla** - quita la vinculación.
- **Registro de diagnóstico** - cuánto va al registro de Papyrus. Deja **Apagado** para el juego normal. Usa **Eventos** al reportar un error; **Cada comprobación** solo si persigues un problema de temporización, y luego vuélvelo a apagar. Puede afectar al rendimiento, sobre todo en cada comprobación.

  El registro solo funciona si el juego está escribiendo registros de Papyrus. En `Documents\My Games\Skyrim Special Edition\`, edita `Skyrim.ini` o `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Reinicia. Archivo de registro: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Busca `fth_IJW`.

---

## Diagnóstico

- **Editor ID cargados** - un indicador. Nombres en la página Escena y en la misión propietaria cuando está encendido; números de ID cuando está apagado. Form ID sigue siendo el `0x…` en bruto en cualquier caso.

- **Temporización** - qué relojes está usando esta escena para el umbral de aviso: tiempo jugado más reloj del juego cuando ambos parecen fiables, o solo tiempo jugado si el reloj del juego se ha perdido para esta escena. **--** cuando el vigilante está apagado, inactivo, o no estás en una escena.

- **Vigilante** - si la comprobación en segundo plano está activa:
  - **En marcha** - bien
  - **Despertando** - normal justo después de una recarga o antes de la primera comprobación
  - **Con retraso** - sigue funcionando, pero las comprobaciones son más lentas de lo habitual (juego ocupado)
  - **Apagado** - pusiste comprobar cada en 0
  - **Inactivo** - activado está desactivado en Ajustes

- **Última autorreparación** - el mod a veces corrige su propia contabilidad interna. Una línea aquí es normal.

- **Versión**

---

## Solución de problemas

### Las escenas se muestran como números de ID, no como nombres

po3 Tweaks no está cargando los Editor ID. En `po3_Tweaks.ini`, pon `Load EditorIDs = true` y reinicia Skyrim; la luz **Editor ID cargados** de la página Diagnóstico lo confirma. Los gestores de mods pueden sobrescribir ese archivo al desplegar o actualizar, así que edita la copia *dentro* del mod Tweaks (o un pequeño mod de override que gane), no solo un archivo suelto en `Data`:

- **MO2:** la carpeta del mod Tweaks en el panel izquierdo, o Overwrite / un mod de mayor prioridad.
- **Vortex:** la carpeta de staging de Tweaks, o un mod de override. Vuelve a comprobarlo tras cada actualización.

Form ID se muestra en cualquier caso, así que nunca te quedas del todo a ciegas.

### Las notificaciones están en el idioma equivocado

Las notificaciones de la esquina siguen **Ajustes > Idioma de las notificaciones**, no el idioma del juego ni qué archivo de traducción de menú esté instalado. El inglés es el valor por defecto y el de reserva.

Una ejecución normal del instalador que fija el idioma de menú predeterminado también inicializa este control para que menú y notificaciones coincidan. Si solo cambiaste el archivo de menú a mano, o actualizaste sin volver a ejecutar ese paso del instalador, pon el idioma de las notificaciones una vez para que coincida con tu menú.

### El menú está en el idioma equivocado

El menú MCM sigue el ajuste de idioma del juego, no el idioma de las notificaciones de arriba. Skyrim carga el archivo de traducción que coincide con el idioma del juego, así que un juego en inglés muestra el menú en inglés aunque hayas instalado otro idioma. Dos formas de cambiarlo:

- **Instalador:** marca tu idioma en el paso 1 y luego elígelo como idioma de menú predeterminado en el paso 2. Eso sobrescribe el archivo de menú inglés (y conserva un `.bak` en inglés) **y** inicializa el idioma de las notificaciones para que coincida.
- **A mano:** renombra `Interface\Translations\fth_ItJustWorks_<LANGUAGE>.txt` a `fth_ItJustWorks_ENGLISH.txt`, sustituyendo el archivo inglés. Eso **no** cambia el idioma de las notificaciones - ponlo en Ajustes para que coincida, o las notificaciones se quedan en inglés.

### El menú o las notificaciones muestran caracteres ilegibles o corruptos

El texto es correcto - lo que pasa es que tu juego no tiene ninguna fuente capaz de dibujar esos caracteres, así que se ve como basura. La fuente de serie de Skyrim cubre las letras latinas y de Europa occidental, pero no el cirílico, el chino, el japonés ni algunos signos de Europa central. Si usas el menú o las notificaciones en uno de esos idiomas, instala un mod de fuente que los incluya; la mayoría de las configuraciones no inglesas ya tienen uno. Si la tuya no, busca en Nexus una fuente que cubra tu idioma - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) es un buen punto de partida general.

### Nunca aparece ningún aviso

Comprueba el estado del Vigilante en la página Diagnóstico, y luego los controles del Vigilante:

- Estado **Inactivo** - el mod está apagado. Activa Activado (Ajustes).
- Estado **Apagado** - comprobar cada está en 0. Vuelve a ponerlo en 10-240s.
- Avisarme tras está en **0** - eso desactiva el aviso. Pon los minutos que quieras.

El aviso espera a que **tanto** el tiempo jugado como el calendario del juego estén disponibles, así que **Tiempo en la escena** puede marcar un valor por encima del umbral mientras el aviso sigue esperando al reloj del juego - eso es normal. Incluso sin ninguna notificación, el menú siempre muestra la escena actual y cuánto tiempo llevas en ella.

### Detener escena no eliminó la escena

Una detención no ha fallado ni una sola vez en más de 10 años desatascando partidas; primero con versiones improvisadas y sueltas, y ahora con esta. Así que si alguna vez informa de que la escena no terminó, o bien has encontrado un error en el mod, o bien algo genuinamente nuevo. Eso es emocionante. La sorpresa es donde ocurre el aprendizaje. Un registro completo es la mejor opción para dar con ello. Activa el registro de Papyrus, pon el registro de diagnóstico en **Cada comprobación**, y activa todas las opciones de registro o depuración que encuentres en tu orden de carga, para que, si vuelve a ocurrir, quede capturado. Luego envía el `Papyrus.0.log` completo como informe de error. Recarga desde antes de que se atascara para seguir jugando mientras tanto.

### Enviar un informe de error, o pedir ayuda

Para un error, pon el registro de diagnóstico en **Eventos**, reproduce el problema y luego sal. Con el registro de Papyrus activado (las líneas de `Skyrim.ini` están en Ajustes), abre `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` y busca `fth_IJW`. Incluye eso, el Form ID de la escena y la misión propietaria, y qué estabas haciendo cuando se atascó.

Dónde enviarlo:

- **Informes de error:** la [pestaña Bugs](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) en la página del mod, o [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Preguntas y ayuda general:** la [pestaña Posts](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) en la página del mod.

---

## Desinstalar

**Quitarlo definitivamente:**

1. En la página Ajustes, desactiva activado.
2. Guarda y sal al escritorio.
3. Quita el mod en tu gestor (o a mano).

Seguro de quitar a mitad de partida. Skyrim puede dejar un pequeño stub de script inerte en la partida, como otros mods con scripts; el juego lo ignora. Opcional: un limpiador de partidas (p. ej. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** en FallrimTools) puede borrar stubs tras la eliminación - usa los limpiadores con cuidado, sobre lo que pretendes quitar. Puedes dejar este mod instalado mientras limpias basura de *otros* mods.
