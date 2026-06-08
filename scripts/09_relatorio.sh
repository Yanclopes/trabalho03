#!/bin/bash

# ---- Variaveis -------------------------------------------------------------
DIR_BASE="$(cd "$(dirname "$0")/.." && pwd)"
DIR_LOG="$DIR_BASE/logs"
ARQ_RELATORIO="$DIR_LOG/relatorio_execucao.txt"

PROJETO="trabalho03-cloud-shell"
TEMA="Plataforma de Podcasts e Audios"
ALUNO="Nome do Aluno"   # <-- ALTERE para o seu nome antes de entregar
APP="/app/podcast"

# ---- Funcao: escrever uma secao no relatorio -------------------------------
secao() {
    local titulo="$1"
    {
        echo ""
        echo "----------------------------------------------------------------"
        echo ">> $titulo"
        echo "----------------------------------------------------------------"
    } >> "$ARQ_RELATORIO"
}

# ---- Funcao: gerar o relatorio completo ------------------------------------
gerar_relatorio() {
    mkdir -p "$DIR_LOG"

    # Cabecalho (sobrescreve relatorios anteriores)
    {
        echo "================================================================"
        echo " RELATORIO OPERACIONAL - PLATAFORMA DE PODCASTS"
        echo "================================================================"
        echo " Projeto : $PROJETO"
        echo " Tema    : $TEMA"
        echo " Aluno   : $ALUNO"
        echo " Data    : $(date '+%Y-%m-%d %H:%M:%S')"
    } > "$ARQ_RELATORIO"

    secao "ESPACO EM DISCO"
    df -h / >> "$ARQ_RELATORIO" 2>&1

    secao "USO DOS DIRETORIOS DA APLICACAO ($APP)"
    if [ -d "$APP" ]; then
        du -sh "$APP"/* >> "$ARQ_RELATORIO" 2>&1
    else
        echo "Diretorio $APP ainda nao criado (rode 03_estrutura.sh)." >> "$ARQ_RELATORIO"
    fi

    secao "STATUS DO APACHE"
    if pgrep -x apache2 >/dev/null 2>&1; then
        echo "[OK] Apache em execucao." >> "$ARQ_RELATORIO"
        apache2 -v 2>/dev/null | head -n 1 >> "$ARQ_RELATORIO"
    else
        echo "[ALERTA] Apache NAO esta em execucao." >> "$ARQ_RELATORIO"
    fi

    secao "ULTIMOS BACKUPS (backups/)"
    ls -lht "$DIR_BASE/backups"/*.tar.gz 2>/dev/null | head -n 5 >> "$ARQ_RELATORIO" \
        || echo "Nenhum backup encontrado." >> "$ARQ_RELATORIO"

    secao "ULTIMOS LOGS (logs/)"
    ls -lht "$DIR_LOG"/*.log 2>/dev/null | head -n 10 >> "$ARQ_RELATORIO" \
        || echo "Nenhum log encontrado." >> "$ARQ_RELATORIO"

    secao "ARQUIVOS PUBLICADOS (/var/www/html)"
    ls -lh /var/www/html 2>/dev/null >> "$ARQ_RELATORIO" \
        || echo "Nada publicado (rode 05_deploy.sh)." >> "$ARQ_RELATORIO"

    secao "USUARIOS E PERMISSOES PRINCIPAIS"
    echo "Grupo podcast_ops:" >> "$ARQ_RELATORIO"
    getent group podcast_ops >> "$ARQ_RELATORIO" 2>&1 || echo "grupo nao criado" >> "$ARQ_RELATORIO"
    echo "Usuario audio_user:" >> "$ARQ_RELATORIO"
    id audio_user >> "$ARQ_RELATORIO" 2>&1 || echo "usuario nao criado" >> "$ARQ_RELATORIO"
    if [ -d "$APP/audios" ]; then
        echo "Permissoes de $APP/audios:" >> "$ARQ_RELATORIO"
        ls -ld "$APP/audios" >> "$ARQ_RELATORIO" 2>&1
    fi
}

# ---- Execucao --------------------------------------------------------------
echo "===== RELATORIO OPERACIONAL - PLATAFORMA DE PODCASTS ====="
gerar_relatorio
echo ">> Relatorio gerado em: $ARQ_RELATORIO"
echo ""
cat "$ARQ_RELATORIO"
