#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查参数
if [ $# -ne 1 ]; then
    echo -e "${RED}用法: $0 <项目名称>${NC}"
    echo -e "${RED}支持的项目: imar, hound${NC}"
    exit 1
fi

PROJECT=$1
if [ "$PROJECT" != "imar" ] && [ "$PROJECT" != "hound" ]; then
    echo -e "${RED}错误: 不支持的项目 '$PROJECT'${NC}"
    echo -e "${RED}支持的项目: imar, hound${NC}"
    exit 1
fi

# 设置目录
GEN_DIR="$PROJECT/gen"
CONF_DIR="$PROJECT/conf"

# 创建目录（如果不存在）
mkdir -p $GEN_DIR
mkdir -p $CONF_DIR

# 检查配置文件是否存在
if [ ! -f "$CONF_DIR/openssl.cnf" ]; then
    echo -e "${RED}错误: 配置文件 $CONF_DIR/openssl.cnf 不存在${NC}"
    exit 1
fi

echo -e "${GREEN}开始为 $PROJECT 生成证书链...${NC}"

# 1. 生成CA证书
echo -e "${GREEN}步骤1: 生成CA证书${NC}"
openssl genrsa -out $GEN_DIR/${PROJECT}CA.key 2048
openssl req -x509 -new -nodes -key $GEN_DIR/${PROJECT}CA.key -sha256 -days 3650 -out $GEN_DIR/${PROJECT}CA.pem -subj "/C=CN/ST=SC/L=CD/O=MG/OU=AVATAR/CN=${PROJECT}RootCA"

# 2. 生成服务器证书
echo -e "${GREEN}步骤2: 生成服务器证书${NC}"
openssl req -new -nodes -out $GEN_DIR/server.csr -keyout $GEN_DIR/server.key -config $CONF_DIR/openssl.cnf
openssl x509 -req -in $GEN_DIR/server.csr -CA $GEN_DIR/${PROJECT}CA.pem -CAkey $GEN_DIR/${PROJECT}CA.key -CAcreateserial -out $GEN_DIR/server.crt -days 825 -sha256 -extfile $CONF_DIR/openssl.cnf -extensions req_ext

# 3. 合并证书链
echo -e "${GREEN}步骤3: 合并证书链${NC}"
cat $GEN_DIR/server.crt $GEN_DIR/${PROJECT}CA.pem > $GEN_DIR/ServerChain.crt

# 4. 设置文件权限
chmod 600 $GEN_DIR/*.key
chmod 644 $GEN_DIR/*.pem $GEN_DIR/*.crt $GEN_DIR/*.csr

echo -e "${GREEN}证书链生成完成！${NC}"
echo -e "${GREEN}生成的文件位于 $GEN_DIR 目录：${NC}"
echo "1. CA私钥: ${PROJECT}CA.key"
echo "2. CA证书: ${PROJECT}CA.pem"
echo "3. 服务器私钥: server.key"
echo "4. 服务器证书: server.crt"
echo "5. 证书链: ServerChain.crt" 