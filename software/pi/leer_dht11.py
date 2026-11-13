"""Primera lectura del DHT11 en la Raspberry Pi (primer hito de H2).

Lee temperatura y humedad cada 2 s desde GPIO4 (pin 7), las muestra en
pantalla y las guarda en lecturas_dht11.csv con fecha y hora.

Uso en la Pi:
    python leer_dht11.py            # lee hasta Ctrl+C
    python leer_dht11.py 30         # 30 lecturas y termina
"""

import csv
import sys
import time
from datetime import datetime
from pathlib import Path

import adafruit_dht
import board

PERIODO_S = 2.0
ARCHIVO = Path(__file__).with_name("lecturas_dht11.csv")


def main() -> None:
    limite = int(sys.argv[1]) if len(sys.argv) > 1 else None
    sensor = adafruit_dht.DHT11(board.D4, use_pulseio=False)
    nuevo = not ARCHIVO.exists()
    seq = 0
    fallidas = 0

    with ARCHIVO.open("a", newline="") as f:
        escritor = csv.writer(f)
        if nuevo:
            escritor.writerow(["seq", "timestamp", "temperatura_c", "humedad_pct"])
        try:
            while limite is None or seq < limite:
                inicio = time.monotonic()
                try:
                    temperatura = sensor.temperature
                    humedad = sensor.humidity
                except RuntimeError as error:
                    # El DHT11 falla seguido por tiempos de la señal: se reintenta.
                    fallidas += 1
                    print(f"lectura fallida ({error}), reintentando")
                    time.sleep(PERIODO_S)
                    continue
                if temperatura is None or humedad is None:
                    fallidas += 1
                    time.sleep(PERIODO_S)
                    continue

                seq += 1
                ts = datetime.now().isoformat(timespec="seconds")
                escritor.writerow([seq, ts, temperatura, humedad])
                f.flush()
                print(f"{seq:4d}  {ts}  T = {temperatura:.1f} °C  HR = {humedad:.0f} %")
                time.sleep(max(0.0, PERIODO_S - (time.monotonic() - inicio)))
        except KeyboardInterrupt:
            pass
        finally:
            sensor.exit()

    print(f"\n{seq} lecturas guardadas en {ARCHIVO.name} ({fallidas} fallidas)")


if __name__ == "__main__":
    main()
