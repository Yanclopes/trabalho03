#!/bin/bash

# Diretorio base de logs (calculado a partir da localizacao deste script)
DIR_BASE="$(cd "$(dirname "$0")/.." && pwd)"
DIR_LOG="$DIR_BASE/logs"
ARQ_LOG="$DIR_LOG/01_update.log"


# Recebe uma mensagem e grava com data/hora no arquivo de log e no terminal.
registrar_log() {
    local mensagem="$1"
    mkdir -p "$DIR_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$ARQ_LOG"
}

# ---- Funcao principal: atualizar o sistema ---------------------------------
atualizar_sistema() {
    # Em containers o usuario padrao normalmente e root; validamos para evitar
    # erro de permissao ao executar o apt.
    if [ "$(id -u)" -ne 0 ]; then
        registrar_log "[ERRO] E necessario executar como root (use sudo)."
        return 1
    fi

    registrar_log "Iniciando atualizacao da lista de pacotes (apt update)..."
    if apt update >>"$ARQ_LOG" 2>&1; then
        registrar_log "[OK] Lista de pacotes atualizada com sucesso."
    else
        registrar_log "[FALHA] Erro ao executar apt update."
        return 1
    fi

    registrar_log "Iniciando atualizacao dos pacotes instalados (apt upgrade)..."
    if DEBIAN_FRONTEND=noninteractive apt upgrade -y >>"$ARQ_LOG" 2>&1; then
        registrar_log "[OK] Pacotes atualizados com sucesso. Ambiente pronto."
        return 0
    else
        registrar_log "[FALHA] Erro ao executar apt upgrade."
        return 1
    fi
}

# ---- Execucao --------------------------------------------------------------
echo "===== ATUALIZACAO DO SISTEMA - PLATAFORMA DE PODCASTS ====="
if atualizar_sistema; then
    echo ">> Sistema atualizado. Log disponivel em: $ARQ_LOG"
    exit 0
else
    echo ">> Houve um problema na atualizacao. Verifique o log: $ARQ_LOG"
    exit 1
fi
