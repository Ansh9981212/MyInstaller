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

# Add after dependency checks
# Update the check_and_fix_port function
check_and_fix_port() {
    local config_file="$HOME/gaianet/config.yaml"
    local port=$(grep -r "port:" "$config_file" 2>/dev/null | awk '{print $2}')
    
    echo "🔍 Checking port configuration..."
    
    # Generate random port between 8080-8100 if no port found
    if [ -z "$port" ]; then
        port=$((RANDOM % 21 + 8080))
    fi
    
    # Check if port is in use, if so try random ports until finding an available one
    while sudo lsof -i :"$port" | grep -v "gaianet" > /dev/null 2>&1; do
        echo "⚠️ Port $port is in use by another process"
        port=$((RANDOM % 21 + 8080))
        echo "🔄 Trying port $port..."
    done
    
    # Update configuration files with the port
    config_files=(
        "$config_file"
        "$HOME/gaianet/dashboard/config_pub.json"
        "$HOME/gaianet/config.json"
    )
    
    for conf in "${config_files[@]}"; do
        if [ -f "$conf" ]; then
            if [[ $conf == *.yaml ]]; then
                sudo sed -i "s/port: [0-9]*/port: $port/" "$conf"
            else
                sudo sed -i "s/\"llamaedge_port\": \"[0-9]*\"/\"llamaedge_port\": \"$port\"/" "$conf"
            fi
        fi
    done
    
    # Restart the node to apply changes
    ~/gaianet/bin/gaianet stop
    sleep 2
    ~/gaianet/bin/gaianet init
    ~/gaianet/bin/gaianet start
    
    # Verify port is now active
    sleep 3
    if sudo lsof -i :"$port" | grep "gaianet" > /dev/null 2>&1; then
        echo -e "\e[1;32m✅ Port $port is now active and in use by GaiaNet\e[0m"
        return 0
    else
        echo -e "\e[1;31m❌ Failed to activate port $port\e[0m"
        return 1
    fi
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


  
  echo -e "10) \e[1;31m🗑️  Uninstall GaiaNet Node (Risky Operation)\e[0m"
  echo "==============================================================="



echo -e "11) \e[1;43m\e[97m🔧  Manually Change GaiaNet Port\e[0m"
echo -e "    \e[1;33m🔢 Manually set a custom port for your GaiaNet node.\e[0m"
echo -e "    \e[1;33m🔄 Useful when you need a specific port configuration.\e[0m"
echo -e "    \e[1;33m⚙️  Available range: 8080-8099\e[0m"
echo "==============================================================="


echo -e "12) \e[1;46m\e[97m🔄  Change Node ID & Device ID\e[0m"
echo -e "    \e[1;36m🔑 Update your GaiaNet node's identifiers\e[0m"
echo -e "    \e[1;36m📝 Useful when migrating or resetting your node\e[0m"
echo -e "    \e[1;36m⚠️  This will require a node restart\e[0m"
echo "==============================================================="



echo -e "13) \e[1;42m\e[97m📊  Performance Monitor\e[0m"
echo -e "    \e[1;32m📈 Monitor your node's performance metrics\e[0m"
echo -e "    \e[1;32m🔍 Track CPU, RAM, and network usage\e[0m"
echo -e "    \e[1;32m📱 Real-time status monitoring\e[0m"
echo "==============================================================="


echo -e "14) \e[1;44m\e[97m📋  View Node Logs\e[0m"
echo -e "    \e[1;34m📝 View and analyze node logs\e[0m"
echo -e "    \e[1;34m🔍 Track events and errors\e[0m"
echo -e "    \e[1;34m📊 Debug node issues\e[0m"
echo "==============================================================="


# Add this to your menu options section
echo -e "15) \e[1;45m\e[97m⚙️  Node Configuration Manager\e[0m"
echo -e "    \e[1;35m🔧 Manage node settings and configuration\e[0m"
echo -e "    \e[1;35m📝 Edit common configuration parameters\e[0m"
echo -e "    \e[1;35m💾 Save and apply changes\e[0m"
echo "==============================================================="




    echo -e "\e[1;91m⚠️  DANGER ZONE:\e[0m"
    echo -e "0) \e[1;31m❌  Exit Installer\e[0m"
    echo "==============================================================="
    
    read -rp "Enter your choice: " choice

    case $choice in


# Modify the installation section (cases 1,2,3) to handle the port before running the WasmEdge command:

1|2|3)
    echo "Installing Gaia-Node..."
    
    # Stop any running processes
    if pgrep -f "gaianet" > /dev/null; then
        echo "🛑 Stopping existing GaiaNet processes..."
        ~/gaianet/bin/gaianet stop 2>/dev/null
        sleep 2
        sudo pkill -f gaianet
    fi
    
    # Clean up existing files
    echo "🧹 Cleaning up old installation files..."
    rm -rf 1.sh
    
    # Create necessary directories
    echo "📁 Creating required directories..."
    mkdir -p ~/gaianet/bin
    
    # Generate random port first
    port=$((RANDOM % 21 + 8080))
    while sudo lsof -i :"$port" > /dev/null 2>&1; do
        port=$((RANDOM % 21 + 8080))
    done
    echo "🔍 Selected port: $port"
    
    # Download and modify installation script
    echo "📥 Downloading installation script..."
    curl -O https://raw.githubusercontent.com/abhiag/Gaiatest/main/1.sh
    chmod +x 1.sh
    
    # Modify the WasmEdge command in the installation script to use our random port
    sed -i "s/:8080/:$port/g" 1.sh
    
    # Run installation script
    echo "🚀 Running installation script..."
    ./1.sh
    
    # Check installation status
    if [ -f ~/gaianet/bin/gaianet ]; then
        echo -e "\e[1;32m✅ GaiaNet installation completed successfully!\e[0m"
        
        # Create or update config file with the selected port
        config_file="$HOME/gaianet/config.yaml"
        if [ ! -f "$config_file" ]; then
            mkdir -p "$HOME/gaianet"
            cat > "$config_file" << EOF
node_id: default
device_id: default
port: $port
log_level: info
EOF
        else
            sed -i "s/port: [0-9]*/port: $port/" "$config_file"
        fi
        
        # Update other configuration files
        dashboard_config="$HOME/gaianet/dashboard/config_pub.json"
        if [ -f "$dashboard_config" ]; then
            sed -i "s/\"llamaedge_port\": \"[0-9]*\"/\"llamaedge_port\": \"$port\"/" "$dashboard_config"
        fi
        
        echo -e "\e[1;32m✅ Configuration completed with port $port\e[0m"
    else
        echo -e "\e[1;31m❌ Installation failed. Please try again.\e[0m"
    fi
    ;;
       
    # Replace entire case 4 section
4)
    echo "Detecting system configuration..."
    
    # Quick installation check
    if [ ! -f ~/gaianet/bin/gaianet ]; then
        echo -e "\e[1;31m❌ GaiaNet is not installed. Please install it first.\e[0m"
        read -rp "Press Enter to return to main menu..."
        continue
    fi

    # Get port configuration
    config_file="$HOME/gaianet/config.yaml"
    port=$(grep -r "port:" "$config_file" 2>/dev/null | awk '{print $2}')

    # Generate random port if needed
    if [ -z "$port" ]; then
        port=$((RANDOM % 20 + 8080))
        while sudo lsof -i :"$port" > /dev/null 2>&1; do
            port=$((RANDOM % 20 + 8080))
        done
        echo -e "\e[1;32m✅ Using port: $port\e[0m"
    fi

    # Quick node restart
    echo "🔄 Ensuring node is running..."
    ~/gaianet/bin/gaianet stop >/dev/null 2>&1
    sleep 1
    ~/gaianet/bin/gaianet start >/dev/null 2>&1
    sleep 2

    # Simple status check
    if pgrep -f "wasmedge" >/dev/null && sudo lsof -i :"$port" 2>/dev/null | grep -q "wasmedge"; then
        echo -e "\e[1;32m✅ GaiaNet is running on port $port\e[0m"
        
        # Start chatbot in optimized way
        echo "🤖 Starting AI chatbot..."
        
        # Clean up any existing sessions
        screen -ls | grep "gaiabot" | cut -d. -f1 | xargs -r kill >/dev/null 2>&1
        
        # Download script with timeout and retry
        for i in {1..3}; do
            if curl -m 10 -sLO https://raw.githubusercontent.com/abhiag/Gaiatest/main/gaiachat.sh; then
                chmod +x gaiachat.sh
                break
            fi
            echo "Retry $i downloading script..."
            sleep 1
        done

        if [ ! -f "gaiachat.sh" ]; then
            echo -e "\e[1;31m❌ Failed to download chatbot script\e[0m"
            read -rp "Press Enter to return to main menu..."
            continue
        fi

        # Start screen session
        screen -dmS gaiabot bash -c './gaiachat.sh || bash'
        sleep 1
        
        if screen -list | grep -q "gaiabot"; then
            screen -r gaiabot
        else
            echo -e "\e[1;31m❌ Failed to start chatbot\e[0m"
            read -rp "Press Enter to return to main menu..."
        fi
    else
        echo -e "\e[1;31m❌ GaiaNet failed to start\e[0m"
        read -rp "Press Enter to return to main menu..."
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
# Modify case 7 to use the new function
              7)
            echo "🔄 Restarting GaiaNet Node..."
            ~/gaianet/bin/gaianet stop
            sleep 2
            
            # Use the new function to handle port configuration
            if ! check_and_fix_port; then
                echo "❌ Failed to configure port properly. Please check logs."
                continue
            fi
            
            # Verify node is running
            if ~/gaianet/bin/gaianet info; then
                echo -e "\e[1;32m✅ GaiaNet node successfully restarted!\e[0m"
            else
                echo -e "\e[1;31m❌ Error: Node failed to start properly. Please check logs.\e[0m"
            fi
            ;;
8)
    echo "Stopping GaiaNet Node..."
    port=$(grep -r "port:" "$HOME/gaianet/config.yaml" 2>/dev/null | awk '{print $2}')
    if [ -z "$port" ]; then
        port="8080"
    fi
    sudo netstat -tulnp | grep :"$port"
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

        11)
            echo "🔧 Manual Port Configuration"
            echo "==============================================================="
            
            # Get current port
            current_port=$(grep -r "port:" ~/gaianet/config.yaml 2>/dev/null | awk '{print $2}' || echo "8080")
            echo "Current port: $current_port"
            
            # Ask for new port
            while true; do
                read -rp "Enter new port number (8080-8099) or press Enter to cancel: " new_port
                
                # Check if user wants to cancel
                if [ -z "$new_port" ]; then
                    echo "Port change cancelled."
                    break
                fi
                
                # Validate port number
                if [[ ! "$new_port" =~ ^808[0-9]$|^8099$ ]]; then
                    echo "❌ Invalid port number. Please use a number between 8080-8099."
                    continue
                fi
                
                # Check if port is available
                if sudo lsof -i :"$new_port" > /dev/null 2>&1; then
                    echo "❌ Port $new_port is already in use. Please choose another port."
                    continue
                fi
                
                echo "🔄 Changing port to $new_port..."
                
                # Stop existing node
                ~/gaianet/bin/gaianet stop
                
                # Update configuration files
                config_files=(
                    "$(find ~ -name "config.yaml" 2>/dev/null)"
                    "/home/codespace/gaianet/dashboard/config_pub.json"
                    "/home/codespace/gaianet/config.json"
                )
                
                for config in "${config_files[@]}"; do
                    if [ -f "$config" ]; then
                        echo "📝 Updating port in $config..."
                        if [[ $config == *.yaml ]]; then
                            sudo sed -i "s/port: [0-9]*/port: $new_port/" "$config"
                        else
                            sudo sed -i "s/\"llamaedge_port\": \"[0-9]*\"/\"llamaedge_port\": \"$new_port\"/" "$config"
                        fi
                    fi
                done
                
                # Restart node
                echo "🔄 Restarting GaiaNet with new port..."
                ~/gaianet/bin/gaianet init
                ~/gaianet/bin/gaianet start
                
                # Verify port change
                sleep 3
                if sudo lsof -i :"$new_port" > /dev/null 2>&1; then
                    echo -e "\e[1;32m✅ Successfully changed port to $new_port!\e[0m"
                else
                    echo -e "\e[1;31m❌ Failed to start on new port. Reverting to port $current_port\e[0m"
                    # Revert changes
                    for config in "${config_files[@]}"; do
                        if [ -f "$config" ]; then
                            if [[ $config == *.yaml ]]; then
                                sudo sed -i "s/port: [0-9]*/port: $current_port/" "$config"
                            else
                                sudo sed -i "s/\"llamaedge_port\": \"[0-9]*\"/\"llamaedge_port\": \"$current_port\"/" "$config"
                            fi
                        fi
                    done
                    ~/gaianet/bin/gaianet init
                    ~/gaianet/bin/gaianet start
                fi
                break
            done
            ;;

        12)
            echo "🔄 Node ID & Device ID Configuration"
            echo "==============================================================="
            
            # Stop the node first
            echo "🛑 Stopping GaiaNet node..."
            ~/gaianet/bin/gaianet stop
            
            # Backup current configuration
            config_file="$HOME/gaianet/config.yaml"
            backup_file="$HOME/gaianet/config.yaml.backup"
            
            if [ -f "$config_file" ]; then
                cp "$config_file" "$backup_file"
                echo "📑 Created backup of current configuration"
            fi
            
            # Get current IDs
            current_node_id=$(grep "node_id:" "$config_file" 2>/dev/null | awk '{print $2}')
            current_device_id=$(grep "device_id:" "$config_file" 2>/dev/null | awk '{print $2}')
            
            echo "Current Node ID: $current_node_id"
            echo "Current Device ID: $current_device_id"
            
            # Ask for new IDs
            read -rp "Enter new Node ID (or press Enter to keep current): " new_node_id
            read -rp "Enter new Device ID (or press Enter to keep current): " new_device_id
            
            if [ -n "$new_node_id" ] || [ -n "$new_device_id" ]; then
                echo "🔧 Updating configuration..."
                
                if [ -n "$new_node_id" ]; then
                    sudo sed -i "s/node_id: .*/node_id: $new_node_id/" "$config_file"
                    echo "✅ Updated Node ID"
                fi
                
                if [ -n "$new_device_id" ]; then
                    sudo sed -i "s/device_id: .*/device_id: $new_device_id/" "$config_file"
                    echo "✅ Updated Device ID"
                fi
                
                # Restart node with new configuration
                echo "🔄 Restarting GaiaNet with new configuration..."
                ~/gaianet/bin/gaianet init
                ~/gaianet/bin/gaianet start
                
                # Verify the changes
                sleep 3
                new_info=$(~/gaianet/bin/gaianet info)
                if [ $? -eq 0 ]; then
                    echo -e "\e[1;32m✅ Successfully updated node configuration!\e[0m"
                    echo "New configuration:"
                    echo "$new_info"
                else
                    echo -e "\e[1;31m❌ Error: Failed to restart node with new configuration\e[0m"
                    echo "🔄 Restoring backup configuration..."
                    cp "$backup_file" "$config_file"
                    ~/gaianet/bin/gaianet init
                    ~/gaianet/bin/gaianet start
                fi
            else
                echo "No changes made to configuration."
                ~/gaianet/bin/gaianet start
            fi
            ;;

# Update the port status check in case 13
13)
    echo "📊 GaiaNet Performance Monitor"
    echo "==============================================================="
    
    while true; do
        clear
        echo "📊 System Performance Metrics"
        echo "==============================================================="
        
        # CPU Usage
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
        echo -e "CPU Usage: \e[1;33m$cpu_usage%\e[0m"
        
        # Memory Usage
        mem_info=$(free -m)
        total_mem=$(echo "$mem_info" | awk '/Mem:/ {print $2}')
        used_mem=$(echo "$mem_info" | awk '/Mem:/ {print $3}')
        mem_usage=$((used_mem * 100 / total_mem))
        echo -e "Memory Usage: \e[1;33m$mem_usage%\e[0m ($used_mem MB / $total_mem MB)"
        
        # GaiaNet Process Status
        if pgrep -f "gaianet" > /dev/null; then
            echo -e "GaiaNet Status: \e[1;32m🟢 Running\e[0m"
            
            # Port Status - Enhanced check
            port=$(grep -r "port:" ~/gaianet/config.yaml 2>/dev/null | awk '{print $2}')
            if [ -z "$port" ]; then
                port="8080"  # Fallback to default if not found
            fi
            
            # More comprehensive port check
            if sudo lsof -i :"$port" | grep -q "gaianet\|wasmedge"; then
                echo -e "Port Status: \e[1;32m🟢 Active on $port\e[0m"
                # Additional port details
                echo "Port Details:"
                sudo lsof -i :"$port" | grep -E "gaianet|wasmedge" | awk '{printf "  Process: %s (PID: %s)\n", $1, $2}'
            else
                echo -e "Port Status: \e[1;31m🔴 Not active\e[0m"
                echo "🔄 Attempting to restart service..."
                ~/gaianet/bin/gaianet stop
                sleep 2
                ~/gaianet/bin/gaianet start
            fi
            
            # Process Resources - Enhanced display
            echo "Process Details:"
            ps aux | grep -E "[g]aianet|[w]asmedge" | \
                awk '{printf "PID: %s, Name: %s, CPU: %s%%, Memory: %s%%\n", $2, $11, $3, $4}'
        else
            echo -e "GaiaNet Status: \e[1;31m🔴 Not Running\e[0m"
            echo "⚠️ Service appears to be down. Use option 7 from main menu to restart."
        fi
        
        echo "==============================================================="
        echo "Press Ctrl+C to exit monitoring"
        sleep 2
    done
    ;;
# Replace case 14 section with this updated version:
14)
    echo "📋 GaiaNet Log Viewer"
    echo "==============================================================="
    
    # Check multiple possible log directories
    possible_log_dirs=(
        "$HOME/gaianet/logs"
        "$HOME/gaianet/log"
        "$HOME/.gaianet/logs"
        "$HOME/.gaianet/log"
        "/var/log/gaianet"
    )
    
    log_dir=""
    for dir in "${possible_log_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_dir="$dir"
            break
        fi
    done
    
    if [ -z "$log_dir" ]; then
        echo "⚠️ No standard log directory found."
        # Try to find any log files in gaianet directory
        log_files=$(find "$HOME/gaianet" -type f -name "*.log" 2>/dev/null)
        if [ -z "$log_files" ]; then
            echo "❌ No log files found anywhere in gaianet installation."
            read -rp "Press Enter to return to main menu..."
            continue
        else
            log_dir="$HOME/gaianet"
        fi
    fi
    
    while true; do
        echo "Select log type:"
        echo "1) Recent logs (last 50 lines)"
        echo "2) Error logs"
        echo "3) Full logs"
        echo "4) Return to main menu"
        
        read -rp "Choose an option: " log_choice
        
        case $log_choice in
            1)
                echo "📑 Recent Logs:"
                find "$log_dir" -type f -name "*.log" -exec tail -n 50 {} \; 2>/dev/null
                ;;
            2)
                echo "❌ Error Logs:"
                find "$log_dir" -type f -name "*.log" -exec grep -i "error\|failed\|critical" {} \; 2>/dev/null
                ;;
            3)
                echo "📚 Full Logs:"
                find "$log_dir" -type f -name "*.log" -exec cat {} \; 2>/dev/null
                ;;
            4)
                break
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
        read -rp "Press Enter to continue..."
    done
    ;;
        15)
            echo "⚙️ GaiaNet Node Configuration Manager"
            echo "==============================================================="
            
            config_file="$HOME/gaianet/config.yaml"
            config_dir="$HOME/gaianet"
            
            # Create config directory if it doesn't exist
            if [ ! -d "$config_dir" ]; then
                echo "📁 Creating configuration directory..."
                mkdir -p "$config_dir"
            fi
            
            # Create default config if it doesn't exist
            if [ ! -f "$config_file" ]; then
                echo "📝 Creating default configuration file..."
                cat > "$config_file" << EOF
node_id: default
device_id: default
port: 8080
log_level: info
EOF
            fi
            
            while true; do
                clear
                echo "Current Configuration:"
                echo "==============================================================="
                
                # Display current settings
                node_id=$(grep "node_id:" "$config_file" | awk '{print $2}')
                device_id=$(grep "device_id:" "$config_file" | awk '{print $2}')
                port=$(grep "port:" "$config_file" | awk '{print $2}')
                log_level=$(grep "log_level:" "$config_file" | awk '{print $2}')
                
                echo -e "1) Node ID: \e[1;36m$node_id\e[0m"
                echo -e "2) Device ID: \e[1;36m$device_id\e[0m"
                echo -e "3) Port: \e[1;36m$port\e[0m"
                echo -e "4) Log Level: \e[1;36m$log_level\e[0m"
                echo "5) Save and restart node"
                echo "6) Return to main menu"
                echo "==============================================================="
                
                read -rp "Choose setting to modify (1-6): " config_choice
                
                case $config_choice in
                    1)
                        read -rp "Enter new Node ID: " new_node_id
                        if [ -n "$new_node_id" ]; then
                            sudo sed -i "s/node_id: .*/node_id: $new_node_id/" "$config_file"
                            echo "✅ Node ID updated"
                        fi
                        ;;
                    2)
                        read -rp "Enter new Device ID: " new_device_id
                        if [ -n "$new_device_id" ]; then
                            sudo sed -i "s/device_id: .*/device_id: $new_device_id/" "$config_file"
                            echo "✅ Device ID updated"
                        fi
                        ;;
                    3)
                        while true; do
                            read -rp "Enter new port (8080-8099): " new_port
                            if [[ "$new_port" =~ ^808[0-9]$|^8099$ ]]; then
                                if ! sudo lsof -i :"$new_port" > /dev/null 2>&1; then
                                    sudo sed -i "s/port: .*/port: $new_port/" "$config_file"
                                    echo "✅ Port updated"
                                    break
                                else
                                    echo "❌ Port $new_port is already in use"
                                fi
                            else
                                echo "❌ Invalid port number"
                            fi
                        done
                        ;;
                    4)
                        echo "Available log levels: debug, info, warn, error"
                        read -rp "Enter new log level: " new_log_level
                        if [[ "$new_log_level" =~ ^(debug|info|warn|error)$ ]]; then
                            sudo sed -i "s/log_level: .*/log_level: $new_log_level/" "$config_file"
                            echo "✅ Log level updated"
                        else
                            echo "❌ Invalid log level"
                        fi
                        ;;
                    5)
                        echo "🔄 Applying configuration changes..."
                        ~/gaianet/bin/gaianet stop
                        sleep 2
                        ~/gaianet/bin/gaianet init
                        ~/gaianet/bin/gaianet start
                        
                        # Verify node status
                        sleep 3
                        if ~/gaianet/bin/gaianet info &> /dev/null; then
                            echo -e "\e[1;32m✅ Node successfully restarted with new configuration!\e[0m"
                        else
                            echo -e "\e[1;31m❌ Failed to restart node\e[0m"
                        fi
                        read -rp "Press Enter to continue..."
                        ;;
                    6)
                        break
                        ;;
                    *)
                        echo "Invalid option"
                        sleep 1
                        ;;
                esac
            done
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
