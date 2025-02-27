#!/bin/bash

# Color definitions
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

echo -e "${GREEN}🔧 Force GPU Installation Mode${RESET}"
echo "=============================="

# Check command line argument
if [ "$1" = "laptop" ]; then
    echo -e "${YELLOW}📱 Setting up laptop GPU mode...${RESET}"
    export FORCE_GPU_MODE="laptop"
    export FORCE_CONFIG="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config1.json"
elif [ "$1" = "desktop" ]; then
    echo -e "${YELLOW}🖥️ Setting up desktop GPU mode...${RESET}"
    export FORCE_GPU_MODE="desktop"
    export FORCE_CONFIG="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config3.json"
else
    echo -e "${RED}❌ Invalid mode selected${RESET}"
    echo "Usage: $0 [laptop|desktop]"
    echo "Examples:"
    echo "  ./force_gpu_install.sh laptop   - Force laptop GPU mode"
    echo "  ./force_gpu_install.sh desktop  - Force desktop GPU mode"
    exit 1
fi

# Warning message
echo -e "${RED}⚠️ WARNING: This will force GPU mode without hardware verification${RESET}"
echo "This may affect performance or cause instability"
echo -n "Do you want to continue? (y/N): "
read -r confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Installation cancelled${RESET}"
    exit 1
fi

echo -e "${GREEN}🚀 Starting forced GPU installation...${RESET}"
rm -rf 1.sh
curl -O https://raw.githubusercontent.com/abhiag/Gaiatest/main/1.sh
chmod +x 1.sh
./1.sh
