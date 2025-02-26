#!/bin/bash

printf "\n"
cat <<EOF


░██████╗░░█████╗░  ░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░█████╗░
██╔════╝░██╔══██╗  ██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔══██╗
██║░░██╗░███████║  ██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░██║░░██║
██║░░╚██╗██╔══██║  ██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░██║░░██║
╚██████╔╝██║░░██║  ╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░╚█████╔╝
░╚═════╝░╚═╝░░╚═╝  ░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░░╚════╝░
EOF

printf "\n\n"
# Add after the banner and before dependencies

# Port handling functions
# Add after the banner and before dependencies
is_codespace() {
    [[ -n "${CODESPACES}" ]] || [[ -n "${GITHUB_CODESPACE_TOKEN}" ]]
}

get_random_port() {
    local min_port=8081
    local max_port=8100
    local port
    
    while true; do
        port=$((RANDOM % (max_port - min_port + 1) + min_port))
        if ! sudo lsof -i :"$port" > /dev/null 2>&1; then
            echo "$port"
            break
        fi
    done
}

modify_wasmedge_command() {
    local port="$1"
    local install_dir="$HOME/gaianet"
    
    # Find and modify the WasmEdge command in all relevant files
    find "$install_dir" -type f -exec sed -i "s|socket-addr 0.0.0.0:8080|socket-addr 0.0.0.0:$port|g" {} \;
    
    # Update specific files that might contain the port
    for file in "$install_dir"/bin/gaia.sh "$install_dir"/bin/gaianet "$install_dir"/config.yaml; do
        if [ -f "$file" ]; then
            sed -i "s|:8080|:$port|g" "$file"
        fi
    done
}

setup_node_port() {
    local port="$1"
    local config_dir="$HOME/gaianet"
    
    # Create config if it doesn't exist
    mkdir -p "$config_dir"
    
    # Update config.yaml
    cat > "$config_dir/config.yaml" << EOF
node_id: default
device_id: default
port: $port
log_level: info
EOF

    # Update WasmEdge command in gaia.sh if it exists
    if [ -f "$config_dir/bin/gaia.sh" ]; then
        sed -i "s|socket-addr 0.0.0.0:[0-9]\+|socket-addr 0.0.0.0:$port|g" "$config_dir/bin/gaia.sh"
    fi
}

# Ensure required packages are installed
echo "📦 Installing dependencies..."
sudo apt update -y && sudo apt install -y pciutils libgomp1 curl wget build-essential libglvnd-dev pkg-config libopenblas-dev libomp-dev

# Detect if running inside WSL
IS_WSL=false
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "🖥️ Running inside WSL."
else
    echo "🖥️ Running on a native Ubuntu system."
fi

# Check if an NVIDIA GPU is present
check_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null || lspci | grep -i nvidia &> /dev/null; then
        echo "✅ NVIDIA GPU detected."
        return 0
    else
        echo "⚠️ No NVIDIA GPU found."
        return 1
    fi
}

# Check if the system is a VPS, Laptop, or Desktop
check_system_type() {
    vps_type=$(systemd-detect-virt)
    if echo "$vps_type" | grep -qiE "kvm|qemu|vmware|xen|lxc"; then
        echo "✅ This is a VPS."
        return 0  # VPS
    elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
        echo "✅ This is a Laptop."
        return 1  # Laptop
    else
        echo "✅ This is a Desktop."
        return 2  # Desktop
    fi
}

# Function to install CUDA Toolkit 12.8 in WSL or Ubuntu 24.04
install_cuda() {
    if $IS_WSL; then
        echo "🖥️ Installing CUDA for WSL 2..."
        # Define file names and URLs for WSL
        PIN_FILE="cuda-wsl-ubuntu.pin"
        PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin"
        DEB_FILE="cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
        DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
    else
        echo "🖥️ Installing CUDA for Ubuntu 24.04..."
        # Define file names and URLs for Ubuntu 24.04
        PIN_FILE="cuda-ubuntu2404.pin"
        PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin"
        DEB_FILE="cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
        DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
    fi

    # Download the .pin file if it doesn't exist
    if [ ! -f "$PIN_FILE" ]; then
        echo "📥 Downloading $PIN_FILE from $PIN_URL..."
        wget "$PIN_URL" || { echo "❌ Failed to download $PIN_FILE from $PIN_URL"; exit 1; }
    else
        echo "✅ $PIN_FILE already exists. Skipping download."
    fi

    # Move the .pin file to the correct location
    sudo mv "$PIN_FILE" /etc/apt/preferences.d/cuda-repository-pin-600 || { echo "❌ Failed to move $PIN_FILE to /etc/apt/preferences.d/"; exit 1; }

    # Download the .deb file if it doesn't exist
    if [ ! -f "$DEB_FILE" ]; then
        echo "📥 Downloading $DEB_FILE from $DEB_URL..."
        wget "$DEB_URL" || { echo "❌ Failed to download $DEB_FILE from $DEB_URL"; exit 1; }
    else
        echo "✅ $DEB_FILE already exists. Skipping download."
    fi

    # Install the .deb file
    sudo dpkg -i "$DEB_FILE" || { echo "❌ Failed to install $DEB_FILE"; exit 1; }

    # Copy the keyring
    sudo cp /var/cuda-repo-*/cuda-*-keyring.gpg /usr/share/keyrings/ || { echo "❌ Failed to copy CUDA keyring to /usr/share/keyrings/"; exit 1; }

    # Update the package list and install CUDA Toolkit 12.8
    echo "🔄 Updating package list..."
    sudo apt-get update || { echo "❌ Failed to update package list"; exit 1; }
    echo "🔧 Installing CUDA Toolkit 12.8..."
    sudo apt-get install -y cuda-toolkit-12-8 || { echo "❌ Failed to install CUDA Toolkit 12.8"; exit 1; }

    echo "✅ CUDA Toolkit 12.8 installed successfully."
    setup_cuda_env
}

# Set up CUDA environment variables
setup_cuda_env() {
    echo "🔧 Setting up CUDA environment variables..."
    echo 'export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}' | sudo tee /etc/profile.d/cuda.sh
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' | sudo tee -a /etc/profile.d/cuda.sh
    source /etc/profile.d/cuda.sh
}

# Install GaiaNet with appropriate CUDA support
install_gaianet() {
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep 'release' | awk '{print $6}' | cut -d',' -f1 | sed 's/V//g' | cut -d'.' -f1)
        echo "✅ CUDA version detected: $CUDA_VERSION"
        if [[ "$CUDA_VERSION" == "11" || "$CUDA_VERSION" == "12" ]]; then
            echo "🔧 Installing GaiaNet with ggmlcuda $CUDA_VERSION..."
            curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' -o install.sh
            chmod +x install.sh
            ./install.sh --ggmlcuda $CUDA_VERSION || { echo "❌ GaiaNet installation with CUDA failed."; exit 1; }
            return
        fi
    fi
    echo "⚠️ Installing GaiaNet without GPU support..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' | bash || { echo "❌ GaiaNet installation without GPU failed."; exit 1; }
}

# Add GaiaNet to PATH
add_gaianet_to_path() {
    echo "🔧 Adding GaiaNet to PATH for both user and root..."
    
    # Define the GaiaNet path
    GAIA_PATH="$HOME/gaianet/bin"

    # Update user's .bashrc
    if ! grep -q "$GAIA_PATH" ~/.bashrc; then
        echo "export PATH=$GAIA_PATH:\$PATH" >> ~/.bashrc
    fi

    # Update root's .bashrc (run only if script is executed with sudo)
    if [ "$EUID" -eq 0 ]; then
        if ! grep -q "$GAIA_PATH" /root/.bashrc; then
            echo "export PATH=$GAIA_PATH:\$PATH" >> /root/.bashrc
        fi
    fi

    # Update system-wide environment (for all users, including sudo)
    if ! grep -q "$GAIA_PATH" /etc/profile.d/gaianet.sh 2>/dev/null; then
        echo "export PATH=$GAIA_PATH:\$PATH" | sudo tee /etc/profile.d/gaianet.sh >/dev/null
    fi

    # Apply changes
    source ~/.bashrc
    [ "$EUID" -eq 0 ] && source /root/.bashrc
    source /etc/profile.d/gaianet.sh

    echo "✅ GaiaNet added to PATH successfully."
}

# Main logic
if check_nvidia_gpu; then
    setup_cuda_env
    install_cuda
    add_gaianet_to_path
    install_gaianet
else
    install_gaianet
fi

# Verify GaiaNet installation
if [ -f ~/gaianet/bin/gaianet ]; then
    echo "✅ GaiaNet installed successfully."
    add_gaianet_to_path
else
    echo "❌ GaiaNet installation failed. Exiting."
    exit 1
fi

# Determine system type and set configuration URL
check_system_type
SYSTEM_TYPE=$?  # Capture the return value of check_system_type

if [[ $SYSTEM_TYPE -eq 0 ]]; then
    # VPS
    CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
elif [[ $SYSTEM_TYPE -eq 1 ]]; then
    # Laptop
    if ! check_nvidia_gpu; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
    else
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config1.json"
    fi
elif [[ $SYSTEM_TYPE -eq 2 ]]; then
    # Desktop
    if ! check_nvidia_gpu; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
    else
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config3.json"
    fi
fi

# Replace the initialization section

# Get random port
PORT=$(get_random_port)
echo "🔍 Selected port: $PORT"

# Initialize GaiaNet with config
echo "⚙️ Initializing GaiaNet..."
~/gaianet/bin/gaianet init --config "$CONFIG_URL" || { echo "❌ GaiaNet initialization failed!"; exit 1; }

# Modify WasmEdge command to use the random port
modify_wasmedge_command "$PORT"

echo "🚀 Starting GaiaNet node..."
~/gaianet/bin/gaianet config --domain gaia.domains

# Stop any existing processes
sudo pkill -f "wasmedge|gaianet" >/dev/null 2>&1
sleep 3

# Start node with new port
~/gaianet/bin/gaianet start || { echo "❌ Error: Failed to start GaiaNet node!"; exit 1; }

# Verify node is running
sleep 5
if pgrep -f "wasmedge.*:$PORT" >/dev/null; then
    echo "✅ Node successfully started on port $PORT"
    if is_codespace; then
        gh codespace ports visibility "$PORT:public" >/dev/null 2>&1
        gh codespace ports forward "$PORT:$PORT" >/dev/null 2>&1 &
        echo "🌐 Codespace URL: https://$CODESPACE_NAME-$PORT.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    fi
else
    echo "❌ Node failed to start properly"
    echo "📋 Debug information:"
    ps aux | grep -E "wasmedge|gaianet"
    sudo lsof -i :"$PORT"
    exit 1
fi

echo "🔍 Fetching GaiaNet node information..."
~/gaianet/bin/gaianet info || { echo "❌ Error: Failed to fetch GaiaNet node information!"; exit 1; }



# Closing message
echo "==========================================================="
echo "🎉 Congratulations! Your GaiaNet node is successfully set up!"
echo "🌟 Stay connected: Telegram: https://t.me/GaCryptOfficial | Twitter: https://x.com/GACryptoO"
echo "💪 Together, let's build the future of decentralized networks!"
echo "===========================================================" 
