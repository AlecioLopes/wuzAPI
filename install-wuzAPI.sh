#!/bin/bash

YELLOW='\033[1;33m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
BOLD='\033[1m'
NC='\033[0m' 
RED='\033[1;31m'

echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════"
echo -e "${GREEN}       Bem-vindo ao ${BOLD}Layout's Automação V5.3${NC}${GREEN} 🚀"
echo -e "${CYAN}═══════════════════════════════════════════════════"

echo -e "${YELLOW}${BOLD}🔄 ESTE PROCESSO LEVARÁ DE 15 A 20 MINUTOS. 🔄${NC}"
echo ""

fail() {
  echo -e "${RED}❌ $1${NC}"
  exit 1
}

check_internet() {
  echo -e "${CYAN}🌐 Verificando conexão com a Internet (via ping para 8.8.8.8)..."
  for i in {1..5}; do
    if ping -c 1 -W 2 8.8.8.8 > /dev/null; then
      echo -e "${GREEN}✅ Conexão estabelecida."
      return 0
    else
      echo -e "${YELLOW}🔄 Tentativa $i/5 falhou. Tentando novamente em 5 segundos..."
      sleep 5
    fi
  done
  fail "❌ Não foi possível estabelecer conexão com a Internet após 5 tentativas."
}

check_sqlite_db() {
  DB_PATH="dbdata/main.db"

  if [ -f "$DB_PATH" ]; then
    echo -e "${CYAN}🧩 Validando integridade do banco de dados SQLite em '$DB_PATH'..."
    sqlite3 "$DB_PATH" "PRAGMA integrity_check;" | grep -q "ok" || fail "O banco de dados SQLite está corrompido."
    echo -e "${GREEN}✅ Banco de dados SQLite está OK${NC}"
  else
    echo -e "${YELLOW}⚠️ Banco de dados '$DB_PATH' não encontrado. Será criado ao iniciar o bot.${NC}"
  fi
}

check_binary() {
  [ -f "wuzapi" ] || fail "Binário wuzapi não encontrado após a compilação."
  chmod +x wuzapi
}

check_loop_running() {
  pgrep -f loop_wuzapi.sh > /dev/null && echo -e "${YELLOW}ℹ️ O loop já está em execução.${NC}" && return 0
  return 1
}

echo -e "${CYAN}🌐 Verificando Conexão com a Internet${NC}"
check_internet

echo -e "${CYAN}🛠 Instalando Dependências${NC}"
echo -e "${CYAN}🛠 Instalando git, golang e sqlite...${NC}"
pkg install -y git golang sqlite curl &>/dev/null || fail "Falha ao instalar pacotes."
command -v go > /dev/null || fail "Go não está instalado corretamente"

echo -e "${CYAN}📥 Clonando Repositório${NC}"
echo -e "${CYAN}Clonando o repositório do Layout's Automação...${NC}"
echo ""
git clone --branch main https://github.com/AlecioLopes/wuzapi.git &>/dev/null || fail "Falha ao clonar repositório"
echo -e "${GREEN}Repositório clonado com sucesso.${NC}"
echo ""

cd wuzapi || fail "Não foi possível entrar no diretório wuzapi"

echo -e "${CYAN}📦 Baixando Dependências${NC}"
echo -e "${CYAN}📦 Baixando dependências...${NC}"
go mod tidy &>/dev/null || fail "Falha em go mod tidy"

echo -e "${CYAN}🔨 Compilando Binário${NC}"
echo ""
echo -e "${CYAN}Compilando o binário...${NC}"
echo ""
go build . &>/dev/null || fail "Falha ao compilar"
check_binary

echo -e "${CYAN}🧩 Verificando Banco de Dados${NC}"
check_sqlite_db

echo -e "${CYAN}🔐 Configurando Permissões dos Scripts${NC}"
chmod +x iniciar_wuzapi.sh
chmod +x loop_wuzapi.sh
chmod +x kill_wuzAPI.sh

echo -e "${CYAN}🚀 Iniciando Processo em Segundo Plano${NC}"
if check_loop_running; then
  echo -e "${GREEN}✅ O processo loop já estava em execução."
else
  echo -e "${CYAN}🚀 Iniciando loop_wuzapi.sh em segundo plano...${NC}"
  nohup bash loop_wuzapi.sh > /dev/null 2>&1 &
fi

echo -e "${CYAN}🔐 Aplicando Permissões aos Arquivos${NC}"
echo -e "${CYAN}🔐 Dando permissões a todos os arquivos...${NC}"
chmod -R 777 . || fail "Não foi possível atribuir as permissões."

echo -e "${CYAN}📲 Configurando Permissões para Apps Externas${NC}"
echo -e "${CYAN}📲 Configurando permissões para apps externas (Tasker)...${NC}"
mkdir -p ~/.termux
echo "allow-external-apps=true" >> ~/.termux/termux.properties
termux-reload-settings || echo -e "${YELLOW}Não foi possível recarregar a configuração do Termux. Opcional${NC}"

echo ""
echo -e "\n${GREEN}✅ Layout's Automação foi instalado. Se você está vendo esta mensagem, está tudo certo e você pode continuar."
echo ""
