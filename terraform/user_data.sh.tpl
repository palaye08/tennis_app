#!/bin/bash
# ══════════════════════════════════════════════════════════════════════
# user_data.sh.tpl — Script d'initialisation de l'instance EC2
#
# RÔLE : Ce script s'exécute UNE SEULE FOIS, au premier démarrage de
#         l'instance EC2 créée par Terraform.
#
# CE QU'IL FAIT (infrastructure uniquement) :
#   1. Met à jour le système (dnf)
#   2. Installe Docker et Docker Compose
#   3. Crée /opt/tennis-app/docker-compose.yml (MySQL + backend)
#   4. Crée le service systemd (redémarrage automatique au reboot)
#   5. Premier démarrage des conteneurs
#
# CE QU'IL NE FAIT PAS (géré par .github/workflows/ci-cd.yml) :
#   → Les mises à jour de l'image Docker backend après le 1er boot
#     sont déclenchées par le pipeline CI/CD à chaque push sur master
#     via SSH : docker-compose pull backend && docker-compose up -d
# ══════════════════════════════════════════════════════════════════════
set -e
exec > /var/log/tennis-setup.log 2>&1

echo "================================================"
echo " INITIALISATION EC2 — TENNIS BACKEND"
echo " Region : us-west-1"
echo " Date   : $(date)"
echo " (Les mises à jour sont gérées par le CI/CD)"
echo "================================================"

# ── 1. Mise à jour du système ─────────────────────
echo "[1/6] Mise à jour du système..."
dnf update -y

# ── 2. Installation de Docker ─────────────────────
echo "[2/6] Installation de Docker..."
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# ── 3. Installation de Docker Compose v2 ─────────
echo "[3/6] Installation de Docker Compose v2.27.0..."
curl -SL "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# ── 4. Création du docker-compose.yml ────────────
echo "[4/6] Création du fichier docker-compose.yml..."
mkdir -p /opt/tennis-app

cat > /opt/tennis-app/docker-compose.yml << 'COMPOSE'
version: "3.8"

services:
  mysql:
    image: mysql:8.0
    container_name: tennis-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${mysql_root_password}
      MYSQL_DATABASE: ${mysql_database}
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - tennis-network
    restart: always
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 15s
      timeout: 5s
      retries: 10
      start_period: 30s

  backend:
    image: ${docker_image}
    container_name: tennis-backend
    ports:
      - "${app_port}:${app_port}"
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/${mysql_database}?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: ${mysql_root_password}
      SERVER_PORT: ${app_port}
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - tennis-network
    restart: always

networks:
  tennis-network:
    driver: bridge

volumes:
  mysql_data:
COMPOSE

# ── 5. Service systemd (redémarre au reboot) ──────
echo "[5/6] Création du service systemd..."

cat > /etc/systemd/system/tennis-app.service << 'SERVICE'
[Unit]
Description=Tennis Backend Application (Docker Compose)
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/tennis-app
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable tennis-app.service

# ── 6. Premier démarrage des conteneurs ──────────
# Ce démarrage initial est géré ici (1er boot uniquement).
# Les mises à jour suivantes sont déclenchées par le pipeline
# CI/CD (.github/workflows/ci-cd.yml) via SSH sur cette instance.
echo "[6/6] Premier démarrage des conteneurs..."
cd /opt/tennis-app
docker-compose pull || echo "Pull partiel - utilisation du cache si disponible"
docker-compose up -d

echo ""
echo "================================================"
echo " INITIALISATION TERMINÉE - $(date)"
echo " Swagger dispo dans ~2 min sur le port ${app_port}"
echo " Logs : sudo cat /var/log/tennis-setup.log"
echo ""
echo " PROCHAINES MISES À JOUR :"
echo " → Pousser sur master → le CI/CD redéploie automatiquement"
echo "================================================"
