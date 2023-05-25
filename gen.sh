#!/bin/sh

domain="$1"
sslRoot="$2"

if [ -z "$domain" ]; then
    echo "domain is required."
    exit 1
fi

if [ -z "$sslRoot" ]; then
    sslRoot=$(pwd)"/certificates"
fi

countryName="CN"
stateOrProvinceName="BeiJing"
localityName="BeiJing"
organizationName="Easy Dev Environment"
email="runchangneo@gmail.com"
caOrganizationalUnitName="Easy Dev Environment Trust Services"
caCommonName="Easy Dev Environment CA"
caDays=3650
caKeyPath=$sslRoot"/CA.key"
caCrtPath=$sslRoot"/CA.crt"
subject="/C=$countryName/ST=$stateOrProvinceName/L=$localityName/O=$organizationName/emailAddress=$email"

# Generate CA certificate
if [ ! -f "$caCrtPath" ]; then
    caSubject=$subject"/OU=$caOrganizationalUnitName/CN=$caCommonName"

    openssl req -x509 -nodes -newkey rsa:2048 \
        -days $caDays \
        -subj "$caSubject" \
        -keyout "$caKeyPath" -out "$caCrtPath"
fi

appSslDirName=$(echo "$domain" | sed "s/^\*\.//")
appSslDir=$sslRoot"/"$appSslDirName

if [ ! -d "$appSslDir" ]; then
    mkdir "$appSslDir"
fi

appSslKeyPath=$appSslDir"/ssl.key"
appSslCsrPath=$appSslDir"/ssl.csr"
appSslExtPath=$appSslDir"/ssl.ext"
appSslCrtPath=$appSslDir"/ssl.crt"

# Generate rsa key
openssl genrsa -out "$appSslKeyPath" 2048

# Generate csr
appOrganizationalUnitName="Easy Dev Environment Applications"
appCommonName=$domain
appSubject=$subject"/OU=$appOrganizationalUnitName/CN=$appCommonName"

openssl req -new -key "$appSslKeyPath" -subj "$appSubject" -out "$appSslCsrPath"

# Generate ext file SAN(subjectAltName)
cat >"$appSslExtPath" <<EOF
[ req ]
default_bits = 2048
req_extensions = req_ext
[ req_distinguished_name ]
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = $domain
EOF

# Generate crt
openssl x509 -req -days $caDays \
    -CA "$caCrtPath" -CAkey "$caKeyPath" -CAcreateserial \
    -in "$appSslCsrPath" -out "$appSslCrtPath" \
    -extfile "$appSslExtPath" -extensions req_ext

# Clean tmp file
rm -rf "$appSslCsrPath" "$appSslExtPath"
