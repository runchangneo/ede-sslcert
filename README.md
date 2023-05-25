# Easy Development Environment - SSLCert
容易搭建的开发环境 - SSL 证书

## 证书生成
证书生成脚本 `gen.sh`  
赋予脚本可执行权限
```
chmod +x gen.sh
```

根据域名，生成证书, 以 `www.test.com` 为例

生成证书
```
./gen.sh www.test.com
```

生成的证书和密钥保存在 *certificates/www.test.com* 目录下
- ssl.crt 证书
- ssl.key 密钥

## 浏览器信任自签名证书
自签名证书是不被浏览器信任的  
要获取浏览器信任，需要将生成证书的 `根证书` 导入浏览器的证书管理系统  
`根证书` 位于 *certificates/CA.crt*

### Chrome
在搜索框中输入 "chrome://settings/security"  
找到 `管理设备证书` 项，点击  
点击 `导入` ，按照向导将 `CA.crt` 导入系统的 `受信任的根证书颁发机构` 中  
重启 chrome 生效

### Firefox
在搜索框中输入 "about:preferences#privacy"  
找到 `证书` 项，点击 `查看证书` 按钮  
选择 `证书颁发机构`  
点击 `导入` ，按照向导将 `CA.crt` 导入即可
