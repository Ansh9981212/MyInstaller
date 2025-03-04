
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

##########################################################################################
#                                                                                        
#                🚀 THIS SCRIPT IS PROUDLY CREATED BY **GA CRYPTO**! 🚀                 
#                                                                                        
#   🌐 Join our revolution in decentralized networks and crypto innovation!               
#                                                                                        
# 📢 Stay updated:                                                                      
#     • Follow us on Telegram: https://t.me/GaCryptOfficial                             
#     • Follow us on X: https://x.com/GACryptoO                                         
##########################################################################################

# Green color for advertisement
GREEN="\033[0;32m"
RESET="\033[0m"


FORCE_GPU_MODE=""
FORCE_CONFIG=""

# Modify the check_nvidia_gpu function
check_nvidia_gpu() {
    # Add at the beginning of the function
    if [ -n "$FORCE_GPU_MODE" ]; then
        echo "⚠️ Running in forced GPU mode: $FORCE_GPU_MODE"
        return 0
    fi
    ...existing check_nvidia_gpu code...
}






# Ensure required packages are installed
echo "📦 Installing dependencies..."
sudo apt update -y && sudo apt install -y pciutils libgomp1 curl wget build-essential libglvnd-dev pkg-config libopenblas-dev libomp-dev


# Add this with other package installations at the beginning

# Ensure required packages are installed
echo "📦 Installing dependencies..."
sudo apt update -y && sudo apt install -y pciutils libgomp1 curl wget build-essential libglvnd-dev pkg-config libopenblas-dev libomp-dev jq



# Detect if running inside WSL
IS_WSL=false
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "🖥️ Running inside WSL."
else
    echo "🖥️ Running on a native Ubuntu system."
fi

check_nvidia_gpu() {
    if [ -n "$FORCE_GPU_MODE" ]; then
        echo "⚠️ Running in forced GPU mode: $FORCE_GPU_MODE"
        return 0
    fi
    # ...existing nvidia check code...
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

# Add after add_gaianet_to_path() function and before Main logic

generate_random_port() {
    local port
    while true; do
        port=$(shuf -i 8080-8500 -n 1)
        if ! sudo lsof -i :"$port" > /dev/null 2>&1; then
            echo "$port"
            break
        fi
    done
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

# Replace the existing configuration section
if [ -n "$FORCE_CONFIG" ]; then
    CONFIG_URL="$FORCE_CONFIG"
    echo "⚠️ Using forced configuration: $CONFIG_URL"
else
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
fi

# Add before the initialization section
if [ -n "$FORCE_GPU_MODE" ]; then
    echo "⚠️ WARNING: Running in forced GPU mode without hardware verification"
    echo "⚠️ This may affect performance or cause instability"
    echo "⚠️ Press Ctrl+C within 5 seconds to abort..."
    sleep 5
fi

# Initialize and start GaiaNet
echo "⚙️ Initializing GaiaNet..."
RANDOM_PORT=$(generate_random_port)
echo "🔌 Selected port: $RANDOM_PORT"

# Download and modify config
echo "📥 Downloading and modifying configuration..."
TMP_CONFIG=$(mktemp)
curl -s "$CONFIG_URL" > "$TMP_CONFIG"

# Update port in config
jq ".llamaedge_port = \"$RANDOM_PORT\"" "$TMP_CONFIG" > "$TMP_CONFIG.new"
mv "$TMP_CONFIG.new" "$TMP_CONFIG"

# Initialize with modified config
~/gaianet/bin/gaianet init --config "file://$TMP_CONFIG" || { echo "❌ GaiaNet initialization failed!"; rm "$TMP_CONFIG"; exit 1; }

# Cleanup
rm "$TMP_CONFIG"

echo "🚀 Starting GaiaNet node on port $RANDOM_PORT..."
~/gaianet/bin/gaianet config --domain gaia.domains
~/gaianet/bin/gaianet start || { echo "❌ Error: Failed to start GaiaNet node!"; exit 1; }

echo "🔍 Fetching GaiaNet node information..."
~/gaianet/bin/gaianet info || { echo "❌ Error: Failed to fetch GaiaNet node information!"; exit 1; }

# Update the closing message to include port information
echo "==========================================================="
echo "🎉 Congratulations! Your GaiaNet node is successfully set up!"
echo "🔌 Node is running on port: $RANDOM_PORT"
echo "🌟 Stay connected: Telegram: https://t.me/GaCryptOfficial | Twitter: https://x.com/GACryptoO"
echo "💪 Together, let's build the future of decentralized networks!"
echo "==========================================================="
