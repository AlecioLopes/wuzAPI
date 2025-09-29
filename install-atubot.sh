#!/bin/bash

YELLOW='\033[1;33m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
BOLD='\033[1m'
NC='\033[0m' 
RED='\033[1;31m'

echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════"
echo -e "${GREEN}       ¡Bienvenido a ${BOLD}Plugin ATUBOT V5.3${NC}${GREEN} 🚀"
echo -e "${CYAN}═══════════════════════════════════════════════════"

echo -e "${YELLOW}${BOLD}🔄 ESTE PROCESO TARDARA DE 15 A 20 MINUTOS. 🔄${NC}"
echo ""

echo -e "${CYAN}🌐 Página web de compra: ${BOLD}https://atubot.net.pe/shop${NC}"
echo -e "${CYAN}▶️ YouTube:   ${BOLD}https://youtube.com/@atubot${NC}"
echo -e "${CYAN}🎵 TikTok:    ${BOLD}https://tiktok.com/@atubot_dev${NC}"
echo ""

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${RED}${BOLD}⚠️ NO APOYES LA PIRATERIA - LO BARATO SALE CARO ⚠️${NC}"
echo ""

fail() {
  echo -e "${RED}❌ $1${NC}"
  exit 1
}

check_internet() {
  echo -e "${CYAN}🌐 Verificando conexión a Internet (vía ping a 8.8.8.8)..."
  for i in {1..5}; do
    if ping -c 1 -W 2 8.8.8.8 > /dev/null; then
      echo -e "${GREEN}✅ Conexión establecida."
      return 0
    else
      echo -e "${YELLOW}🔄 Intento $i/5 fallido. Reintentando en 5 segundos..."
      sleep 5
    fi
  done
  fail "❌ No se pudo establecer conexión a Internet después de 5 intentos."
}

check_sqlite_db() {
  DB_PATH="dbdata/main.db"

  if [ -f "$DB_PATH" ]; then
    echo -e "${CYAN}🧩 Validando integridad de la base de datos SQLite en '$DB_PATH'..."
    sqlite3 "$DB_PATH" "PRAGMA integrity_check;" | grep -q "ok" || fail "La base de datos SQLite está corrupta."
    echo -e "${GREEN}✅ Base de datos SQLite está OK${NC}"
  else
    echo -e "${YELLOW}⚠️ No se encontró la base de datos '$DB_PATH'. Se creará al iniciar el bot.${NC}"
  fi
}

check_binary() {
  [ -f "wuzapi" ] || fail "Binario wuzapi no encontrado después de compilar."
  chmod +x wuzapi
}

check_loop_running() {
  pgrep -f loop_wuzapi.sh > /dev/null && echo -e "${YELLOW}ℹ️ El loop ya se está ejecutando.${NC}" && return 0
  return 1
}

# Validación de red
check_internet

# Instalar dependencias
echo -e "${CYAN}🛠 Instalando git, golang y sqlite..."
pkg install -y git golang sqlite curl &>/dev/null || fail "Fallo al instalar paquetes."
command -v go > /dev/null || fail "Go no está instalado correctamente"

# Clonar el repositorio de WuzAPI
echo "Clonando el repositorio de ATUBOT..."
echo ""
git clone --branch develop https://github.com/davidtchdev/wuzapi.git &>/dev/null || fail "Fallo al clonar repositorio"
echo "Repositorio clonado con éxito."
echo ""

cd wuzapi || fail "No se pudo entrar al directorio wuzapi"

# Dependencias Go
echo -e "${CYAN}📦 Descargando dependencias..."
go mod tidy &>/dev/null || fail "Fallo en go mod tidy"

# Compilar el binario de WuzAPI con el nombre por defecto
echo ""
echo "Compilando el binario..."
echo ""
go build . &>/dev/null || fail "Fallo al compilar"
check_binary

# Verificar base de datos
check_sqlite_db

# Dar permisos a scripts
chmod +x ejecutar_wuzapi.sh
chmod +x loop_wuzapi.sh
chmod +x kill_atubot.sh

# Ejecutar en segundo plano si no está corriendo
if check_loop_running; then
  echo -e "${GREEN}✅ El proceso loop ya estaba en ejecución."
else
  echo -e "${CYAN}🚀 Iniciando loop_wuzapi.sh en segundo plano..."
  nohup bash loop_wuzapi.sh > /dev/null 2>&1 &
fi

# Permisos
echo -e "${CYAN}🔐 Dando permisos a todos los archivos..."
chmod -R 777 . || fail "No se pudieron asignar los permisos."

# Conceder permisos a Tasker y apps externas
echo -e "${CYAN}📲 Configurando permisos para apps externas (Tasker)..."
mkdir -p ~/.termux
echo "allow-external-apps=true" >> ~/.termux/termux.properties
termux-reload-settings || echo -e "${YELLOW}No se pudo recargar la configuración de Termux. opcional"

# Confimacion
echo ""
echo -e "\n${GREEN}✅ ATUBOT ha sido instalado. Si estas viendo este mensaje ya esta todo ok puedes continuar."
echo ""
