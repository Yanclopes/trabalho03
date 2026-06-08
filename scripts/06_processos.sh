#!/bin/bash

# ---- Variaveis -------------------------------------------------------------
DIR_BASE="$(cd "$(dirname "$0")/.." && pwd)"
DIR_LOG="$DIR_BASE/logs"
ARQ_LOG="$DIR_LOG/06_processos.log"

registrar_log() {
    local mensagem="$1"
    mkdir -p "$DIR_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$ARQ_LOG"
}

# ---- Funcao: listar processos ativos ---------------------------------------
listar_processos() {
    registrar_log "Listando processos ativos do ambiente..."
    ps aux | head -n 20
}

# ---- Funcao: buscar processo por nome --------------------------------------
buscar_processo() {
    local nome="$1"
    if [ -z "$nome" ]; then
        registrar_log "[ERRO] Informe o nome do processo. Ex.: buscar apache"
        return 1
    fi
    registrar_log "Buscando processos com o nome '$nome'..."
    # grep -v grep evita que a propria busca apareca no resultado
    local resultado
    resultado="$(ps aux | grep -i "$nome" | grep -v grep)"
    if [ -n "$resultado" ]; then
        echo "$resultado"
    else
        registrar_log "[INFO] Nenhum processo '$nome' em execucao."
    fi
}

# ---- Funcao: matar processo por PID (com validacao) ------------------------
matar_processo() {
    local pid="$1"

    # Seguranca 1: PID obrigatorio
    if [ -z "$pid" ]; then
        registrar_log "[ERRO] PID nao informado. Encerramento BLOQUEADO por seguranca."
        echo ">> Uso correto: $0 matar <PID>"
        return 1
    fi

    # Seguranca 2: PID precisa ser numerico
    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        registrar_log "[ERRO] PID invalido ('$pid'). Deve ser numerico."
        return 1
    fi

    # Seguranca 3: o processo precisa existir
    if ! kill -0 "$pid" 2>/dev/null; then
        registrar_log "[ERRO] Nao existe processo com PID $pid."
        return 1
    fi

    registrar_log "Encerrando o processo PID $pid..."
    if kill "$pid" 2>>"$ARQ_LOG"; then
        registrar_log "[OK] Processo $pid encerrado."
    else
        registrar_log "[FALHA] Nao foi possivel encerrar o PID $pid."
        return 1
    fi
}

# ---- Roteamento por argumento ----------------------------------------------
echo "===== GERENCIAMENTO DE PROCESSOS - PLATAFORMA DE PODCASTS ====="
case "$1" in
    listar)
        listar_processos
        ;;
    buscar)
        buscar_processo "$2"
        ;;
    matar)
        matar_processo "$2"
        ;;
    *)
        echo "Uso: $0 {listar | buscar <nome> | matar <PID>}"
        echo "Exemplos:"
        echo "  $0 listar"
        echo "  $0 buscar apache"
        echo "  $0 matar 1234"
        ;;
esac
