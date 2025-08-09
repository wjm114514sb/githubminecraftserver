#!/bin/bash

CONFIG_FILE="./config.mc"
EULA_FILE="./eula.txt"

# Function to check Java installation
check_java() {
    echo "检查 Java 是否安装..."
    if ! java -version &>/dev/null; then
        echo "Java 未安装，正在安装..."
        # Add your Java installation command here
    else
        echo "Java 已安装："
        java -version
    fi
}

# Function to install Minecraft server
install_server() {
    echo "请输入 Minecraft 分配的内存大小 (例如：2G): "
    read memory_size
    echo "设置 Minecraft 服务器内存为 $memory_size"

    echo "下载 Minecraft 服务器..."
    wget -O server.jar https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar

    # Create eula.txt and set eula=true
    echo "eula=true" > $EULA_FILE
}

# Function to start the Minecraft server
start_server() {
    echo "启动 Minecraft 服务器..."
    java -Xmx$memory_size -Xms$memory_size -jar server.jar nogui
}

# Function to stop the Minecraft server
stop_server() {
    echo "停止 Minecraft 服务器..."
    # Command to stop the Minecraft server, e.g. by killing the Java process
    pkill -f "java -jar server.jar"
}

# Function to setup and start internal penetration
start_frp() {
    echo "请输入访问密钥: "
    read access_key
    echo "请输入隧道ID: "
    read tunnel_id

    # Save the input to config.mc
    echo "access_key=$access_key" > $CONFIG_FILE
    echo "tunnel_id=$tunnel_id" >> $CONFIG_FILE

    # Run Docker to start FRP (internal penetration)
    echo "启动内网穿透..."
    docker run -d --name of --restart unless-stopped --network host openfrp/frpc:latest -u $access_key -p $tunnel_id
}

# Function to stop internal penetration
stop_frp() {
    echo "停止内网穿透..."
    docker stop of
    docker rm of
}

# Function to view FRP logs
view_frp_logs() {
    echo "查看内网穿透日志..."
    docker logs of
}

# Main menu
while true; do
    echo "请选择操作:"
    echo "1. 安装 Minecraft 服务器"
    echo "2. 设置 Minecraft 服务器内存"
    echo "3. 启动 Minecraft 服务器"
    echo "4. 停止 Minecraft 服务器"
    echo "5. 启动内网穿透"
    echo "6. 停止内网穿透"
    echo "7. 查看内网穿透日志"
    echo "8. 退出"
    read -p "请输入选项 (1-8): " option

    case $option in
        1) install_server ;;
        2) 
            echo "请输入 Minecraft 分配的内存大小 (例如：2G): "
            read memory_size
            echo "设置 Minecraft 服务器内存为 $memory_size"
            ;;
        3) start_server ;;
        4) stop_server ;;
        5) start_frp ;;
        6) stop_frp ;;
        7) view_frp_logs ;;
        8) exit ;;
        *) echo "无效选项" ;;
    esac
done
