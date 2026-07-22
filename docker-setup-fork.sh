#!/bin/bash
# -----------------------------------------------------------------------------
# Skrip One-Click Deployment Xiaozhi Server (Khusus Fork & Branch Custom)
# Repository Fork Default: https://github.com/nixon42/xiaozhi-esp32-server
# -----------------------------------------------------------------------------

# Handler Interupsi (Ctrl+C)
handle_interrupt() {
    echo ""
    echo "Pemasangan dibatalkan oleh pengguna (Ctrl+C)"
    exit 1
}
trap handle_interrupt SIGINT

# Banner Tampilan
echo -e "\e[1;32m"
cat << "EOF"
  __      __            _  _  _            _   _         _      _      _        
  \ \    / /           (_)| || |          | \ | |       | |    (_)    | |       
   \ \  / /__ _  _ __   _ | || |  __ _    |  \| |  __ _ | |__   _   __| |  __ _ 
    \ \/ // _` || '_ \ | || || | / _` |   | . ` | / _` || '_ \ | | / _` | / _` |
     \  /| (_| || | | || || || || (_| |   | |\  || (_| || | | || || (_| || (_| |
      \/  \__,_||_| |_||_||_||_| \__,_|   |_| \_| \__,_||_| |_||_| \__,_| \__,_|
EOF
echo -e "\e[0m"
echo -e "\e[1;36m  Skrip Pemasangan Xiaozhi Server Fork (Mendukung Custom Fork & Branch Translasi) \e[0m\n"
sleep 1

# Pemeriksaan Hak Akses Root
if [ $EUID -ne 0 ]; then
    echo "Gagal: Silakan jalankan skrip ini menggunakan akses root (sudo bash docker-setup-fork.sh)"
    exit 1
fi

# Pemeriksaan & Instalasi Dependensi (whiptail, curl, git)
for pkg in whiptail curl git; do
    if ! command -v $pkg &> /dev/null; then
        echo "Menginstall dependensi yang diperlukan: $pkg ..."
        apt-get update && apt-get install -y $pkg
    fi
done

# Konfirmasi Pemasangan
whiptail --title "Konfirmasi Pemasangan" --yesno "Akan memulai proses pembentukan (build) dan deployment Xiaozhi Server dari Fork. Lanjutkan?" 10 65 || exit 1

# Konfigurasi Repository Fork & Branch
FORK_REPO=$(whiptail --title "Alamat Repository Fork" --inputbox "Masukkan alamat Git Repository Fork:" 10 65 "https://github.com/nixon42/xiaozhi-esp32-server.git" 3>&1 1>&2 2>&3) || exit 1
FORK_BRANCH=$(whiptail --title "Pilihan Branch Git" --inputbox "Masukkan nama branch yang ingin dideploy (misal: translation-en):" 10 65 "translation-en" 3>&1 1>&2 2>&3) || exit 1

# Pemeriksaan & Instalasi Docker
if ! command -v docker &> /dev/null; then
    echo "Docker belum terdeteksi, menginstall Docker..."
    apt-get update && apt-get install -y docker.io docker-compose-plugin
    systemctl start docker
    systemctl enable docker
fi

# Pemeriksaan Perintah Docker Compose
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    echo "Gagal: Perintah 'docker compose' tidak ditemukan di sistem."
    exit 1
fi

# Penyiapan Direktori Deployment
INSTALL_DIR="/opt/xiaozhi-server"
SRC_DIR="$INSTALL_DIR/src"
DATA_DIR="$INSTALL_DIR/data"
MODEL_DIR="$INSTALL_DIR/models/SenseVoiceSmall"

mkdir -p "$DATA_DIR" "$MODEL_DIR"

# Mengambil Kode Sumber dari Fork & Branch
echo "------------------------------------------------------------"
echo "Mengambil kode dari Repository Fork [Repo: $FORK_REPO | Branch: $FORK_BRANCH]..."
if [ -d "$SRC_DIR/.git" ]; then
    echo "Memperbarui kode yang sudah ada..."
    cd "$SRC_DIR"
    git fetch origin
    git checkout "$FORK_BRANCH"
    git pull origin "$FORK_BRANCH"
else
    echo "Melakukan Clone kode sumber..."
    rm -rf "$SRC_DIR"
    git clone -b "$FORK_BRANCH" "$FORK_REPO" "$SRC_DIR"
fi

if [ $? -ne 0 ]; then
    whiptail --title "Kesalahan" --msgbox "Gagal melakukan Clone / Pull kode sumber. Periksa jaringan dan nama branch!" 10 65
    exit 1
fi

# Mengunduh Model Pengenalan Suara (SenseVoiceSmall)
MODEL_FILE="$MODEL_DIR/model.pt"
if [ ! -f "$MODEL_FILE" ]; then
    echo "------------------------------------------------------------"
    echo "Mendownload model pengenalan suara SenseVoiceSmall..."
    curl -fL --progress-bar https://modelscope.cn/models/iic/SenseVoiceSmall/resolve/master/model.pt -o "$MODEL_FILE" || {
        whiptail --title "Kesalahan" --msgbox "Gagal mendownload file model.pt!" 10 50
        exit 1
    }
else
    echo "File model.pt sudah tersedia, melewati unduhan."
fi

# Salin Template Docker-Compose & Konfigurasi dari Fork
cp "$SRC_DIR/main/xiaozhi-server/docker-compose_all.yml" "$INSTALL_DIR/docker-compose_all.yml"
if [ ! -f "$DATA_DIR/.config.yaml" ]; then
    cp "$SRC_DIR/main/xiaozhi-server/config_from_api.yaml" "$DATA_DIR/.config.yaml"
fi

# Membangun (Build) Docker Image dari Kode Sumber Fork
echo "------------------------------------------------------------"
echo "Mulai membangun Image Docker dari Kode Sumber Fork (Server & Web)..."
echo "Proses ini membutuhkan waktu beberapa menit, silakan tunggu..."

cd "$SRC_DIR"

echo "1/2 Membangun Image Server (xiaozhi-esp32-server-fork:latest)..."
docker build -t xiaozhi-esp32-server-fork:latest -f Dockerfile-server . || {
    whiptail --title "Kesalahan" --msgbox "Gagal membangun Image Server!" 10 50
    exit 1
}

echo "2/2 Membangun Image Web & API (xiaozhi-esp32-web-fork:latest)..."
docker build -t xiaozhi-esp32-web-fork:latest -f Dockerfile-web . || {
    whiptail --title "Kesalahan" --msgbox "Gagal membangun Image Web/API!" 10 50
    exit 1
}

# Memperbarui docker-compose_all.yml agar Menggunakan Image Lokal Fork
sed -i 's|ghcr.nju.edu.cn/xinnan-tech/xiaozhi-esp32-server:server_latest|xiaozhi-esp32-server-fork:latest|g' "$INSTALL_DIR/docker-compose_all.yml"
sed -i 's|ghcr.io/xinnan-tech/xiaozhi-esp32-server:server_latest|xiaozhi-esp32-server-fork:latest|g' "$INSTALL_DIR/docker-compose_all.yml"
sed -i 's|ghcr.nju.edu.cn/xinnan-tech/xiaozhi-esp32-server:web_latest|xiaozhi-esp32-web-fork:latest|g' "$INSTALL_DIR/docker-compose_all.yml"
sed -i 's|ghcr.io/xinnan-tech/xiaozhi-esp32-server:web_latest|xiaozhi-esp32-web-fork:latest|g' "$INSTALL_DIR/docker-compose_all.yml"

# Menjalankan Layanan Container
echo "------------------------------------------------------------"
echo "Menjalankan layanan container Docker..."
cd "$INSTALL_DIR"
$DOCKER_COMPOSE_CMD -f docker-compose_all.yml up -d

if [ $? -ne 0 ]; then
    whiptail --title "Kesalahan" --msgbox "Gagal menjalankan layanan Docker!" 10 50
    exit 1
fi

# Menunggu Layanan Berjalan
echo "------------------------------------------------------------"
echo "Menunggu layanan Web API berjalan..."
TIMEOUT=180
START_TIME=$(date +%s)
while true; do
    CURRENT_TIME=$(date +%s)
    if [ $((CURRENT_TIME - START_TIME)) -gt $TIMEOUT ]; then
        whiptail --title "Peringatan" --msgbox "Waktu tunggu habis. Silakan periksa log dengan perintah 'docker logs xiaozhi-esp32-server-web'" 10 65
        break
    fi
    
    if docker logs xiaozhi-esp32-server-web 2>&1 | grep -q "Started AdminApplication in"; then
        echo "Layanan Web API berhasil berjalan!"
        break
    fi
    sleep 2
done

# Konfigurasi Kunci Rahasia Server (server.secret)
PUBLIC_IP=$(hostname -I | awk '{print $1}')
whiptail --title "Konfigurasi Kunci Rahasia (server.secret)" --msgbox "Silakan buka browser dan mendaftar akun Super Admin di Dashboard:\n\nAlamat Web: http://$PUBLIC_IP:8002/\n\nSetelah login, masuk ke menu [Kamus Parameter -> Manajemen Parameter], cari parameter 'server.secret' (Kunci Rahasia Server), lalu salin nilainya." 16 70

SECRET_KEY=$(whiptail --title "Masukkan Kunci Rahasia" --inputbox "Masukkan nilai server.secret yang telah disalin (kosongkan jika ingin melewatinya):" 12 65 3>&1 1>&2 2>&3)

if [ -n "$SECRET_KEY" ]; then
    python3 -c "
import yaml;
config_path = '$DATA_DIR/.config.yaml';
with open(config_path, 'r') as f:
    config = yaml.safe_load(f) or {};
config['manager-api'] = {'url': 'http://xiaozhi-esp32-server-web:8002/xiaozhi', 'secret': '$SECRET_KEY'};
with open(config_path, 'w') as f:
    yaml.dump(config, f);
" 2>/dev/null || true

    docker restart xiaozhi-esp32-server
fi

# Ringkasan Akhir
whiptail --title "Pemasangan Selesai!" --msgbox "\
Deployment Fork berhasil diselesaikan!\n\n\
- Alamat Dashboard Web: http://$PUBLIC_IP:8002\n\
- Alamat WebSocket Core: ws://$PUBLIC_IP:8000/xiaozhi/v1/\n\
- Alamat Interface Visi: http://$PUBLIC_IP:8003/mcp/vision/explain\n\n\
Direktori Kode Sumber: /opt/xiaozhi-server/src\n\
File Konfigurasi Utama: /opt/xiaozhi-server/data/.config.yaml\n" 16 70

echo "Pemasangan selesai!"
