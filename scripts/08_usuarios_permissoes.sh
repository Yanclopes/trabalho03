#!/bin/bash

# ---- Variaveis -------------------------------------------------------------
DIR_BASE="$(cd "$(dirname "$0")/.." && pwd)"
DIR_LOG="$DIR_BASE/logs"
ARQ_LOG="$DIR_LOG/08_usuarios_permissoes.log"

# Nomes coerentes com o tema (plataforma de podcasts/audios)
GRUPO="podcast_ops"
USUARIO="audio_user"
DIR_ALVO="/app/podcast/audios"

registrar_log() {
    local mensagem="$1"
    mkdir -p "$DIR_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$ARQ_LOG"
}

# ---- Funcao: criar grupo e usuario -----------------------------------------
criar_usuarios_grupos() {
    if [ "$(id -u)" -ne 0 ]; then
        registrar_log "[ERRO] Criacao de usuarios/grupos exige privilegios de root."
        return 1
    fi

    # Cria o grupo se ainda nao existir
    if getent group "$GRUPO" >/dev/null 2>&1; then
        registrar_log "[INFO] Grupo '$GRUPO' ja existe."
    else
        groupadd "$GRUPO" && registrar_log "[OK] Grupo '$GRUPO' criado."
    fi

    # Cria um usuario de sistema (sem login interativo) e o adiciona ao grupo
    if id "$USUARIO" >/dev/null 2>&1; then
        registrar_log "[INFO] Usuario '$USUARIO' ja existe."
    else
        useradd --system --no-create-home --shell /usr/sbin/nologin \
                --gid "$GRUPO" "$USUARIO" \
            && registrar_log "[OK] Usuario de sistema '$USUARIO' criado no grupo '$GRUPO'."
    fi
}

# ---- Funcao: aplicar permissoes --------------------------------------------
aplicar_permissoes() {
    # Garante a existencia do diretorio alvo
    mkdir -p "$DIR_ALVO"

    registrar_log "Aplicando dono (chown) $USUARIO:$GRUPO em $DIR_ALVO..."
    chown -R "$USUARIO":"$GRUPO" "$DIR_ALVO" \
        && registrar_log "[OK] chown aplicado."

    # 750 = dono (rwx), grupo (r-x), outros (sem acesso).
    # Evitamos 777: os audios da plataforma nao devem ser graváveis por todos.
    registrar_log "Aplicando permissoes 750 em $DIR_ALVO (sem 777, por seguranca)..."
    chmod -R 750 "$DIR_ALVO" \
        && registrar_log "[OK] chmod 750 aplicado."

    echo ">> Permissoes atuais de $DIR_ALVO:"
    ls -ld "$DIR_ALVO"
}

# ---- Execucao --------------------------------------------------------------
echo "===== USUARIOS, GRUPOS E PERMISSOES - PLATAFORMA DE PODCASTS ====="
echo ">> Grupo  : $GRUPO"
echo ">> Usuario: $USUARIO"
echo ">> Pasta  : $DIR_ALVO"
criar_usuarios_grupos
aplicar_permissoes
echo ">> Concluido. Log disponivel em: $ARQ_LOG"
