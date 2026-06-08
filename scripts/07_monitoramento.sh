#!/bin/bash

# ---- Variaveis -------------------------------------------------------------
DIR_BASE="$(cd "$(dirname "$0")/.." && pwd)"
DIR_LOG="$DIR_BASE/logs"
ARQ_LOG="$DIR_LOG/07_monitoramento.log"

# Limites (em %) a partir dos quais um alerta e disparado
LIMITE_CPU=80
LIMITE_MEM=80
LIMITE_DISCO=80

registrar_log() {
    local mensagem="$1"
    mkdir -p "$DIR_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$ARQ_LOG"
}

# ---- Funcao: uso de CPU ----------------------------------------------------
monitorar_cpu() {
    # Uso de CPU = 100 - tempo ocioso (idle), obtido do 'top' em modo batch.
    local uso_cpu
    uso_cpu=$(top -bn1 | grep -i "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)
    [ -z "$uso_cpu" ] && uso_cpu=0
    echo ">> CPU em uso: ${uso_cpu}%"
    if [ "$uso_cpu" -ge "$LIMITE_CPU" ]; then
        registrar_log "[ALERTA] Uso de CPU acima de ${LIMITE_CPU}% (${uso_cpu}%)"
    else
        registrar_log "[OK] CPU em ${uso_cpu}%"
    fi
}

# ---- Funcao: uso de memoria ------------------------------------------------
monitorar_memoria() {
    local uso_mem
    uso_mem=$(free | awk '/Mem:/ {printf("%d", $3/$2 * 100)}')
    echo ">> Memoria RAM em uso: ${uso_mem}%"
    if [ "$uso_mem" -ge "$LIMITE_MEM" ]; then
        registrar_log "[ALERTA] Uso de memoria acima de ${LIMITE_MEM}% (${uso_mem}%)"
    else
        registrar_log "[OK] Memoria em ${uso_mem}%"
    fi
}

# ---- Funcao: uso de disco --------------------------------------------------
monitorar_disco() {
    local uso_disco
    uso_disco=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
    echo ">> Disco (/) em uso: ${uso_disco}%"
    if [ "$uso_disco" -ge "$LIMITE_DISCO" ]; then
        registrar_log "[ALERTA] Uso de disco acima de ${LIMITE_DISCO}% (${uso_disco}%)"
    else
        registrar_log "[OK] Disco em ${uso_disco}%"
    fi
}

# ---- Funcao: status do Apache ----------------------------------------------
monitorar_apache() {
    if pgrep -x apache2 >/dev/null 2>&1; then
        registrar_log "[OK] Apache em execucao - no ar."
    else
        registrar_log "[ALERTA] Apache NAO esta em execucao!"
    fi
}

# ---- Execucao --------------------------------------------------------------
echo "===== MONITORAMENTO DO SISTEMA - PLATAFORMA DE PODCASTS ====="
registrar_log "Coleta de monitoramento iniciada em $(date '+%Y-%m-%d %H:%M:%S')"
monitorar_cpu
monitorar_memoria
monitorar_disco
monitorar_apache
echo ">> Coleta concluida. Log disponivel em: $ARQ_LOG"
