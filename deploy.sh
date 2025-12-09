#!/bin/bash
# Script de deploy com backup automático
# Uso: ./deploy.sh "mensagem do commit"

MSG=${1:-"Atualização automática"}
BACKUP_DIR="/srv/helpdesk/backups"
TS=$(date +"%Y%m%d_%H%M%S")

mkdir -p "$BACKUP_DIR"

echo "=== Criando backup pré-deploy ==="
tar -czf "$BACKUP_DIR/helpdesk_backup_$TS.tar.gz" /srv/helpdesk/frontend/front /srv/helpdesk/backend/helpdesk-backend

echo "Backup salvo em: $BACKUP_DIR/helpdesk_backup_$TS.tar.gz"

echo "=== [FRONTEND] Enviando alterações ==="
cd /srv/helpdesk/frontend/front || exit
git add -A
git commit -m "$MSG" || echo "Nenhuma alteração no frontend"
git push origin main

echo "=== [BACKEND] Enviando alterações ==="
cd /srv/helpdesk/backend/helpdesk-backend || exit
git add -A
git commit -m "$MSG" || echo "Nenhuma alteração no backend"
git push origin main

echo "=== Deploy finalizado com sucesso ==="
