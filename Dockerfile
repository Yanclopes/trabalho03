# =============================================================================
# Trabalho 03 - Plataforma de Podcasts e Audios
# Dockerfile - imagem Ubuntu com Apache + ffmpeg para o ambiente de podcasts
# =============================================================================
FROM ubuntu:22.04

# Evita prompts interativos durante a instalacao de pacotes
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza o sistema e instala os pacotes base do ambiente:
# - apache2  : servidor web que publica o site da plataforma de podcasts
# - ffmpeg   : processamento de audio (coerente com o tema)
# - utilitarios usados pelos scripts (procps, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2 \
        ffmpeg \
        procps \
        nano \
        sudo \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Diretorio de trabalho do projeto dentro do container
WORKDIR /opt/trabalho03-cloud-shell

# Copia os scripts, o site estatico e o entrypoint para dentro do container
COPY scripts/   ./scripts/
COPY source/    ./source/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Garante permissao de execucao nos scripts e no entrypoint
RUN chmod +x ./scripts/*.sh /usr/local/bin/entrypoint.sh

# Expoe a porta do Apache
EXPOSE 80

# O entrypoint publica o site e mantem o Apache em primeiro plano
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
