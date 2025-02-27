#!/bin/bash

# ----------------------------
# Color and Icon Definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

ICON_INSTALL="\xf0\x9f\xa7\xa0"
ICON_RESTART="\xf0\x9f\x94\x84"
ICON_CHECK="\xe2\x9c\x85"
ICON_LOG_OP_NODE="\xf0\x9f\x93\x84"
ICON_LOG_EXEC_CLIENT="\xf0\x9f\x93\x84"
ICON_DISABLE="\xe2\x8f\xb9"
ICON_EXIT="\xe2\x9d\x8c"
ICON_WALLLET="\xf0\x9f\x94\x90"

# ----------------------------
# Function to display ASCII logo
# ----------------------------
display_header() {
    clear
    echo -e "${RED}WINGS NODE TEAM - UNICHAIN MAINNET${RESET}"
    echo -e "${MAGENTA}📢 Follow us on Twitter: https://x.com/wingsnodeteam${RESET}"
    echo -e "${GREEN}Welcome to the Unichain Mainnet Node Management Interface!${RESET}\n"
}

# ----------------------------
# Install Node
# ----------------------------
install_node() {
    cd
    if docker ps -a --format '{{.Names}}' | grep -q "^unichain-node-execution-client-1$"; then
        echo -e "${YELLOW}🟡 Node is already installed.${RESET}"
    else
        echo -e "${GREEN}🟢 Installing node...${RESET}"
        sudo apt update && sudo apt upgrade -y
        sudo apt install docker.io -y
        sudo systemctl start docker
        sudo systemctl enable docker

        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        git clone https://github.com/Uniswap/unichain-node
        cd unichain-node || { echo -e "${RED}❌ Failed to enter unichain-node directory.${RESET}"; return; }

        if [[ -f .env.mainnet ]]; then
            sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=<ВАШ_ETHEREUM_L1_RPC>|' .env.mainnet
            sed -i 's|^OP_NODE_L1_BEACON=.*$|OP_NODE_L1_BEACON=<ВАШ_ETHEREUM_L1_BEACON>|' .env.mainnet
            sed -i 's|^GETH_ROLLUP_SEQUENCERHTTP=.*$|GETH_ROLLUP_SEQUENCERHTTP=https://mainnet-sequencer.unichain.org|' .env.mainnet
        else
            echo -e "${RED}❌ .env.mainnet file not found!${RESET}"
            return
        fi

        sudo docker-compose up -d

        echo -e "${GREEN}✅ Node has been successfully installed.${RESET}"
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Restart Node
# ----------------------------
restart_node() {
    echo -e "${GREEN}🔄 Restarting node...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Node has been restarted.${RESET}"
    echo
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Main Loop
# ----------------------------
while true; do
    display_header
    echo -e "${YELLOW}Please choose an option:${RESET}"
    echo -e "${CYAN}1.${RESET} ${ICON_INSTALL} Install node"
    echo -e "${CYAN}2.${RESET} ${ICON_RESTART} Restart node"
    echo -e "${CYAN}0.${RESET} ${ICON_EXIT} Exit"
    echo -ne "${YELLOW}Enter your choice [0-2]: ${RESET}"
    read choice
    case $choice in
        1) install_node ;;
        2) restart_node ;;
        0) echo -e "${GREEN}❌ Exiting...${RESET}"; exit 0 ;;
        *) echo -e "${RED}❌ Invalid option. Please try again.${RESET}"; read -p "Press Enter to continue..." ;;
    esac
done
