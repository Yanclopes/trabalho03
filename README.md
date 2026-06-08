# 🎙 Plataforma de Podcasts e Áudios

**Trabalho 03 — Linux, Shell Script e Automação Operacional aplicada à Cloud**
Disciplina: Cloud Computing · Curso: Sistemas de Informação · Unidavi
Prof. Esp. Ademar Perfoll Junior

---

## 👤 Aluno

- **Nome:** Yan Lopes
- **Tema (Trabalho 01/02):** Plataforma de Podcasts e Áudios

---

## 🎧 Tema do trabalho

Este projeto simula o ambiente operacional de uma **plataforma de podcasts e áudios**, onde episódios precisam ser hospedados, publicados e mantidos em um
servidor Linux. Por se tratar de um tema de mídia/áudio, o ambiente também instala o
**ffmpeg** (processamento e conversão de áudio), conforme previsto na Tarefa 02.

O tema aparece em toda a solução: nomes de diretórios (`/app/podcast/episodios`,
`/audios`, `/transcricoes`, `/capas`), usuário e grupo de sistema (`audio_user`,
`podcast_ops`), conteúdo do site (`index.html`/`sobre.html`), comentários dos scripts,
logs e relatório final.

---

## 🗺 Descrição do cenário

Você foi contratado como profissional júnior de DevOps para preparar o ambiente Linux
da plataforma. A missão é criar um ambiente **containerizado com Ubuntu Server**
e desenvolver scripts Shell para automatizar tarefas operacionais: atualização do sistema,
instalação de serviços, preparação de diretórios, publicação de arquivos estáticos,
backup, monitoramento, controle de permissões e geração de logs/relatórios.

---

## 🧰 Tecnologias utilizadas

- **Ubuntu Server 22.04** (imagem base do container)
- **Docker** e **Docker Compose** (ambiente containerizado + volume persistente)
- **Apache HTTP Server** (publicação do site estático)
- **Bash / Shell Script** (automação das rotinas operacionais)
- **ffmpeg** (processamento de áudio — coerente com o tema de podcasts)

---

## 📁 Estrutura de pastas

```
trabalho03-cloud-shell/
├── Dockerfile               # imagem Ubuntu + Apache + ffmpeg
├── docker-compose.yml       # serviço, porta 8080:80 e volume persistente
├── entrypoint.sh            # publica o site e mantém o Apache em foreground
├── README.md                # esta documentação
├── scripts/
│   ├── 01_update.sh             # atualização do sistema
│   ├── 02_apache.sh             # instalação/validação do Apache + ffmpeg
│   ├── 03_estrutura.sh          # estrutura de diretórios da plataforma
│   ├── 04_backup.sh             # backup .tar.gz com data/hora
│   ├── 05_deploy.sh             # deploy do site para /var/www/html
│   ├── 06_processos.sh          # listar/buscar/matar processos
│   ├── 07_monitoramento.sh      # CPU, memória, disco e Apache + alertas
│   ├── 08_usuarios_permissoes.sh# grupo, usuário, chown/chmod
│   ├── 09_relatorio.sh          # relatório operacional consolidado
│   └── menu.sh                  # menu interativo principal
├── source/                  # site estático da plataforma
│   ├── index.html
│   ├── sobre.html
│   └── assets/
│       └── style.css
├── backups/                 # destino dos backups (.tar.gz)
├── logs/                    # logs e relatório de execução
└── evidencias/              # prints/arquivos de evidência (preencher na sua máquina)
```

---

## ▶️ Como executar o projeto

Pré-requisitos: **Docker** e **Docker Compose** instalados.

```bash
# 1) Na raiz do projeto, suba o ambiente (build + container)
docker compose up -d --build

# 2) Acesse o container
docker exec -it trabalho03-linux bash
```

O `entrypoint.sh` já publica o site e inicia o Apache automaticamente ao subir o container.

---

## 🌐 Como acessar o Apache no navegador

Com o container em execução, abra:

```
http://localhost:8080
```

A porta `8080` do host é mapeada para a porta `80` do container (Apache).

---

## ⚙️ Como executar cada script

Dentro do container, vá até a pasta dos scripts:

```bash
cd /opt/trabalho03-cloud-shell/scripts
chmod +x *.sh   # garante permissão de execução (caso necessário)
```

| Script | O que faz | Como executar |
|--------|-----------|---------------|
| `01_update.sh` | Atualiza o sistema (`apt update`/`upgrade`) e registra log. Função: `atualizar_sistema`. | `./01_update.sh` |
| `02_apache.sh` | Instala e valida o Apache, instala o ffmpeg e exibe a versão. Funções: `instalar_apache`, `verificar_apache`, `versao_apache`. | `./02_apache.sh` |
| `03_estrutura.sh` | Cria a árvore `/app/podcast` (episódios, áudios, transcrições, etc.) com remoção segura da estrutura antiga. | `./03_estrutura.sh` |
| `04_backup.sh` | Gera backup `.tar.gz` com data/hora em `backups/` e valida a integridade. | `./04_backup.sh` |
| `05_deploy.sh` | Limpa `/var/www/html`, copia o site de `source/` e valida o `index.html`. | `./05_deploy.sh` |
| `06_processos.sh` | Lista, busca e encerra processos (bloqueia kill sem PID). Funções: `listar_processos`, `buscar_processo`, `matar_processo`. | `./06_processos.sh listar` · `./06_processos.sh buscar apache` · `./06_processos.sh matar <PID>` |
| `07_monitoramento.sh` | Mostra CPU, memória, disco e status do Apache, com alertas acima de 80%. | `./07_monitoramento.sh` |
| `08_usuarios_permissoes.sh` | Cria o grupo `podcast_ops`, o usuário `audio_user` e aplica `chown`/`chmod 750`. | `./08_usuarios_permissoes.sh` |
| `09_relatorio.sh` | Gera o relatório consolidado em `logs/relatorio_execucao.txt`. | `./09_relatorio.sh` |

---

## 🧭 Como executar o menu principal

```bash
cd /opt/trabalho03-cloud-shell/scripts
./menu.sh
```

O menu permite executar todas as rotinas pelos números de 1 a 9 (0 para sair).


## 🐳 Imagem no DockerHub

```
https://hub.docker.com/r/yanclops/trabalho03
```

Publicação:

```bash
docker tag trabalho03:latest yanclops/trabalho03:latest
docker push yanclops/trabalho03:latest
```


## 🤖 Uso de Inteligência Artificial

> Foi utilizado IA para pesquisa de comando, revisão e documentação do projeto, assim apoiando o aprendizado e desenvolvimento do projeto

