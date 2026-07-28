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

# Salin file docker-compose_all.yml & skrip update-fork.sh terbaru ke direktori /opt/xiaozhi-server/
cp -f /opt/xiaozhi-server/src/main/xiaozhi-server/docker-compose_all.yml /opt/xiaozhi-server/docker-compose_all.yml 2>/dev/null || true
cp -f /opt/xiaozhi-server/src/update-fork.sh /opt/xiaozhi-server/update-fork.sh 2>/dev/null || true

# 2. Build ulang image Server, Web, API & Dapur Voice App
echo "[2/3] Membangun ulang Docker Image dari Kode Sumber..."
echo "  -> Building xiaozhi-esp32-server-fork:latest..."
sudo docker build -t xiaozhi-esp32-server-fork:latest -f Dockerfile-server . || { echo "Gagal build docker image server"; exit 1; }
echo "  -> Building xiaozhi-esp32-web-fork:latest..."
sudo docker build -t xiaozhi-esp32-web-fork:latest -f Dockerfile-web . || { echo "Gagal build docker image web"; exit 1; }
echo "  -> Building dapur-voice-app-fork:latest..."
sudo docker build -t dapur-voice-app-fork:latest -f dapur_voice_app/Dockerfile dapur_voice_app/ || { echo "Gagal build dapur-voice-app"; exit 1; }

# 3. Restart container
echo "[3/3] Merestart Docker Containers..."
cd /opt/xiaozhi-server || { echo "Gagal masuk ke /opt/xiaozhi-server"; exit 1; }
sudo docker compose -f docker-compose_all.yml up -d --force-recreate

echo "------------------------------------------------------------"
echo "  SUCCESS! Update selesai & server berhasil dijalankan kembali."
echo "------------------------------------------------------------"
