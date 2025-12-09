#!/bin/bash
# Atualiza frontend e backend a partir do GitHub
# Uso: ./update.sh

echo "=== [FRONTEND] Atualizando ==="
cd /srv/helpdesk/frontend/front || exit
git pull origin main

echo "=== [BACKEND] Atualizando ==="
cd /srv/helpdesk/backend/helpdesk-backend || exit
git pull origin main

echo "=== Update concluído ==="
