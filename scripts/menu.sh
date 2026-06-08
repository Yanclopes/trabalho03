#!/bin/bash

# Diretorio onde estao os scripts (mesma pasta deste arquivo)
DIR_SCRIPTS="$(cd "$(dirname "$0")" && pwd)"

# ---- Funcao: cabecalho do menu ---------------------------------------------
exibir_cabecalho() {
    clear 2>/dev/null
    echo "Criado por: Yan Lopes"
    echo "Instituicao: Unidavi"
    echo "Tema: Plataforma de Podcasts e Audios"
    echo "===== MENU DEVOPS CLOUD ====="
    echo "1 - Atualizar sistema"
    echo "2 - Instalar Apache"
    echo "3 - Criar estrutura do projeto"
    echo "4 - Realizar backup"
    echo "5 - Fazer deploy"
    echo "6 - Ver processos"
    echo "7 - Monitorar sistema"
    echo "8 - Configurar usuarios e permissoes"
    echo "9 - Gerar relatorio"
    echo "0 - Sair"
    echo "============================="
}

# ---- Funcao: executar a opcao escolhida ------------------------------------
executar_opcao() {
    local opcao="$1"
    case "$opcao" in
        1) bash "$DIR_SCRIPTS/01_update.sh" ;;
        2) bash "$DIR_SCRIPTS/02_apache.sh" ;;
        3) bash "$DIR_SCRIPTS/03_estrutura.sh" ;;
        4) bash "$DIR_SCRIPTS/04_backup.sh" ;;
        5) bash "$DIR_SCRIPTS/05_deploy.sh" ;;
        6)
            echo "Acao de processos (listar | buscar <nome> | matar <PID>)"
            read -r -p "Digite a acao: " acao param
            bash "$DIR_SCRIPTS/06_processos.sh" "$acao" "$param"
            ;;
        7) bash "$DIR_SCRIPTS/07_monitoramento.sh" ;;
        8) bash "$DIR_SCRIPTS/08_usuarios_permissoes.sh" ;;
        9) bash "$DIR_SCRIPTS/09_relatorio.sh" ;;
        0)
            echo "Encerrando o menu. Ate logo!"
            exit 0
            ;;
        *)
            echo "[ERRO] Opcao invalida. Escolha um numero do menu."
            ;;
    esac
}

# ---- Laco principal --------------------------------------------------------
while true; do
    exibir_cabecalho
    read -r -p "Escolha uma opcao: " escolha
    echo ""
    executar_opcao "$escolha"
    echo ""
    read -r -p "Pressione ENTER para voltar ao menu..." _
done
