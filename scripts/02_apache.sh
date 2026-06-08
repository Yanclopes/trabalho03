#!/bin/bash

# ---- Variaveis -------------------------------------------------------------
DIR_BASE="$(cd "$(dirname "$0")/.." && pwd)"
DIR_LOG="$DIR_BASE/logs"
ARQ_LOG="$DIR_LOG/02_apache.log"

registrar_log() {
    local mensagem="$1"
    mkdir -p "$DIR_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$ARQ_LOG"
}

# ---- Funcao: instalar o Apache ---------------------------------------------
instalar_apache() {
    if [ "$(id -u)" -ne 0 ]; then
        registrar_log "[ERRO] Instalacao do Apache exige privilegios de root."
        return 1
    fi

    registrar_log "Instalando o Apache2..."
    apt update >>"$ARQ_LOG" 2>&1
    if DEBIAN_FRONTEND=noninteractive apt install -y apache2 >>"$ARQ_LOG" 2>&1; then
        registrar_log "[OK] Apache2 instalado."
    else
        registrar_log "[FALHA] Nao foi possivel instalar o Apache2."
        return 1
    fi

    # Tema de audio/podcast: instala ffmpeg para processamento de audio.
    registrar_log "Instalando ferramenta de audio (ffmpeg) - coerente com o tema podcasts..."
    if DEBIAN_FRONTEND=noninteractive apt install -y ffmpeg >>"$ARQ_LOG" 2>&1; then
        registrar_log "[OK] ffmpeg instalado (conversao/transcodificacao de audios)."
    else
        registrar_log "[AVISO] ffmpeg nao pode ser instalado, mas o Apache esta operacional."
    fi

    # Inicia o servico. Em containers sem systemd usamos 'service'/apache2ctl.
    iniciar_apache
}

# ---- Funcao: iniciar o Apache (tolerante a ambiente sem systemd) -----------
iniciar_apache() {
    registrar_log "Iniciando o servico Apache..."
    if service apache2 start >>"$ARQ_LOG" 2>&1; then
        registrar_log "[OK] Apache iniciado via 'service'."
    elif apache2ctl start >>"$ARQ_LOG" 2>&1; then
        registrar_log "[OK] Apache iniciado via 'apache2ctl'."
    else
        registrar_log "[AVISO] Nao foi possivel iniciar via service/apache2ctl."
    fi
}

# ---- Funcao: verificar se o Apache esta instalado --------------------------
verificar_apache() {
    if command -v apache2 >/dev/null 2>&1; then
        registrar_log "[OK] Apache esta instalado no sistema."
        return 0
    else
        registrar_log "[FALHA] Apache NAO esta instalado."
        return 1
    fi
}

# ---- Funcao: exibir a versao do Apache -------------------------------------
versao_apache() {
    if command -v apache2 >/dev/null 2>&1; then
        local versao
        versao="$(apache2 -v | head -n 1)"
        registrar_log "Versao instalada: $versao"
    else
        registrar_log "[FALHA] Nao foi possivel obter a versao (Apache ausente)."
        return 1
    fi
}

# ---- Execucao --------------------------------------------------------------
echo "===== INSTALACAO E VALIDACAO DO APACHE - PLATAFORMA DE PODCASTS ====="
instalar_apache
verificar_apache
versao_apache
echo ">> Operacao concluida. Log disponivel em: $ARQ_LOG"
