#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#set page(
  paper: "us-letter",
  margin: (x: 2cm, top: 2.6cm, bottom: 1.9cm),
  header-ascent: 25%,
  header: context {
    if counter(page).get().first() > 0 [
      #grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        text(size: 7.5pt)[FACULTAD DE INGENIERÍA\
        DEPTO. DE INGENIERÍA INFORMÁTICA Y CIENCIAS DE LA COMPUTACIÓN\
        ANÁLISIS Y DISEÑO DE SISTEMAS CIBER-FÍSICOS],
        image("img/escudo_udec.png", height: 0.85cm),
      )
      #v(-6pt)
      #line(length: 100%, stroke: 0.9pt)
    ]
  },
  footer: context {
    if counter(page).get().first() > 0 [
      #line(length: 100%, stroke: 0.5pt)
      #v(-4pt)
      #align(center)[#text(size: 9pt)[#counter(page).display("1")]]
    ]
  }
)

#set text(
  font: "Times New Roman",
  size: 10.5pt,
  lang: "es"
)

#set par(
  justify: true,
  leading: 0.6em,
  spacing: 0.9em
)

#set heading(numbering: "1.")
#show heading.where(level: 1): set text(size: 12pt)
#show heading.where(level: 2): set text(size: 10.5pt)
#show heading: set block(above: 1em, below: 0.6em)

#set figure(supplement: "Figura")
#show figure.where(kind: table): set figure(supplement: "Tabla")
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.caption: set text(size: 9.5pt)
#set figure(gap: 0.5em)

#set math.equation(numbering: "(1)")

// Recuadro de respuesta, igual que en los laboratorios anteriores
#let rbox(content) = {
  block(
    width: 100%,
    stroke: 0.5pt + luma(180),
    radius: 4pt,
    inset: (x: 8pt, y: 5pt),
    fill: luma(253),
    breakable: true
  )[#content]
}

#let tabla(..args) = table(align: center, stroke: 0.5pt + luma(180), ..args)

// Recuadro para la evidencia que todavía no existe
#let pendiente(content) = block(
  width: 100%,
  stroke: (paint: rgb("#c0392b"), thickness: 1pt, dash: "dashed"),
  radius: 4pt,
  inset: (x: 8pt, y: 6pt),
  fill: rgb("#fdecea"),
)[#text(size: 9.5pt)[*PENDIENTE:* #content]]

// ---------------------------------------------------------------- Portada
#page(numbering: none, header: none, footer: none, margin: (x: 2cm, top: 2cm, bottom: 2cm))[
  #grid(
    columns: (auto, 1fr, auto),
    align: (left + horizon, center, right + horizon),
    image("img/escudo_udec.png", width: 2.6cm),
    [],
    image("img/logo_dinf.png", width: 2.4cm),
  )
  #v(10pt)
  #align(center)[
    #text(size: 13pt, weight: "bold")[UNIVERSIDAD DE CONCEPCIÓN]\
    #v(2pt)
    #text(size: 12pt)[#smallcaps[Facultad de Ingeniería]]\
    #text(size: 12pt)[#smallcaps[Departamento de Ingeniería Informática y\ Ciencias de la Computación]]
  ]
  #v(1fr)
  #align(center)[
    #text(size: 20pt)[#smallcaps[Gemelo digital físico-virtual\ sincronizado por MQTT]]
    #v(0.5cm)
    #text(size: 12pt, style: "italic")[Proyecto Integrador H2 — Entrega 1: Informe de Avance]
  ]
  #v(1fr)
  #set text(size: 11pt)
  *Asignatura:* Análisis y Diseño de Sistemas Ciber-Físicos\
  *Profesor:* Hugo Garcés\
  *Ayudante:* Juan Ignacio Carvajal\
  *Repositorio (público):* #link("https://github.com/TheAmazingLife/proyecto-h2-gemelo-digital")[`github.com/TheAmazingLife/proyecto-h2-gemelo-digital`]\
  *Estudiantes:*
  - Joaquín San Martín V.
  - Antonia Guajardo
  - Matías Urrea
  - Tomás Cárdenas Oyarce
  #v(1fr)
  #align(center)[#text(size: 12pt)[Concepción, 12 de noviembre de 2026]]
]

#counter(page).update(1)

= Problema y enfoque

*Contexto y problema.* El proyecto usa una cámara térmica pequeña (una caja con tapa que se precalienta con una fuente externa y luego se deja enfriar), mide su temperatura con un DHT11 conectado a una Raspberry Pi 4 y publica cada lectura por MQTT a un gemelo en Python que predice la temperatura con un modelo físico. Durante el enfriamiento se provocan eventos reales a mano, abrir la tapa y encender un ventilador USB, y se mide cuánto tarda el gemelo en detectarlos y cuántas falsas alarmas da. Corresponde al proyecto H2 del curso. El problema queda acotado a una planta térmica de una sola temperatura, dos eventos conocidos y una red local.

*Área CPS.* Gemelos digitales y monitoreo en red: el lazo físico (planta, sensor, eventos) se sincroniza con un lazo cibernético (broker, modelo, detector) por un canal con latencia y pérdidas medibles @mqtt5 @grieves2017.

*Método elegido y alternativas.* El gemelo compara la medición $y_k$ con la predicción $hat(y)_k$ de un modelo térmico de primer orden que describe el enfriamiento natural de la caja, y detecta el evento cuando el residuo $r_k = y_k - hat(y)_k$ se mantiene fuera de un umbral. Se compara con dos alternativas:

- *Umbral fijo sin modelo* (alarma si $y_k < T_"ref" - Delta$ o si $|Delta y|$ supera un límite). Es simple, pero durante el enfriamiento la temperatura baja todo el tiempo, rápido al comienzo y lento al final. Si $Delta$ es chico, da falsas alarmas al inicio de cada enfriamiento; si es grande, no detecta un evento que ocurre cuando la caja ya está cerca de la temperatura ambiente. Tampoco distingue entre tapa y ventilador. Se implementará como *línea base* para comparar los KPI de la @kpis.
- *Modelo de datos puro* (regresión o red neuronal). Necesita muchos datos que cubran todas las condiciones, y la caja entrega pocos ensayos de horas cada uno. En el Laboratorio 4 una regresión lineal tuvo RMSE de 0,695 °C en prueba contra 0,057 °C del modelo físico, porque no generalizó a una condición que no vio al entrenar.

El modelo físico tiene pocos parámetros con significado físico ($tau$, $T_a$ y $T_0$), se identifica con un solo ensayo (@modelo) y su residuo tiene una interpretación directa: abrir la tapa o prender el ventilador aumenta la pérdida de calor y deja un residuo negativo sostenido.

= Objetivos y KPIs

*Objetivo general.* Diseñar e implementar un gemelo digital de una cámara térmica física, sincronizado por MQTT, que detecte la apertura de la tapa y el encendido del ventilador con baja latencia y pocas falsas alarmas.

*Objetivos específicos.*
+ *OE1.* Implementar la cadena DHT11 → Pi → broker → gemelo con tasa de entrega $>= 99$ % y latencia p95 $<= 200$ ms en una sesión de 1 h.
+ *OE2.* Identificar $tau$ del modelo con un ensayo de enfriamiento natural de la caja precalentada, y lograr RMSE $<= 1","5$ °C en simulación libre sobre un ensayo de validación distinto.
+ *OE3.* Detectar los dos eventos con latencia mediana $<= 60$ s en al menos 5 repeticiones de cada uno y $<= 0","5$ falsas alarmas por hora, y comparar ambos KPI contra el umbral fijo.

Los KPI se resumen en la @kpis.

#figure(
  placement: auto,
  text(size: 8.5pt)[
    #table(
      columns: (auto, 1.55fr, auto, 1.7fr, 1.35fr),
      align: (left, left, center, left, left),
      stroke: 0.5pt + luma(180),
      inset: 4pt,
      table.header([*KPI*], [*Definición y fórmula*], [*Unidad*], [*Meta y justificación*], [*Método*]),
      [Latencia de detección $L_d$],
      [Tiempo entre el evento y la primera alarma: $L_d = t_"alarma" - t_"evento"$],
      [s],
      [Mediana $<= 60$ s. Con $T - T_a approx 15$ °C y $tau$ bajando de 10 a 3 min (supuesto), la pendiente cambia en $approx 0","06$ °C/s y el residuo llega a 1,5 °C en $approx 26$ s; 60 s deja margen para el filtro y la persistencia.],
      [$t_"evento"$: mensaje del operador en `camara/evento` al abrir la tapa o encender el ventilador (error de marca $approx 1$ s). $N >= 5$ por evento.],
      [RMSE del gemelo],
      [$sqrt(1/N sum_k (y_k - hat(y)_k)^2)$ en simulación libre, sin eventos],
      [°C],
      [$<= 1","5$ °C. La exactitud del DHT11 es $plus.minus 2$ °C, pero es casi un sesgo que el ajuste absorbe porque se compara contra el mismo sensor; el ruido entre lecturas es de décimas (Sección 5).],
      [Ensayo de validación distinto al de identificación, en el registro SQLite.],
      [Latencia MQTT],
      [$L_m = t_"rec" - t_"pub"$ por mensaje; se reporta p50, p95 y máximo],
      [ms],
      [p95 $<= 200$ ms, menos del 10 % de $T_s = 2$ s: cada lectura se procesa antes de la siguiente y no pesa frente a $L_d$. En el Lab. 4 el p95 fue 105 ms.],
      [Marcas de tiempo en la Pi y en el gemelo, relojes sincronizados por NTP; respaldo: ida y vuelta por un tópico de eco, dividida por 2.],
      [Tasa de entrega (PDR)],
      [$"PDR" = 100 dot N_"rec" \/ N_"pub"$, con $N_"pub"$ según el número de secuencia `seq`],
      [%],
      [$>= 99$ % por hora: admite un corte de hasta 36 s (18 lecturas) por hora; en red local con QoS 1 se espera casi 100 %.],
      [Saltos de `seq` en el registro, como en el Lab. 4.],
      [Falsas alarmas (FAR)],
      [$"FAR" = N_f \/ H$: alarmas sin evento asociado $N_f$ en $H$ horas de operación],
      [1/h],
      [$<= 0","5$ /h: a lo más una en una sesión de 2 h con unos 10 eventos, es decir, menos del 10 % de las alarmas.],
      [Ensayo en reposo de $>= 2$ h y tramos sin eventos de los demás ensayos.],
    )
  ],
  caption: [KPI del proyecto. Los valores de $tau$ usados para justificar $L_d$ son supuestos de diseño.]
) <kpis>

= Arquitectura CPS

La @arq muestra la arquitectura. El DHT11 va dentro de la caja y la Pi afuera, para que su calor no altere la planta; los cables pasan por un orificio sellado. La Pi lee el sensor y publica cada lectura en el broker Mosquitto @mosquitto. La caja se precalienta con un calefactor externo que se retira antes de medir, y los eventos los provoca y marca un operador. El gemelo, en un notebook de la misma red local, se suscribe, predice, calcula el residuo y publica su estado. El broker corre en la Pi, así la medición y su registro no dependen del notebook.

#figure(
  placement: auto,
  text(size: 8pt)[
    #diagram(
      spacing: (9mm, 7mm),
      node-stroke: 0.6pt,
      node-corner-radius: 3pt,
      node-inset: 5pt,
      edge-stroke: 0.6pt,
      node((0, 0), [Precalentamiento\ (calefactor externo)], stroke: (dash: "dashed"), name: <cal>),
      node((0, 1), [Evento: ventilador\ USB (manual)], stroke: (dash: "dashed"), name: <ven>),
      node((1, 0.5), [*Planta*\ caja-cámara\ con tapa], name: <pla>, fill: luma(235)),
      node((1, -0.6), [Evento: abrir tapa], stroke: (dash: "dashed"), name: <tapa>),
      node((2, 0.5), [*DHT11*\ T, HR], name: <dht>),
      node((3, 0.5), [*Raspberry Pi 4*\ lectura y\ publicador], name: <pi>, fill: luma(245)),
      node((4, 1.6), [CSV local en la Pi\ (respaldo)], name: <csv>),
      node((4, 0.5), [*Broker*\ Mosquitto\ (en la Pi)], name: <brk>),
      node((5, 0.5), [*Gemelo*\ Python: modelo,\ residuo, detector], name: <gem>, fill: luma(245)),
      node((5, 1.6), [SQLite\ (registro)], name: <db>),
      node((4, -0.6), [Operador:\ marca de evento], stroke: (dash: "dashed"), name: <op>),
      edge(<cal>, <pla>, "-|>", [$T_0$], label-side: left),
      edge(<ven>, <pla>, "-|>", [$R$], label-side: right),
      edge(<tapa>, <pla>, "-|>", [$R$]),
      edge(<pla>, <dht>, "-|>"),
      edge(<dht>, <pi>, "-|>", [GPIO4]),
      edge(<pi>, <csv>, "-|>"),
      edge(<pi>, <brk>, "-|>", [`medicion`], label-side: left),
      edge(<op>, <brk>, "-|>", [`evento`], label-side: left),
      edge(<brk>, <gem>, "-|>", bend: 20deg, label-side: left),
      edge(<gem>, <brk>, "-|>", [`gemelo`], bend: 20deg, label-side: left),
      edge(<gem>, <db>, "-|>"),
    )
  ],
  caption: [Arquitectura del sistema. Gris: planta y nodos de cómputo; líneas punteadas: acciones manuales. Los tópicos MQTT cuelgan de `camara/`.]
) <arq>

La @senales detalla cada señal. El período de 2 s se elige porque el DHT11 admite como máximo una lectura por segundo @dht11, 2 s deja tiempo para reintentar una lectura con error de suma de verificación, y la constante de tiempo esperada de la caja (minutos) queda cubierta con decenas de muestras por $tau$.

#figure(
  placement: auto,
  text(size: 8.5pt)[
    #table(
      columns: (auto, auto, 1.5fr, auto, 1.5fr),
      align: (left, left, left, center, left),
      stroke: 0.5pt + luma(180),
      inset: 4pt,
      table.header([*Señal*], [*Origen → destino*], [*Interfaz o canal*], [*Período*], [*Justificación*]),
      [$T$ [°C], HR [%]], [DHT11 → Pi], [GPIO4 (pin 7), protocolo de un hilo del DHT11; 3,3 V en pin 1, GND en pin 6 @rpi], [2 s], [Límite de 1 lectura/s del sensor y margen para reintento; $T_s << tau$.],
      [$T_a$ y $T$ de referencia], [Termómetro digital → operador], [Lectura visual registrada a mano], [inicio y fin de cada ensayo], [Mide $T_a$ fuera de la caja y verifica el desfase del DHT11 (P8).],
      [Medición], [Pi → broker → gemelo], [MQTT `camara/medicion`, JSON {`seq`, `ts`, $T$, HR}, Wi-Fi local, QoS 1], [2 s], [Un mensaje por lectura; `seq` permite contar pérdidas.],
      [Evento manual], [Operador → broker], [MQTT `camara/evento`, QoS 1], [asíncrono], [Referencia de $L_d$ para tapa y ventilador; no puede perderse.],
      [Estado del gemelo], [Gemelo → broker], [MQTT `camara/gemelo` ($hat(y)$, $r$, $I$, alarma), QoS 0], [2 s], [Solo visualización; perder uno no afecta la detección.],
      [Registro], [Pi; gemelo], [CSV local en la Pi; SQLite en el notebook], [2 s], [El CSV conserva los datos si cae la red o el broker.],
    )
  ],
  caption: [Señales, interfaces y períodos de muestreo. El período efectivo medido fue de 3,3 s por las lecturas fallidas (Sección 5).]
) <senales>

*Calidad de servicio.* La latencia MQTT debe quedar con p95 $<= 200$ ms y la entrega en $>= 99$ % por hora (@kpis). La *disponibilidad* del flujo de datos debe ser $>= 99$ % del tiempo de cada ensayo, medida como la fracción de períodos con una medición recibida. Para eso las mediciones y los eventos viajan con QoS 1 y el gemelo descarta duplicados por `seq` @mqtt5. La Pi declara un último mensaje (_Last Will_) en `camara/estado` con _keepalive_ de 10 s; si pasan 6 s sin mensajes, el gemelo marca "sin datos" y no emite alarmas térmicas. El publicador se reconecta solo en menos de 30 s y sigue escribiendo el CSV local durante el corte.

*Seguridad.* La amenaza principal es la *publicación falsa*: cualquier equipo de la red que llegue al broker puede publicar en `camara/medicion` lecturas inventadas que oculten un evento real o provoquen una falsa alarma. Como contramedida, el broker exige usuario y clave (`allow_anonymous false` y `mosquitto_passwd`) @mosquitto, y el gemelo rechaza mensajes con `seq` repetido o hacia atrás, con marca de tiempo desfasada en más de 5 s o con un salto imposible para la planta ($|Delta T| > 3$ °C en 2 s). Si el tiempo alcanza, se agregará TLS para que las claves no viajen en claro. La prueba P6 (@pruebas) verifica ambas medidas.

= Modelo de la planta <modelo>

Se reutiliza el modelo de primer orden del Laboratorio 4. Se supone que el aire de la caja y sus paredes tienen una temperatura uniforme $T$, que la temperatura ambiente $T_a$ es constante durante un ensayo y que, retirado el calefactor y con la Pi fuera, no hay fuentes de calor dentro de la caja. Desde la temperatura inicial $T_0$ del precalentamiento, la caja se enfría según

$ C (d T) / (d t) = -(T - T_a) / R, quad T(0) = T_0 $ <ec-planta>

#figure(
  placement: auto,
  text(size: 8.5pt)[
    #table(
      columns: (auto, 2fr, auto, 2.4fr),
      align: (center, left, center, left),
      stroke: 0.5pt + luma(180),
      inset: 4pt,
      table.header([*Parámetro*], [*Significado*], [*Unidad*], [*Cómo se obtiene*]),
      [$C$], [Capacidad térmica de aire, paredes y soportes], [J/K], [No se separa de $R$; se identifica $tau$.],
      [$R$], [Resistencia térmica caja–ambiente, con tapa cerrada y ventilador apagado], [K/W], [No se separa de $C$; se identifica $tau$.],
      [$T_a$], [Temperatura ambiente], [°C], [Termómetro digital fuera de la caja, al inicio y al fin del ensayo.],
      [$T_0$], [Temperatura inicial tras el precalentamiento], [°C], [Primera lectura del DHT11 con la caja cerrada.],
      [$tau = R C$], [Constante de tiempo del enfriamiento], [s], [Ajuste del ensayo de identificación.],
    )
  ],
  caption: [Parámetros del modelo térmico.]
) <param>

*Eventos.* Abrir la tapa o encender el ventilador baja la resistencia a $R_"tapa" < R$ o $R_"ven" < R$ (más pérdida por convección). El gemelo mantiene el $R$ nominal; por eso, tras el evento la planta se enfría más rápido que su predicción y el residuo queda negativo.

*Discretización.* Con retención de orden cero y $T_s = 2$ s, la solución exacta de la @ec-planta entre muestras es

$ hat(T)_(k+1) = hat(T)_k - alpha (hat(T)_k - T_a), quad alpha = 1 - e^(-T_s \/ tau), $ <ec-disc>

que tiene la misma forma que el modelo del Laboratorio 4 sin entrada de calor. El gemelo corre en *simulación libre*, es decir, usa su propia predicción y no la última medición, porque entre dos muestras la temperatura cambia unas décimas, del mismo orden que el ruido del DHT11, y el residuo a un paso no distingue un evento. En simulación libre la diferencia se acumula y supera el umbral en decenas de segundos (@kpis). El gemelo se resincroniza con la medición al inicio de cada ensayo y cuando una alarma se cierra. El detector reutiliza el índice del Lab. 4, $I_k = 0","7 I_(k-1) + 0","3 r_k$, con alarma si $|I_k| > h$ durante $m$ muestras seguidas; $h$ y $m$ se fijan con el ensayo en reposo (valores iniciales: $h = 1","5$ °C y $m = 3$).

*Ensayo de identificación.* (1) Medir $T_a$ con el termómetro; (2) precalentar la caja con el calefactor de invierno a distancia hasta unos 40 °C, bajo el límite de 50 °C del DHT11; (3) retirar el calefactor, cerrar la tapa y registrar el enfriamiento por al menos $3 tau$ (se estiman 30 a 60 min). Se ajusta por mínimos cuadrados la solución analítica $T(t) = T_a + (T_0 - T_a) e^(-t\/tau)$ a la curva completa, y no a las diferencias $y_(k+1) - y_k$ como en el Lab. 4, porque entre muestras esas diferencias son del orden del ruido. El mismo ensayo con la tapa abierta y con el ventilador encendido entrega $tau_"tapa"$ y $tau_"ven"$, que sirven para dimensionar el umbral. La validación usa otro enfriamiento distinto (OE2).

= Estado de avance

A la fecha están el diseño de esta entrega (problema, KPI, arquitectura, modelo y plan de pruebas) y el *primer hito cumplido*: la Raspberry Pi 4 Model B (2 GB, Raspberry Pi OS basado en Debian 13) está en la red local, se accede a ella por SSH y lee el DHT11 por GPIO4 con el script `software/pi/leer_dht11.py` del repositorio, que guarda cada lectura en un CSV con marca de tiempo. La @foto muestra el montaje y la @captura, las primeras lecturas del 12-11-2026.

#grid(
  columns: (1fr, 1.25fr),
  gutter: 8pt,
  [#figure(image("img/IMG_2363.jpg", height: 4.6cm), caption: [Montaje: DHT11 con VCC → pin 1, DATA → pin 7 y GND → pin 6 de la Pi 4.]) <foto>],
  [#figure(image("img/captura_lectura.png", height: 4.6cm), caption: [Primeras lecturas con marca de tiempo (12-11-2026, 23:54).]) <captura>],
)

*Primeras métricas del sensor.* Se registraron 60 lecturas válidas el 12-11-2026, guardadas en `datos/lecturas_dht11.csv` del repositorio. En las dos primeras sesiones hubo 20 lecturas válidas de 31 intentos (65 %); los fallos son errores de verificación propios del DHT11 y el script reintenta. El período efectivo entre lecturas válidas fue de 3,3 s, sobre los 2 s de diseño. El sensor entrega décimas de grado, aunque su exactitud nominal es de $plus.minus 2$ °C. Estas cifras confirman el primer riesgo de la @riesgos y justifican la persistencia del detector.

*Pendiente para la siguiente semana:* la cadena MQTT (broker, publicador y gemelo) con sus métricas de latencia y entrega (P2), la caja con tapa y la verificación del DHT11 contra un termómetro digital de referencia (P8). Se cuenta con el ventilador USB y el calefactor para el precalentamiento.

= Plan de pruebas

La @pruebas define los casos. Todos se registran en el CSV de la Pi y en el SQLite del gemelo, con fecha y hora.

#figure(
  text(size: 8.5pt)[
    #table(
      columns: (auto, 1.2fr, 1.9fr, 1.5fr, 1.4fr),
      align: (center, left, left, left, left),
      stroke: 0.5pt + luma(180),
      inset: 4pt,
      table.header([*ID*], [*Objetivo*], [*Procedimiento*], [*Resultado esperado*], [*Criterio de aprobación*]),
      [P1], [Lectura en reposo], [Caja cerrada a temperatura ambiente, sin eventos, 2 h a $T_s = 2$ s.], [Lecturas estables; detector sin alarmas.], [Sin huecos de más de 10 s entre lecturas válidas; FAR $<= 0","5$ /h.],
      [P2], [Entrega MQTT], [Publicar 1800 mensajes (1 h) y comparar `seq` y marcas de tiempo.], [Sin pérdidas ni duplicados sin descartar.], [PDR $>= 99$ %; latencia p95 $<= 200$ ms.],
      [P3], [Apertura de tapa], [Caja precalentada; durante el enfriamiento abrir la tapa y marcar el evento; cerrar a los 3 min. $N >= 5$.], [Residuo negativo sostenido y alarma.], [Detección en $>= 4$ de 5; mediana $L_d <= 60$ s.],
      [P4], [Ventilador], [Igual que P3, pero colocando y encendiendo el ventilador USB a mano. $N >= 5$.], [Alarma; residuo más negativo que en P3 si $tau_"ven" < tau_"tapa"$.], [Detección en $>= 4$ de 5; mediana $L_d <= 60$ s.],
      [P5], [Corte de red o broker], [Detener Mosquitto o el Wi-Fi 60 s y restablecer.], [Gemelo marca "sin datos"; la Pi sigue en CSV y se reconecta.], ["Sin datos" en $<= 6$ s; reconexión $<= 30$ s; sin alarmas térmicas.],
      [P6], [Mensaje falso], [Desde otro equipo, publicar en `camara/medicion` sin clave, con clave ajena y con `seq` repetido.], [El broker rechaza los dos primeros; el gemelo descarta el tercero.], [0 mensajes falsos aceptados por el gemelo.],
      [P7], [Validación y línea base], [Enfriamiento con eventos; correr gemelo y umbral fijo sobre los mismos datos.], [Gemelo con menos falsas alarmas o menor $L_d$.], [RMSE $<= 1","5$ °C; KPI de ambos métodos reportados.],
      [P8], [Verificación del sensor], [DHT11 junto al termómetro digital; 5 lecturas pareadas en reposo y 5 con la caja caliente.], [Desfase medio estable.], [$|$desfase$| <= 2$ °C; se resta en el gemelo.],
    )
  ],
  caption: [Plan de pruebas.]
) <pruebas>

= Plan de trabajo y riesgos

La @plan reparte las actividades según la planificación del curso, desde el 13-11-2026 hasta las presentaciones de proyectos del 30-11 y el 3-12-2026. La semana 14 tiene el certamen (16-11), por eso concentra el trabajo que no depende de ensayos largos.

#figure(
  text(size: 8.5pt)[
    #table(
      columns: (auto, 2.6fr, 1.1fr, auto),
      align: (center, left, left, center),
      stroke: 0.5pt + luma(180),
      inset: 4pt,
      table.header([*Semana*], [*Actividad*], [*Responsable*], [*Fechas*]),
      [11–13], [Pi con sistema, red y SSH; DHT11 conectado; primera lectura con marca de tiempo; foto del montaje], [Todos], [hecho, 12 nov],
      [14], [Broker Mosquitto, publicador con el DHT11 y gemelo base que guarda en SQLite; primeras métricas MQTT (P2)], [Joaquín San Martín], [13–19 nov],
      [14], [Caja con tapa y orificio para cables; verificación del DHT11 con el termómetro (P8)], [Antonia Guajardo], [13–19 nov],
      [15], [Ensayo de enfriamiento e identificación de $tau$, $tau_"tapa"$ y $tau_"ven"$; validación (OE2)], [Matías Urrea, Tomás Cárdenas], [20–24 nov],
      [15], [Detector (residuo, índice, persistencia), umbral con P1, línea base de umbral fijo; usuario y clave en Mosquitto (P6)], [Joaquín San Martín, Antonia Guajardo], [20–26 nov],
      [15–16], [Experimentos P3–P5 y P7 con $N >= 5$; cálculo de KPI; gráfico de curva medida, predicha y eventos], [Todos (coordina Tomás Cárdenas)], [25–28 nov],
      [16], [Informe final y presentación con los KPI medidos contra sus metas], [Todos (coordina Joaquín San Martín)], [30 nov / 3 dic],
    )
  ],
  caption: [Plan de trabajo por semana del curso hasta las presentaciones.]
) <plan>

#figure(
  text(size: 8.5pt)[
    #table(
      columns: (1.3fr, 2.6fr),
      align: (left, left),
      stroke: 0.5pt + luma(180),
      inset: 4pt,
      table.header([*Riesgo*], [*Mitigación*]),
      [DHT11 lento e impreciso ($plus.minus 2$ °C, 35 % de lecturas fallidas)], [Simulación libre y persistencia en el detector; reintento ante error de suma de verificación; si no basta, corregir el desfase con el termómetro (P8); si no basta, cambiar a un DS18B20 (0,0625 °C) por el mismo GPIO.],
      [El precalentamiento supera 50 °C (límite del DHT11) o deforma la caja], [Calefactor a distancia y hasta unos 40 °C, vigilado en vivo; caja de cartón o plumavit.],
      [La red de la universidad bloquea el puerto 1883 o aísla clientes], [Router o punto de acceso propio para la Pi y el notebook; broker en la Pi; probar la red en semana 1.],
      [El modelo de primer orden no ajusta (dos constantes de tiempo, calor de la propia Pi)], [Pi fuera de la caja; ajustar por tramos o pasar a un modelo de dos nodos (aire y paredes) si el RMSE supera la meta.],
      [Ensayos muy largos por un $tau$ grande], [Caja más pequeña; precalentar menos; ajustar con la curva parcial.],
    )
  ],
  caption: [Riesgos y mitigación.]
) <riesgos>

La @riesgos resume los riesgos. El que más afecta los KPI es el primero, porque el ruido y el desfase del sensor fijan el umbral mínimo y con él la latencia de detección.

#pagebreak()

#heading(numbering: none)[Referencias]

#bibliography("referencias.yml", title: none, style: "ieee")
