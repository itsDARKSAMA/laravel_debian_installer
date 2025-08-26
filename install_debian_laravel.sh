#!/usr/bin/env bash
# Laravel + Valet Auto Installer for Debian 12
# Designed & Developed by: Eng. Abdelrahman M. Almajayda
# GitHub: https://GitHub.com/itsDaRKSAMA

set -euo pipefail

# ========== COLORS ==========
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# ========== BANNER ==========
clear
echo -e "${YELLOW}"
cat <<'EOF'
██╗      █████╗ ██████╗  █████╗ ██╗   ██╗███████╗██╗
██║     ██╔══██╗██╔══██╗██╔══██╗██║   ██║██╔════╝██║
██║     ███████║██████╔╝███████║██║   ██║█████╗  ██║
██║     ██╔══██║██╔══██╗██╔══██║╚██╗ ██╔╝██╔══╝  ██║
███████╗██║  ██║██║  ██║██║  ██║ ╚████╔╝ ███████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚══════╝
EOF

echo -e "${RED}"
cat <<'EOF'
██████╗ ███████╗██████╗ ██╗ █████╗ ███╗   ██╗       ██╗
██╔══██╗██╔════╝██╔══██╗██║██╔══██╗████╗  ██║    ██╗╚██╗
██║  ██║█████╗  ██████╔╝██║███████║██╔██╗ ██║    ╚═╝ ██║
██║  ██║██╔══╝  ██╔══██╗██║██╔══██║██║╚██╗██║    ██╗ ██║
██████╔╝███████╗██████╔╝██║██║  ██║██║ ╚████║    ╚═╝██╔╝
╚═════╝ ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝       ╚═╝
EOF
echo -e "${NC}"

echo -e "${CYAN}Laravel + Valet Auto Installer (Debian 12)${NC}"
echo -e "${WHITE}Designed & Developed by: Eng. Abdelrahman M. Almajayda${NC}"
echo -e "${WHITE}GitHub: https://GitHub.com/itsDaRKSAMA${NC}\n"

# ========== GLOBAL ==========
LOG_FILE="/root/valet_installer.log"
touch "$LOG_FILE"

declare -A STATUS

log() {
  local msg="$1"
  echo -e "[$(date '+%F %T')] $msg" | tee -a "$LOG_FILE"
}

progress_bar() {
  local cur=$1 total=$2 msg=$3
  local percent=$(( cur * 100 / total ))
  local filled=$(( percent / 2 ))
  local empty=$(( 50 - filled ))
  printf "\r${YELLOW}%-20s${NC} [${GREEN}%s${NC}%s] %3d%%" \
    "$msg" "$(printf '#%.0s' $(seq 1 $filled))" \
    "$(printf '.%.0s' $(seq 1 $empty))" "$percent"
}

# ========== FUNCTIONS ==========
check_service() {
  local service="$1"
  if systemctl is-active --quiet "$service"; then
    echo -e "${GREEN}running${NC}"
  elif systemctl is-enabled --quiet "$service"; then
    echo -e "${YELLOW}installed (not running)${NC}"
  else
    echo -e "${RED}missing${NC}"
  fi
}

install_step() {
  local name="$1" cmd="$2"
  echo -e "\n${BLUE}>> Installing ${name}...${NC}"
  log "Installing ${name}"
  eval "$cmd" &>>"$LOG_FILE" || { STATUS["$name"]="❌"; return 1; }
  STATUS["$name"]="✅"
  echo -e "${GREEN}${name} installation completed.${NC}"
}

# ========== 1) UPDATE SYSTEM ==========
echo -e "\n${CYAN}==> Updating system...${NC}"
apt update -y && apt upgrade -y &>>"$LOG_FILE"
STATUS["System Update"]="✅"

# ========== 2) INSTALL ENVIRONMENT ==========
install_step "PHP" "apt install -y php php-cli php-mbstring php-xml php-bcmath php-curl"
install_step "Composer" "apt install -y composer"
install_step "Nginx" "apt install -y nginx"
install_step "MariaDB" "apt install -y mariadb-server"
install_step "Dnsmasq" "apt install -y dnsmasq"
install_step "Valet Linux" "composer global require cpriego/valet-linux"

# ========== 3) CONFIGURE DATABASE ==========
echo -e "\n${CYAN}==> Configuring MariaDB...${NC}"
if systemctl is-active --quiet mariadb; then
  echo -e "${YELLOW}MariaDB already running.${NC}"
else
  systemctl start mariadb
  systemctl enable mariadb
  STATUS["MariaDB"]="✅"
fi

# ========== 4) CREATE LARAVEL PROJECT ==========
read -rp "Enter Laravel project name: " PROJECT_NAME
cd ~
composer create-project laravel/laravel "$PROJECT_NAME" &>>"$LOG_FILE"
STATUS["Laravel Project"]="✅"

# ========== 5) CONFIGURE .env ==========
DB_USER="laravel_user"
DB_PASS="secret"
DB_NAME="${PROJECT_NAME}_db"

mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;"

cat > "$PROJECT_NAME/.env" <<EOF
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASS}
EOF
STATUS[".env Config"]="✅"

# ========== 6) START SERVICES ==========
systemctl restart nginx
systemctl restart mariadb
systemctl restart dnsmasq
STATUS["Services Restart"]="✅"

# ========== 7) FINAL REPORT ==========
echo -e "\n\n${CYAN}=========== INSTALLATION REPORT ===========${NC}"
printf "%-20s | %-10s\n" "Component" "Status"
printf -- "----------------------+------------\n"
for comp in "System Update" "PHP" "Composer" "Nginx" "MariaDB" "Dnsmasq" "Valet Linux" "Laravel Project" ".env Config" "Services Restart"; do
  if [[ "${STATUS[$comp]}" == "✅" ]]; then
    printf "%-20s | ${GREEN}%s${NC}\n" "$comp" "OK"
  else
    printf "%-20s | ${RED}%s${NC}\n" "$comp" "FAIL"
  fi
done
echo -e "${CYAN}===========================================${NC}\n"
