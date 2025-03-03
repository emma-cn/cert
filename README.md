# 证书链制作

## 1、制作CA证书

	1）生成CA私钥：openssl genrsa -out juliusCA.key 2048
	2）生成自签名的 CA 证书：openssl req -x509 -new -nodes -key juliusCA.key -sha256 -days 3650 -out juliusCA.pem -subj "/C=CN/ST=SC/L=CD/O=MG/OU=AVATAR/CN=JuliusRootCA"

## 2、使用 CA 证书签署服务器证书

	1）生成证书签名请求（CSR）和私钥： openssl req -new -nodes -out server.csr -keyout server.key -config openssl.cnf
	2） 使用 CA 签署服务器证书： openssl x509 -req -in server.csr -CA juliusCA.pem -CAkey juliusCA.key -CAcreateserial -out server.crt -days 825 -sha256 -extfile openssl.cnf -extensions req_ext

## 3、合并证书链：
    cat server.crt juliusCA.pem  > ServerChain.crt

## 4、服务端使用 
    ServerChain.crt和 server.key
    
## 5、客户端需要将根证书导入系统信任中


## 验证命令:

    检查证书信息：openssl x509 -in server.crt -text -noout
    查看请求文件：openssl req -in server.csr -text -noout

    检查证书链：openssl s_client -connect julius-macmini.local:8088 -showcerts
