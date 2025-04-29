#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 设置证书目录
GEN_DIR="imar/gen"

# 查看证书内容的函数
view_cert() {
    local cert_file=$1
    local cert_type=$2
    
    echo -e "${YELLOW}查看${cert_type}内容:${NC}"
    echo "1. 文本格式"
    openssl x509 -in $cert_file -text -noout
    echo -e "\n2. 主题和颁发者信息"
    openssl x509 -in $cert_file -subject -issuer -noout
    echo -e "\n3. 有效期"
    openssl x509 -in $cert_file -dates -noout
}

# 主菜单
show_menu() {
    echo -e "${GREEN}证书查看工具${NC}"
    echo "1. 查看CA证书内容"
    echo "2. 查看服务器证书内容"
    echo "3. 查看证书链内容"
    echo "4. 退出"
    echo -n "请选择操作 (1-4): "
}

# 主循环
while true; do
    show_menu
    read choice
    case $choice in
        1)
            if [ -f "$GEN_DIR/imarCA.pem" ]; then
                view_cert "$GEN_DIR/imarCA.pem" "CA证书"
            else
                echo -e "${YELLOW}CA证书不存在${NC}"
            fi
            ;;
        2)
            if [ -f "$GEN_DIR/server.crt" ]; then
                view_cert "$GEN_DIR/server.crt" "服务器证书"
            else
                echo -e "${YELLOW}服务器证书不存在${NC}"
            fi
            ;;
        3)
            if [ -f "$GEN_DIR/ServerChain.crt" ]; then
                view_cert "$GEN_DIR/ServerChain.crt" "证书链"
            else
                echo -e "${YELLOW}证书链不存在${NC}"
            fi
            ;;
        4)
            echo "退出程序"
            exit 0
            ;;
        *)
            echo "无效的选择，请重新输入"
            ;;
    esac
    echo
done 