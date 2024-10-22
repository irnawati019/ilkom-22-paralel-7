# Smart Monitoring System untuk Greenhouse Tanaman Cabai Berbasis IoT

import time
import random
from paho.mqtt import client as mqtt_client

# Simulasi sensor
class Sensor:
    def __init__(self, name, min_value, max_value):
        self.name = name
        self.min_value = min_value
        self.max_value = max_value

    def read(self):
        return random.uniform(self.min_value, self.max_value)

# Inisialisasi sensor
temperature_sensor = Sensor("Suhu", 20, 35)
humidity_sensor = Sensor("Kelembaban", 60, 90)
soil_moisture_sensor = Sensor("Kelembaban Tanah", 30, 70)
light_sensor = Sensor("Intensitas Cahaya", 500, 1500)

# Konfigurasi MQTT
broker = 'localhost'
port = 1883
topic = "greenhouse/sensors"
client_id = f'python-mqtt-{random.randint(0, 1000)}'

# Fungsi untuk menghubungkan ke broker MQTT
def connect_mqtt():
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Terhubung ke MQTT Broker!")
        else:
            print(f"Gagal terhubung, kode return: {rc}")

    client = mqtt_client.Client(client_id)
    client.on_connect = on_connect
    client.connect(broker, port)
    return client

# Fungsi untuk publikasi data sensor
def publish(client):
    while True:
        time.sleep(5)
        data = {
            "temperature": temperature_sensor.read(),
            "humidity": humidity_sensor.read(),
            "soil_moisture": soil_moisture_sensor.read(),
            "light_intensity": light_sensor.read()
        }
        msg = f"{data}"
        result = client.publish(topic, msg)
        status = result[0]
        if status == 0:
            print(f"Mengirim `{msg}` ke topic `{topic}`")
        else:
            print(f"Gagal mengirim pesan ke topic {topic}")

# Main function
def run():
    client = connect_mqtt()
    client.loop_start()
    publish(client)

if __name__ == '__main__':
    run()