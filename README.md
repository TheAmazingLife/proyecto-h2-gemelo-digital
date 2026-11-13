# Gemelo digital físico-virtual sincronizado por MQTT (Proyecto H2)

Proyecto integrador de Análisis y Diseño de Sistemas Ciber-Físicos, Universidad de Concepción, 2026-2.

Una caja con tapa se precalienta y se deja enfriar con un sensor DHT11 adentro. Una Raspberry Pi 4 lee el sensor y publica cada medición por MQTT a un gemelo en Python que predice la temperatura con un modelo térmico de primer orden. Durante el enfriamiento se abre la tapa o se enciende un ventilador a mano, y se mide cuánto tarda el gemelo en detectar el evento.

**Profesor:** Hugo Garcés · **Ayudante:** Juan Ignacio Carvajal
**Integrantes:** Joaquín San Martín V., Antonia Guajardo, Matías Urrea, Tomás Cárdenas Oyarce

## Estado

| Etapa | Estado |
|---|---|
| Raspberry Pi en red y DHT11 leyendo con marca de tiempo (primer hito) | Listo, 12-11-2026 |
| Informe de avance (Entrega 1) | Listo |
| Cadena MQTT: broker, publicador y gemelo | Pendiente |
| Ensayo de enfriamiento e identificación del modelo | Pendiente |
| Experimentos con tapa y ventilador, KPIs | Pendiente |

## Estructura

```
informe/     informe de avance (fuente Typst, PDF y figuras)
software/pi/ scripts que corren en la Raspberry Pi
datos/       lecturas registradas del DHT11
montaje/     fotos del montaje
ROADMAP.md   hitos del proyecto
```

## Conexión del DHT11

| DHT11 | Raspberry Pi 4 |
|---|---|
| VCC | pin 1 (3,3 V) |
| DATA | pin 7 (GPIO4) |
| GND | pin 6 (GND) |

## Primera lectura en la Pi

```bash
sudo apt install -y python3-venv python3-lgpio
python3 -m venv --system-site-packages ~/h2
~/h2/bin/pip install adafruit-circuitpython-dht
~/h2/bin/python software/pi/leer_dht11.py 10
```

El script guarda cada lectura válida en `lecturas_dht11.csv` con fecha y hora y reintenta las lecturas fallidas del DHT11.

## Informe

```bash
cd informe && typst compile informe.typ
```

La primera compilación descarga el paquete `fletcher` y necesita internet.
