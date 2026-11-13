# Roadmap — Proyecto H2: Gemelo digital físico-virtual sincronizado por MQTT

Equipo: Joaquín San Martín, Antonia Guajardo, Matías Urrea, Tomás Cárdenas.

Entrega 1 (informe de avance): **12-11-2026, 23:59**. Máximo 5 páginas sin portada ni referencias, según el aviso del ayudante.

Hardware confirmado: Raspberry Pi 4 (2 GB), DHT11, Arduino UNO, protoboard, cables y resistencias.
Falta: ventilador con transistor o relé, fuente USB-C para la Pi y la caja que hará de cámara.

---

## Entrega 1

### Hito 1 — Informe base en Typst (no depende del hardware)

Carpeta: `proyecto/informe/` (`informe.typ`, después se pasa a LaTeX).

- [ ] Problema y enfoque: gemelo con modelo térmico frente a la alternativa de umbral fijo sin modelo.
- [ ] Objetivo general, 3 objetivos específicos y KPIs con definición, fórmula, unidad, meta justificada y método de medición.
- [ ] Arquitectura: diagrama, señales con su canal y período de muestreo, calidad de servicio (latencia y disponibilidad) y una amenaza con su contramedida.
- [ ] Modelo de la planta, de primer orden: `C·dT/dt = −(T − Tamb)/R + P`, con el ensayo de identificación por curva de enfriamiento. Se reutiliza lo del laboratorio 4.
- [ ] Plan de pruebas con al menos 5 casos.
- [ ] Plan de trabajo hasta la entrega final, con responsables y al menos 3 riesgos con su mitigación.
- [ ] Huecos marcados para la evidencia del hito 3: foto, captura y métricas.

Listo cuando: compila con `typst compile` y solo le falta la evidencia física.

### Hito 2 — Cadena MQTT simulada (no depende del hardware)

Carpeta: `proyecto/software/`.

- [ ] Broker Mosquitto local.
- [ ] Publicador con un sensor simulado: temperatura y humedad con marca de tiempo.
- [ ] Gemelo en Python: se suscribe, predice y guarda en CSV.
- [ ] Primeras métricas: latencia MQTT y porcentaje de mensajes entregados.

Listo cuando: los datos simulados viajan de punta a punta y hay números para el informe.

### Hito 3 — Montaje y evidencia (depende de que lleguen los materiales)

- [ ] La Pi con Raspberry Pi OS, en red y con acceso por SSH.
- [ ] DHT11 conectado: VCC al pin 1, DATA al pin 7 (GPIO4) y GND al pin 6.
- [ ] Primera lectura registrada con marca de tiempo. Este es el **primer hito oficial de H2**.
- [ ] Cambiar el sensor simulado del hito 2 por el DHT11 real.
- [ ] Foto del montaje, capturas y log con fecha.

Plan B: si el hardware no llega a tiempo, avisarle al ayudante por Teams y entregar con la cadena simulada, mencionando el componente faltante.

### Hito 4 — Ajuste y entrega

- [ ] Insertar la evidencia y las métricas reales en el informe.
- [ ] Revisar el límite de 5 páginas, que las figuras estén referenciadas y las fuentes citadas.
- [ ] Repositorio con historial y enlace en el informe.
- [ ] Exportar a PDF y subirlo a la plataforma.

---

## Hasta la entrega final

1. **Planta completa:** caja con tapa, fuente de calor y ventilador controlado por la Pi.
2. **Identificación:** ensayo de enfriamiento real y ajuste de R, C y τ.
3. **Gemelo calibrado y detector:** residuo entre lo medido y lo predicho, umbral y persistencia. Se reutiliza el índice del laboratorio 4.
4. **Experimentos:** N repeticiones de abrir la tapa y encender el ventilador; latencia de detección, falsas alarmas y RMSE.
5. **Seguridad:** autenticación en Mosquitto, y TLS si se alcanza.
6. **Visualización:** curva medida, curva predicha y eventos marcados.
7. **Informe final y presentación** con los KPIs medidos contra sus metas.
