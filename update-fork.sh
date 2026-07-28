#!/bin/bash
# -----------------------------------------------------------------------------
# Skrip Update Cepat Xiaozhi Server Fork
# -----------------------------------------------------------------------------

echo "------------------------------------------------------------"
echo "  Mulai Update Cepat Xiaozhi Server Fork (Branch: custom_tool)"
echo "------------------------------------------------------------"

# 1. Masuk ke direktori kode sumber & update dari git
cd /opt/xiaozhi-server/src || { echo "Gagal masuk ke /opt/xiaozhi-server/src"; exit 1; }

echo "[1/3] Menarik kode terbaru dari GitHub..."
sudo git pull origin custom_tool || { echo "Gagal melakukan git pull"; exit 1; }

# 2. Build ulang image Web & API
echo "[2/3] Membangun ulang Docker Image (xiaozhi-esp32-web-fork:latest)..."
sudo docker build -t xiaozhi-esp32-web-fork:latest -f Dockerfile-web . || { echo "Gagal build docker image"; exit 1; }

# 3. Restart container
echo "[3/3] Merestart Docker Containers..."
cd /opt/xiaozhi-server || { echo "Gagal masuk ke /opt/xiaozhi-server"; exit 1; }
sudo docker compose -f docker-compose_all.yml up -d --force-recreate

echo "------------------------------------------------------------"
echo "  SUCCESS! Update selesai & server berhasil dijalankan kembali."
echo "------------------------------------------------------------"
