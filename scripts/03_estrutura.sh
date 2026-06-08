#!/bin/bash

# ---- Variaveis -------------------------------------------------------------
DIR_BASE="$(cd "$(dirname "$0")/.." && pwd)"
DIR_LOG="$DIR_BASE/logs"
ARQ_LOG="$DIR_LOG/03_estrutura.log"

# Raiz da aplicacao da plataforma de podcasts dentro do container
APP="/app/podcast"

# Lista de diretorios tematicos (nomes coerentes com uma plataforma de audio)
DIRETORIOS=(
    "$APP/episodios"      # arquivos de audio dos episodios publicados
    "$APP/audios"         # audios brutos enviados para edicao
    "$APP/transcricoes"   # transcricoes e legendas dos episodios
    "$APP/capas"          # imagens de capa dos podcasts
    "$APP/dados"          # metadados (titulos, descricoes, RSS)
    "$APP/publicacao"     # conteudo pronto para o servidor web
    "$APP/logs"           # logs internos da aplicacao
    "$APP/backups"        # backups internos da aplicacao
)

registrar_log() {
    local mensagem="$1"
    mkdir -p "$DIR_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$ARQ_LOG"
}

# ---- Funcao: remover estrutura antiga com seguranca ------------------------
# So remove se o caminho for exatamente /app/podcast, evitando rm acidental.
limpar_estrutura_antiga() {
    if [ -d "$APP" ]; then
        if [ "$APP" = "/app/podcast" ]; then
            registrar_log "Removendo estrutura antiga em $APP ..."
            rm -rf "${APP:?}/"*
            registrar_log "[OK] Estrutura antiga removida com seguranca."
        else
            registrar_log "[ERRO] Caminho inesperado ($APP). Remocao abortada."
            return 1
        fi
    else
        registrar_log "Nenhuma estrutura anterior encontrada. Seguindo com a criacao."
    fi
}

# ---- Funcao: criar a estrutura de diretorios -------------------------------
criar_estrutura() {
    registrar_log "Criando estrutura de diretorios da plataforma de podcasts..."
    for dir in "${DIRETORIOS[@]}"; do
        mkdir -p "$dir"
        registrar_log "  -> criado: $dir"
    done

    # Arquivos iniciais de exemplo coerentes com o tema
    echo "Episodio 01 - Bem-vindo" > "$APP/episodios/ep01.txt"
    echo "titulo;descricao;duracao" > "$APP/dados/catalogo.csv"
    echo "Transcricao do episodio 01..." > "$APP/transcricoes/ep01.txt"
    registrar_log "[OK] Arquivos iniciais de exemplo criados."
}

# ---- Execucao --------------------------------------------------------------
echo "===== ESTRUTURA DE DIRETORIOS - PLATAFORMA DE PODCASTS ====="
limpar_estrutura_antiga
criar_estrutura
echo ">> Estrutura criada em $APP"
echo ">> Conferindo a arvore criada:"
ls -R "$APP"
echo ">> Log disponivel em: $ARQ_LOG"
