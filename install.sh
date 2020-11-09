#!/bin/bash
stty erase ^h
echo -e "\033[32mChecking Environment... \033[0m"
CURLSTATUS=$(curl -V | grep "command not found")
DCSTATUS=$(docker-compose -v | grep "command not found")
if [[ -n "$CURLSTATUS" ]]
then
    echo -e "\033[31mcURL Not Found. \033[0m"
    echo -e "\033[32mInstalling cURL... \033[0m"
    apt update && apt install curl -y
fi 
if [[ -n "$DCSTATUS" ]]
then
    echo -e "\033[31mDocker-Compose Not Found. \033[0m"
    echo -e "\033[32mInstalling Docker-Compose... \033[0m"
    curl -fsSL https://get.docker.com | bash
    curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod a+x /usr/local/bin/docker-compose
fi

wget -N --no-check-certificate "https://github.000060000.xyz/tcpx.sh" && chmod +x tcpx.sh 

clear

read -p "Please Input Your Domain: " FQDN
read -p "Please Input Your Mailbox: " MAILBOX
# Setting Up v2ray Parameters
# Setting Up SSL
FULLCHAIN="\"certificateFile\": \"\/etc\/letsencrypt\/live\/$FQDN\/fullchain.pem\","
PRIVKEY="\"keyFile\": \"\/etc\/letsencrypt\/live\/$FQDN\/privkey.pem\""
sed -i "s/\"certificateFile\":.*/$FULLCHAIN/" ./v2ray/config.json
sed -i "s/\"keyFile\":.*/$PRIVKEY/" ./v2ray/config.json

# Setting Up UUID
UUIDN=$(curl https://www.uuidgenerator.net/api/version4)
CID="\"id\": \"$UUIDN\","
sed -i "s/\"id\":.*/$CID/" ./v2ray/config.json

# Setting Up Path
#VLWSPATH="\"path\": \"\/vlws$UUIDN\""
#sed -i "s/\"path\": \"\/vlws.*/$VLWSPATH/" ./v2ray/config.json
#VMTCPPATH="\"path\": \"\/vltcp$UUIDN\""
#sed -i "s/\"path\": \"\/vmtcp.*/$VMTCPPATH/" ./v2ray/config.json
#VMWSPATH="\"path\": \"\/vmws$UUIDN\""
#sed -i "s/\"path\": \"\/vmws.*/$VMWSPATH/" ./v2ray/config.json

# Setting Up Certbot Parameters
EMAIL="CERTBOT_EMAIL: $MAILBOX"
DOMAIN="FQDN: $FQDN"
sed -i "s/CERTBOT_EMAIL:.*/$EMAIL/" ./docker-compose.yml
sed -i "s/FQDN:.*/$DOMAIN/" ./docker-compose.yml

docker-compose up -d

echo -e "\033[32mYour Random UUID Is: $UUIDN\033[0m"