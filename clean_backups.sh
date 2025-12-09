#!/bin/bash
# Mantém apenas os últimos 7 dias de backups

BACKUP_DIR="/srv/helpdesk/backups"

echo "=== Limpando backups antigos em $BACKUP_DIR ==="
find "$BACKUP_DIR" -type f -name "helpdesk_backup_*.tar.gz" -mtime +30 -print -delete

echo "=== Limpeza concluída. Backups com mais de 30 dias foram removidos. ==="
