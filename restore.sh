#!/bin/bash
# Restaura backup do helpdesk
# Uso: ./restore.sh caminho/do/backup.tar.gz

BACKUP=$1

if [ -z "$BACKUP" ]; then
  echo "Uso: $0 caminho/do/backup.tar.gz"
  exit 1
fi

if [ ! -f "$BACKUP" ]; then
  echo "Arquivo de backup não encontrado: $BACKUP"
  exit 1
fi

echo "=== Restaurando do backup $BACKUP ==="
# Criar backup de segurança do estado atual (caso precise reverter a restauração)
TS=$(date +"%Y%m%d_%H%M%S")
SAFETY_BACKUP="/srv/helpdesk/backups/helpdesk_safety_$TS.tar.gz"

echo "Criando backup de segurança atual em: $SAFETY_BACKUP"
tar -czf "$SAFETY_BACKUP" /srv/helpdesk/frontend/front /srv/helpdesk/backend/helpdesk-backend

# Restaurar conteúdo
tar -xzf "$BACKUP" -C /

echo "=== Restauração concluída ==="
echo "Se algo quebrar, você pode reverter usando: $SAFETY_BACKUP"
