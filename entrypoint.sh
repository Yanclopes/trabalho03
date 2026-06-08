#!/bin/bash
# =============================================================================
# Trabalho 03 - Plataforma de Podcasts e Audios
# entrypoint.sh - executado quando o container inicia.
# Publica o site estatico em /var/www/html e mantem o Apache em primeiro plano
# (foreground), necessario para o container continuar em execucao.
# =============================================================================

echo "[entrypoint] Iniciando o ambiente"

# Publica o site da plataforma de podcasts no diretorio do Apache
if [ -d /opt/trabalho03-cloud-shell/source ]; then
    rm -rf /var/www/html/*
    cp -r /opt/trabalho03-cloud-shell/source/* /var/www/html/
    echo "[entrypoint] Site publicado em /var/www/html."
fi

# Mantem o Apache rodando em primeiro plano (mantem o container vivo)
echo "[entrypoint] Subindo o Apache em foreground..."
exec apache2ctl -D FOREGROUND
