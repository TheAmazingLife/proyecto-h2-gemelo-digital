# Roadmap — Proyecto H2

Gemelo digital físico-virtual sincronizado por MQTT. Presentaciones: 30-11 y 3-12-2026.

## Hecho

- [x] Raspberry Pi 4 en red local con acceso por SSH.
- [x] DHT11 conectado (VCC → pin 1, DATA → pin 7, GND → pin 6).
- [x] Primeras lecturas con marca de tiempo (`datos/lecturas_dht11.csv`).
- [x] Informe de avance (Entrega 1).

## Semana 14 (13–19 nov)

- [ ] Broker Mosquitto en la Pi, publicador con el DHT11 y gemelo base que guarda en SQLite.
- [ ] Primeras métricas MQTT: latencia y tasa de entrega (P2).
- [ ] Caja con tapa y orificio para cables.
- [ ] Verificación del DHT11 contra el termómetro digital (P8).

## Semana 15 (20–26 nov)

- [ ] Ensayo de enfriamiento de la caja precalentada; ajuste de τ, τ_tapa y τ_ven.
- [ ] Detector: residuo, índice suavizado, umbral y persistencia; línea base de umbral fijo.
- [ ] Usuario y clave en Mosquitto y validación de mensajes en el gemelo (P6).

## Semana 15–16 (25 nov – 3 dic)

- [ ] Experimentos con la tapa y el ventilador (N ≥ 5 cada uno) y cálculo de KPI.
- [ ] Gráfico de la curva medida, la predicha y los eventos.
- [ ] Informe final y presentación.
