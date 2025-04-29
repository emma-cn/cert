#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 创建gen目录（如果不存在）
GEN_DIR="imar/gen"
mkdir -p $GEN_DIR

echo -e "${GREEN}开始生成证书链...${NC}"

# 1. 生成CA证书
echo -e "${GREEN}步骤1: 生成CA证书${NC}"
openssl genrsa -out $GEN_DIR/imarCA.key 2048
openssl req -x509 -new -nodes -key $GEN_DIR/imarCA.key -sha256 -days 3650 -out $GEN_DIR/imarCA.pem -subj "/C=CN/ST=SC/L=CD/O=MG/OU=AVATAR/CN=imarRootCA"

# 2. 生成服务器证书
echo -e "${GREEN}步骤2: 生成服务器证书${NC}"
openssl req -new -nodes -out $GEN_DIR/server.csr -keyout $GEN_DIR/server.key -config openssl.cnf
openssl x509 -req -in $GEN_DIR/server.csr -CA $GEN_DIR/imarCA.pem -CAkey $GEN_DIR/imarCA.key -CAcreateserial -out $GEN_DIR/server.crt -days 825 -sha256 -extfile openssl.cnf -extensions req_ext

# 3. 合并证书链
echo -e "${GREEN}步骤3: 合并证书链${NC}"
cat $GEN_DIR/server.crt $GEN_DIR/imarCA.pem > $GEN_DIR/ServerChain.crt

# 4. 设置文件权限
chmod 600 $GEN_DIR/*.key
chmod 644 $GEN_DIR/*.pem $GEN_DIR/*.crt $GEN_DIR/*.csr

echo -e "${GREEN}证书链生成完成！${NC}"
echo -e "${GREEN}生成的文件位于 $GEN_DIR 目录：${NC}"
echo "1. CA私钥: imarCA.key"
echo "2. CA证书: imarCA.pem"
echo "3. 服务器私钥: server.key"
echo "4. 服务器证书: server.crt"
echo "5. 证书链: ServerChain.crt" 