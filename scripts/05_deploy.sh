#!/bin/bash

# ---- Variaveis -------------------------------------------------------------
DIR_BASE="$(cd "$(dirname "$0")/.." && pwd)"
DIR_LOG="$DIR_BASE/logs"
ARQ_LOG="$DIR_LOG/05_deploy.log"

ORIGEM="$DIR_BASE/source"     # arquivos do site (index.html, sobre.html, assets)
DESTINO="/var/www/html"       # diretorio publico do Apache

registrar_log() {
    local mensagem="$1"
    mkdir -p "$DIR_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$ARQ_LOG"
}

# ---- Funcao: realizar o deploy ---------------------------------------------
fazer_deploy() {
    if [ "$(id -u)" -ne 0 ]; then
        registrar_log "[ERRO] O deploy em $DESTINO exige privilegios de root."
        return 1
    fi

    if [ ! -d "$ORIGEM" ]; then
        registrar_log "[ERRO] Pasta de origem nao encontrada: $ORIGEM"
        return 1
    fi

    mkdir -p "$DESTINO"

    registrar_log "Limpando diretorio de destino ($DESTINO)..."
    rm -rf "${DESTINO:?}/"*

    registrar_log "Copiando arquivos de $ORIGEM para $DESTINO..."
    if cp -r "$ORIGEM"/* "$DESTINO"/ 2>>"$ARQ_LOG"; then
        registrar_log "[OK] Arquivos do publicados."
    else
        registrar_log "[FALHA] Erro ao copiar os arquivos."
        return 1
    fi
}

# ---- Funcao: validar o deploy ----------------------------------------------
validar_deploy() {
    if [ -f "$DESTINO/index.html" ]; then
        registrar_log "[OK] index.html encontrado no destino. Site publicado."
        return 0
    else
        registrar_log "[FALHA] index.html nao foi encontrado em $DESTINO."
        return 1
    fi
}

# ---- Execucao --------------------------------------------------------------
echo "===== DEPLOY DO SITE - PLATAFORMA DE PODCASTS ====="
if fazer_deploy && validar_deploy; then
    echo ">> Arquivos publicados em $DESTINO:"
    ls -lh "$DESTINO"
    echo ">> Deploy concluido. Acesse o site pelo navegador."
    exit 0
else
    echo ">> Falha no deploy. Verifique o log: $ARQ_LOG"
    exit 1
fi
