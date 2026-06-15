#!/bin/bash

# ---- Variaveis -------------------------------------------------------------
DIR_BASE="$(cd "$(dirname "$0")/.." && pwd)"
DIR_LOG="$DIR_BASE/logs"
ARQ_LOG="$DIR_LOG/04_backup.log"

# Origem: dados da plataforma de podcasts dentro do container.
# Se /app/podcast nao existir ainda, usamos a pasta source/ como origem.
ORIGEM="/app/podcast"
[ -d "$ORIGEM" ] || ORIGEM="$DIR_BASE/source"

# Destino dos backups
DESTINO="$DIR_BASE/backups"

# Nome do arquivo com data e hora (ex.: backup_podcast_2026-05-31_21-30.tar.gz)
DATA_HORA="$(date '+%Y-%m-%d_%H-%M')"
ARQ_BACKUP="backup_podcast_${DATA_HORA}.tar.gz"

registrar_log() {
    local mensagem="$1"
    mkdir -p "$DIR_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$ARQ_LOG"
}

# ---- Funcao: realizar o backup ---------------------------------------------
realizar_backup() {
    mkdir -p "$DESTINO"

    if [ ! -d "$ORIGEM" ]; then
        registrar_log "[ERRO] Diretorio de origem nao encontrado: $ORIGEM"
        return 1
    fi

    registrar_log "Gerando backup de '$ORIGEM' em '$DESTINO/$ARQ_BACKUP'..."
    # -C entra na pasta pai para nao gravar o caminho absoluto no tar
    if tar -czf "$DESTINO/$ARQ_BACKUP" -C "$(dirname "$ORIGEM")" "$(basename "$ORIGEM")" 2>>"$ARQ_LOG"; then
        registrar_log "[OK] Backup gerado: $ARQ_BACKUP"
        # Registra no log o tamanho do backup gerado (obtido com du -sh)
        local tam_backup
        tam_backup="$(du -sh "$DESTINO/$ARQ_BACKUP" | cut -f1)"
        registrar_log "Tamanho do backup: $tam_backup"
    else
        registrar_log "[FALHA] Erro ao gerar o backup."
        return 1
    fi
}

# ---- Funcao: validar o backup criado ---------------------------------------
validar_backup() {
    if [ -f "$DESTINO/$ARQ_BACKUP" ] && tar -tzf "$DESTINO/$ARQ_BACKUP" >/dev/null 2>&1; then
        local tamanho
        tamanho="$(du -h "$DESTINO/$ARQ_BACKUP" | cut -f1)"
        registrar_log "[OK] Backup valido. Tamanho: $tamanho"
        return 0
    else
        registrar_log "[FALHA] O backup nao foi criado corretamente ou esta corrompido."
        return 1
    fi
}

# ---- Execucao --------------------------------------------------------------
echo "===== BACKUP AUTOMATIZADO - PLATAFORMA DE PODCASTS ====="
echo ">> Origem : $ORIGEM"
echo ">> Destino: $DESTINO/$ARQ_BACKUP"
if realizar_backup && validar_backup; then
    echo ">> Backup concluido com sucesso."
    echo ">> Backups existentes:"
    ls -lh "$DESTINO"/*.tar.gz 2>/dev/null
    exit 0
else
    echo ">> Falha no processo de backup. Verifique: $ARQ_LOG"
    exit 1
fi
