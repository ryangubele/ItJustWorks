# Usar It Just Works™

## Qué hace, y por qué

Skyrim funciona a base de *escenas* - momentos guionizados como conversaciones y secuencias de vídeo que están pensados para terminar por su cuenta. A veces uno no lo hace, y una escena atascada puede bloquear en silencio a las que vienen después, rompiendo sin hacer ruido una misión o incluso una partida guardada entera, sin ningún error que te avise. Este mod vigila la escena en la que estás y te avisa si llevas demasiado tiempo atascado en una, te muestra en qué estás desde un menú, y te deja detener una escena que se ha atascado. Esa es toda la idea: pillar el interruptor atascado antes de que te cueste la partida.

Todo lo que hace el mod se controla desde una sola página: **Menú de Configuración del Mod > It Just Works**. Esto es lo que hace cada parte.

La versión corta, si acabas de instalarlo: deja los valores por defecto como están, sigue jugando y deja que el vigilante te dé un toque en el hombro si alguna vez te quedas demasiado tiempo en una escena. Todo lo de abajo es para cuando quieras mirar más de cerca.

## Ver el menú en español

El mod incluye traducciones del menú para varios idiomas - elígelas en el instalador. Skyrim carga la traducción que coincide con la **configuración de idioma** de tu juego; así que si tu juego está en inglés pero quieres el menú en español, sigue leyendo el archivo inglés y el menú permanece en inglés aunque la traducción esté instalada. Dos soluciones: en el instalador, marca ese idioma en el primer paso y luego elígelo como tu **idioma predeterminado del menú** en el segundo (escribe la traducción sobre el archivo inglés por ti, y guarda un `.bak` inglés que puedes volver a renombrar); o a mano, renombra el archivo de tu idioma en `Interface\Translations\` - `fth_ItJustWorks_SPANISH.txt` - a `fth_ItJustWorks_ENGLISH.txt`, reemplazando el inglés.

## Escena actual

La parte de arriba de la página es una lectura en vivo de la escena en la que estás, o "None" si no estás en ninguna. Abrir la página toma una lectura nueva, así que nunca está desactualizada.

- **Escena** - la escena en la que estás, por su nombre (su Editor ID) cuando los nombres están disponibles, o un número de ID en bruto cuando no (mira el indicador de abajo).
- **Form ID** - el número de ID en bruto de la escena, siempre visible, por si lo necesitas para la consola o un informe de error.
- **Misión propietaria** - la misión a la que pertenece la escena. Suele ser el nombre más útil: te dice *qué* te está reteniendo.
- **Tiempo en la escena** - aproximadamente cuánto llevas en esta escena. Marcado con `~` porque el mod comprueba con un temporizador, así que conoce la respuesta con una precisión de una comprobación.

## El indicador "Editor ID cargados"

Un indicador de estado, no un interruptor - hacer clic en él no hace nada más que devolverlo a la verdad.

- **Encendido** - bien. powerofthree's Tweaks está cargando los Editor ID, así que escenas y misiones se muestran por su nombre.
- **Apagado** - los nombres están desactivados; todo se muestra como números de ID en su lugar. El mod funciona exactamente igual de cualquier modo - solo es más difícil de leer.

Para activar los nombres: abre `po3_Tweaks.ini` (en tu instalación de powerofthree's Tweaks) y pon `Load EditorIDs = true`, luego reinicia Skyrim. El indicador se enciende y aparecen los nombres.

El mod también lo dice una vez, por su cuenta, la primera vez que nota que los nombres están desactivados. Este indicador es la versión permanente de ese aviso - lo que señalar en un hilo de ayuda cuando alguien pregunta por qué sus escenas son todo números.

## Acciones

- **Detener escena** - la solución. Si estás realmente atascado, esto termina la escena en la que estás. Es a propósito en dos pasos: pulsa **Detener escena** una vez para armarlo (aparece una línea confirmando que se detendrá al cerrar el menú) y pulsa de nuevo para cancelar. La detención en sí ocurre en el momento en que cierras el menú, porque ese es el único punto en que el juego corre lo suficiente para que surta efecto. Así que: ármalo, cierra el menú, listo.

  Recurre a esto solo si crees que la escena está atascada. Detener una escena que funciona normalmente puede romper cosas, y detener una atascada puede desatar una breve ráfaga de eventos retrasados mientras el juego se pone al día - eso es lo esperado, no un error nuevo.

- **Actualizar** - toma una lectura nueva de la escena actual ahora mismo, sin cerrar y volver a abrir la página.

## Escenas recientes

Las últimas diez escenas por las que has pasado, la más reciente primero, cada una con su duración aproximada. Útil para "espera, ¿qué era eso en lo que estaba?", sobre todo cuando una escena pasa demasiado rápido para captarla.

## Vigilante

La parte que vigila para que tú no tengas que hacerlo.

- **Avisarme tras** - cuántos minutos en una misma escena antes de que el mod te avise. Por defecto 3. Ponlo en 0 para no avisar nunca.
- **Comprobar cada** - con qué frecuencia mira el vigilante, en segundos. Por defecto 30. Ponlo en 0 para apagar el vigilante por completo. Está pensado para el caso que se detecta un buen rato después, así que no necesita ser rápido: entre 10 y 240 segundos sobra, y es más ligero para tu juego.

Cuando el vigilante salta, son dos líneas cortas en la esquina - cuánto llevas en la escena y que está bloqueando otras, luego el nombre del mod. No necesitas tener el menú abierto para verlo.

## Ver cómo trabaja (la página de Diagnóstico)

- **Vigilante** - una palabra para saber si la comprobación en segundo plano está en marcha ahora mismo: **En marcha**, **Despertando** (normal durante un momento justo tras una recarga), **Apagado** (has puesto Comprobar cada en 0), o **Inactivo** (apagado en la página Desinstalar). Es como confirmas que el mod está vivo sin abrir un registro.
- **Última autorreparación** - el mod resincroniza en silencio su propio estado de vez en cuando, casi siempre justo tras una recarga - por ejemplo, resincronizando el temporizador de escena para que una escena en la que te quedaste atascado a través de una recarga aún se detecte. Una línea aquí es mantenimiento normal y sano (la herramienta diciéndote que se ha arreglado sola), no un fallo.
- **Registro de diagnóstico** - cuánto escribe el mod en el registro de Papyrus, para diagnosticar o para un informe de error:
  - **Apagado** - nada. El valor por defecto; déjalo aquí para jugar con normalidad.
  - **Eventos** - cambios de escena, avisos, y cada vez que el mod se corrige a sí mismo. Ponlo así para rellenar un informe de error.
  - **Cada comprobación** - añade una línea en cada comprobación (el latido del bucle, el temporizador subiendo). Para perseguir un problema de tiempos; luego vuelve a dejarlo como estaba.

El registro solo llega al disco si el registro de Papyrus está activado en el juego. Añade un bloque `[Papyrus]` a `Skyrim.ini` (o `SkyrimCustom.ini`) en `Documents\My Games\Skyrim Special Edition\`:

```
[Papyrus]
bEnableLogging=1
bEnableTrace=1
```

Reinicia Skyrim. El archivo aparece en `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`; búscalo con `fth_IJW` (`findstr fth_IJW Papyrus.0.log`, o `grep`). Con Mod Organizer 2 esa es tu carpeta Documents real, no la carpeta virtual del juego.

## Ajustes

- **Nombrar la escena actual** - asigna una tecla aquí, y pulsarla muestra el nombre de la escena en la que estás, sin abrir el menú en absoluto. El "¿en qué estoy ahora mismo?" más rápido.
- **Borrar tecla** - desasigna esa tecla. Aquí no hay ESC para borrar (en este menú ESC es Pausa, y el juego te avisa del conflicto), así que este botón es la forma de quitar la asignación una vez que la has puesto.

## Acerca de

La versión, para ver de un vistazo qué build estás jugando - útil cuando pides ayuda o compruebas si estás al día.

## Apagarlo, o quitarlo

No hace falta desinstalar para que el mod pare. La página **Desinstalar** tiene un único interruptor **Activado**: apágalo y el mod queda inactivo - el vigilante deja de comprobar y la tecla se desregistra - sin limpiar nada ni tocar tu partida guardada. Vuelve a activarlo cuando quieras y retoma exactamente donde lo dejó. Esa es la forma suave de aparcarlo a mitad de partida, y una forma fácil de comprobar si acaso era lo que te estaba molestando.

Si de verdad quieres que desaparezca para siempre, quítalo en este orden:

1. **Apágalo** en la página Desinstalar.
2. **Guarda, luego sal** al escritorio.
3. **Quita el mod** en tu gestor de mods (Vortex, MO2, o a mano).

Eso es de verdad todo lo que hace falta. Nada de lo que hace este mod va a romper una partida al salir - no retiene ningún objeto del juego como rehén, no bloquea nada, y nada más depende de él. Lo que deja atrás es lo que deja *cualquier* mod con scripts: un pequeño resto inerte en la partida donde antes vivía su script. Skyrim lo ignora. Si quieres que hasta eso desaparezca, puedes barrer ese resto con un limpiador de partidas una vez quitado el mod.

### Sobre los limpiadores de partidas (ReSaver)

En una partida larga ejecutarás un limpiador de vez en cuando - **ReSaver** (parte de FallrimTools) es el habitual - para quitar la basura de scripts que dejan *otros* mods que has cambiado o quitado. Puedes dejar It Just Works instalado mientras lo haces. Está hecho para sobrevivir a una limpieza: sin alias, sin estado del mundo, capaz de recomponerse solo. Una pasada normal no lo toca, e incluso una agresiva que borre su temporizador o su tecla, se rearma la próxima vez que abras el menú. El riesgo para *este* mod es tan bajo como puede serlo el de un mod con scripts, por diseño.

Las precauciones que quedan son sobre la herramienta, no sobre nosotros: entiende lo que hace ReSaver antes de apuntarlo a una partida que aprecias, y apunta a lo que de verdad quitaste en vez de a un barrido a ciegas.
