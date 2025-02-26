#!/bin/bash

# Check if sudo is installed
if ! command -v sudo &> /dev/null; then
    echo "❌ sudo is not installed. Installing sudo..."
    apt update
    apt install -y sudo
else
    echo "✅ sudo is already installed."
fi

# Check if screen is installed
if ! command -v screen &> /dev/null; then
    echo "❌ screen is not installed. Installing screen..."
    sudo apt update
    sudo apt install -y screen
else
    echo "✅ screen is already installed."
fi

# Check if net-tools is installed
if ! command -v ifconfig &> /dev/null; then
    echo "❌ net-tools is not installed. Installing net-tools..."
    sudo apt install -y net-tools
else
    echo "✅ net-tools is already installed."
fi

# Check if lsof is installed
if ! command -v lsof &> /dev/null; then
    echo "❌ lsof is not installed. Installing lsof..."
    sudo apt update
    sudo apt install -y lsof
    sudo apt upgrade -y
else
    echo "✅ lsof is already installed."
fi



is_codespace() {
    [[ -n "${CODESPACES}" ]] || [[ -n "${GITHUB_CODESPACE_TOKEN}" ]]
}

get_random_port() {
    local min_port=8080
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




# Function to list active screen sessions and allow user to select one
select_screen_session() {
    while true; do
        echo "Checking for active screen sessions..."
        
        # Get the list of active screen sessions
        sessions=$(screen -list | grep -oP '\d+\.\S+' | awk '{print $1}')
        
        # Check if there are any active sessions
        if [ -z "$sessions" ]; then
            echo "No active screen sessions found."
            return  # Return to the main menu
        fi
        
        # Display the list of sessions with numbers
        echo "Active screen sessions:"
        i=1
        declare -A session_map
        for session in $sessions; do
            session_name=$(echo "$session" | cut -d'.' -f2)
            echo "$i) $session_name"
            session_map[$i]=$session
            i=$((i+1))
        done
        
        # Prompt the user to select a session
        echo -n "Select a session by number (1, 2, 3, ...) or press Enter to return to the main menu: "
        read -r choice
        
        # If the user presses Enter, return to the main menu
        if [ -z "$choice" ]; then
            return  # Return to the main menu
        fi
        
        # Validate the user's choice
        if [[ -z "${session_map[$choice]}" ]]; then
            echo "Invalid selection. Please try again."
            continue
        fi
        
        # Attach to the selected session
        selected_session=${session_map[$choice]}
        echo "Attaching to session: $selected_session"
        screen -d -r "$selected_session"
        break
    done
}

while true; do
    clear
    echo "==============================================================="
    echo -e "\e[1;36m🚀🚀 GAIANET NODE INSTALLER Tool-Kit BY GA CRYPTO 🚀🚀\e[0m"

    echo -e "\e[1;85m📢 Stay updated:\e[0m"
    echo -e "\e[1;85m🔹 Telegram: https://t.me/GaCryptOfficial\e[0m"
    echo -e "\e[1;85m🔹 X (Twitter): https://x.com/GACryptoO\e[0m"

    echo "==============================================================="
    echo -e "\e[1;97m✨ Your GPU, CPU & RAM Specs Matter a Lot for Optimal Performance! ✨\e[0m"
    echo "==============================================================="
    
    # Performance & Requirement Section
    echo -e "\e[1;96m⏱  Keep Your Node Active Minimum 15 - 20 Hours Each Day! ⏳\e[0m"
    echo -e "\e[1;91m⚠️  Don’t Run Multiple Nodes if You Only Have 6-8GB RAM! ❌\e[0m"
    echo -e "\e[1;94m☁️  VPS Requirements: 8 Core+ CPU & 6-8GB RAM (Higher is Better) ⚡\e[0m"
    echo -e "\e[1;92m💻  Supported GPUs: RTX 20/30/40/50 Series Or Higher 🟢\e[0m"
    echo "==============================================================="
    
    echo -e "\e[1;33m🎮  Desktop GPU Users: Higher Points – 10x More Powerful than Laptop GPUs! ⚡🔥\e[0m"
    echo -e "\e[1;33m💻  Laptop GPU Users: Earn More Points Than Non-GPU Users 🚀💸\e[0m"
    echo -e "\e[1;33m🌐  VPS/Non-GPU Users: Earn Based on VPS Specifications ⚙️📊\e[0m"
    echo "==============================================================="
    echo -e "\e[1;32m✅ Earn Gaia Points Continuously – Keep Your System Active for Maximum Rewards! 💰💰\e[0m"
    echo "==============================================================="
    
    # Menu Options
    echo -e "\n\e[1mSelect an action:\e[0m\n"
echo -e "1) \e[1;46m\e[97m☁️  Install Gaia-Node (VPS/Non-GPU)\e[0m"
echo -e "   \e[1;36m🌐  Set up Gaia-Node on a Virtual Private Server (VPS) or a system without a GPU.\e[0m"
echo -e "   \e[1;36m💻  Ideal for users with limited hardware resources.\e[0m"
echo -e "   \e[1;36m⚙️  Requires a stable internet connection.\e[0m"

echo -e "2) \e[1;45m\e[97m💻  Install Gaia-Node (Laptop Nvidia GPU)\e[0m"
echo -e "   \e[1;35m💡 Optimized for laptops with Nvidia GPUs for enhanced performance.\e[0m"
echo -e "   \e[1;35m🔧 Ensure your GPU drivers are up-to-date for seamless installation.\e[0m"
echo -e "   \e[1;35m🚀 Perfect for users who want to maximize their node's efficiency.\e[0m"

echo -e "3) \e[1;44m\e[97m🎮  Install Gaia-Node (Desktop NVIDIA GPU)\e[0m"
echo -e "   \e[1;34m🖥️  Designed for desktops with powerful NVIDIA GPUs.\e[0m"
echo -e "   \e[1;34m⚡  Delivers the highest performance and earning potential.\e[0m"
echo -e "   \e[1;34m🔥  Recommended for advanced users with high-end hardware.\e[0m"

echo -e "4) \e[1;42m\e[97m🤖  Start Auto Chat With Ai-Agent\e[0m"
echo -e "   \e[1;32m🚀 Engage in automated conversations with the AI Agent to explore its capabilities.\e[0m"
echo -e "   \e[1;32m💡 Perfect for testing AI responses or automating repetitive tasks.\e[0m"
echo -e "   \e[1;32m🔧 Requires an active internet connection and proper configuration.\e[0m"

echo -e "5) \e[1;100m\e[97m🔍  Switch to Active Screens\e[0m"
echo -e "   \e[1;37m🖥️  Seamlessly switch between active terminal sessions or screens.\e[0m"
echo -e "   \e[1;37m📂  Ideal for managing multiple tasks or monitoring ongoing processes.\e[0m"
echo -e "   \e[1;37m⚙️  Use this to navigate between different workspaces efficiently.\e[0m"

echo -e "6) \e[1;41m\e[97m✋  Stop Auto Chatting With Ai-Agent\e[0m"
echo -e "   \e[1;31m🛑  Halt all automated conversations with the AI Agent immediately.\e[0m"
echo -e "   \e[1;31m⚠️  Use this if the AI Agent is consuming too many resources or behaving unexpectedly.\e[0m"
echo -e "   \e[1;31m🔌  Ensures your system returns to normal operation.\e[0m"

echo "==============================================================="

echo -e "7) \e[1;43m\e[97m🔄  Restart GaiaNet Node\e[0m"
echo -e "   \e[1;33m♻️  Restart the GaiaNet Node to apply updates or resolve issues.\e[0m"
echo -e "   \e[1;33m🛠️  Useful after configuration changes or performance tweaks.\e[0m"
echo -e "   \e[1;33m⏳ May take a few moments to restart completely.\e[0m"

echo -e "8) \e[1;43m\e[97m⏹️  Stop GaiaNet Node\e[0m"
echo -e "   \e[1;33m🛑 Gracefully shut down the GaiaNet Node.\e[0m"
echo -e "   \e[1;33m⚠️  Use this to stop the node temporarily for maintenance or updates.\e[0m"
echo -e "   \e[1;33m🔌 Ensure all processes are safely terminated.\e[0m"

echo "==============================================================="

echo -e "9) \e[1;46m\e[97m🔍  Check Your Gaia Node ID & Device ID\e[0m"
echo -e "   \e[1;36m📋 Retrieve your unique Gaia Node ID and Device ID for identification.\e[0m"
echo -e "   \e[1;36m🔑 Essential for troubleshooting and node management.\e[0m"
echo -e "   \e[1;36m📊 Use this information to track your node's performance.\e[0m"

echo "==============================================================="

    echo -e "\e[1;91m⚠️  DANGER ZONE:\e[0m"
    echo -e "10) \e[1;31m🗑️  Uninstall GaiaNet Node (Risky Operation)\e[0m"
    echo "==============================================================="
    
    echo -e "0) \e[1;31m❌  Exit Installer\e[0m"
    echo "==============================================================="
    
    read -rp "Enter your choice: " choice

    case $choice in
     1|2|3)
    echo "Installing Gaia-Node..."
    
    # Stop existing processes
    if pgrep -f "gaianet|wasmedge" > /dev/null; then
        echo "🛑 Stopping existing processes..."
        ~/gaianet/bin/gaianet stop 2>/dev/null
        sleep 2
        sudo pkill -f "gaianet|wasmedge"
    fi
    
    # Get random port
    port=$(get_random_port)
    echo "🔍 Selected port: $port"
    export GAIA_PORT="$port"
    
    # Download and run installation script
    echo "📥 Downloading installation script..."
    curl -sLO https://raw.githubusercontent.com/abhiag/Gaiatest/main/1.sh
    chmod +x 1.sh
    ./1.sh
    
    # Verify installation
    if [ -f ~/gaianet/bin/gaianet ]; then
        if pgrep -f "wasmedge.*:$port" >/dev/null; then
            echo -e "\e[1;32m✅ Node running on port $port\e[0m"
            if is_codespace; then
                echo "🌐 Access URL: https://$CODESPACE_NAME-$port.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
            fi
        else
            echo -e "\e[1;31m❌ Node failed to start properly\e[0m"
        fi
    fi
    ;;
       
4)
    echo "Detecting system configuration..."
    
    if ! command -v ~/gaianet/bin/gaianet &> /dev/null; then
        echo -e "\e[1;31m❌ GaiaNet not installed\e[0m"
        read -rp "Press Enter to continue..."
        continue
    fi
    
    # Get active port from config
    port=$(grep -r "port:" "$HOME/gaianet/config.yaml" 2>/dev/null | awk '{print $2}')
    if [ -z "$port" ]; then
        port=$(get_random_port)
        echo "🔍 Using new port: $port"
    fi
    
    # Start chatbot
    if pgrep -f "wasmedge.*:$port" >/dev/null; then
        echo -e "\e[1;32m✅ Node is running on port $port\e[0m"
        script_name="gaiachat.sh"
        screen -dmS gaiabot bash -c "curl -sLO https://raw.githubusercontent.com/abhiag/Gaiatest/main/$script_name && chmod +x $script_name && ./$script_name"
        sleep 2
        screen -r gaiabot
    else
        echo -e "\e[1;31m❌ Node not running. Please restart node first\e[0m"
    fi
    ;;
        5)
            select_screen_session
            ;;

        6)
            echo "🔴 Terminating and wiping all 'gaiabot' screen sessions..."
            # Terminate all 'gaiabot' screen sessions
            screen -ls | awk '/[0-9]+\.gaiabot/ {print $1}' | xargs -r -I{} screen -X -S {} quit
            # Remove any remaining screen sockets for 'gaiabot'
            find /var/run/screen -type s -name "*gaiabot*" -exec sudo rm -rf {} + 2>/dev/null
            echo -e "\e[32m✅ All 'gaiabot' screen sessions have been killed and wiped.\e[0m"
            ;;

 7)
    echo "Restarting GaiaNet Node..."
    port=$(grep -r "port:" "$HOME/gaianet/config.yaml" 2>/dev/null | awk '{print $2}')
    ~/gaianet/bin/gaianet stop
    sleep 2
    ~/gaianet/bin/gaianet init
    ~/gaianet/bin/gaianet start
    sleep 3
    if pgrep -f "wasmedge.*:$port" >/dev/null; then
        echo -e "\e[1;32m✅ Node restarted successfully on port $port\e[0m"
    else
        echo -e "\e[1;31m❌ Node failed to restart\e[0m"
    fi
    ;;
        8)
            echo "Stopping GaiaNet Node..."
            sudo netstat -tulnp | grep :8080
            ~/gaianet/bin/gaianet stop
            ;;

        9)
            echo "Checking Your Gaia Node ID & Device ID..."
            gaianet_info=$(~/gaianet/bin/gaianet info 2>/dev/null)
            if [[ -n "$gaianet_info" ]]; then
                echo "$gaianet_info"
            else
                echo "❌ GaiaNet is not installed or configured properly."
            fi
            ;;

        10)
            echo "⚠️ WARNING: This will completely remove GaiaNet Node from your system!"
            read -rp "Are you sure you want to proceed? (y/n) " confirm
            if [[ "$confirm" == "y" ]]; then
                echo "🗑️ Uninstalling GaiaNet Node..."
                curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/uninstall.sh' | bash
                source ~/.bashrc
            else
                echo "Uninstallation aborted."
            fi
            ;;

        0)
            echo "Exiting..."
            exit 0
            ;;

        *)
            echo "Invalid choice. Please try again."
            ;;
    esac

    read -rp "Press Enter to return to the main menu..."
done
