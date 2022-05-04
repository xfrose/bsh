#!/usr/bin/env bash

# 0. set *.dat files' directory
XrayDatDir="/usr/local/share/xray/"
V2rayAgentDatDir="/etc/v2ray-agent/xray/"
V2flyDatDir="/usr/local/share/v2ray/"
V2rayOldDir="/usr/lib/v2ray/"
if [[ -e $XrayDatDir ]]; then
DatDir=$XrayDatDir
elif [[ -e $V2rayAgentDatDir ]]; then
DatDir=$V2rayAgentDatDir
elif [[ -e $V2flyDatDir ]]; then
DatDir=$V2flyDatDir
elif [[ -e "/usr/lib/v2ray/geosite.dat" ]]; then
DatDir=$V2rayOldDir
else
echo -e "${RedBG}>>> 未匹配到设置的默认dat文件路径，请手动输入：${NC}"
read DatDir
fi

YELLOW='\033[33m'
GREEN='\033[0;32m'
RedBG='\033[41;37m'
GreenBG='\033[42;37m'
NC='\033[0m'

GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

GEOIP="geoip.dat"
GEOSITE="geosite.dat"

# argument 1 must be <empty> or "cn"
if [[ $# -gt 1 ]]; then
    echo -e "${RedBG}>>> only accept 1 argument!${NC}"
    exit 1
fi

# validation check
if [[ $1 == "cn" ]]; then
    # set different URL for downloading assets
    GEOIP_URL="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat"
    GEOSITE_URL="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat"
elif [[ $# -eq 1 && $1 != "cn" ]]; then
    echo -e "${RedBG}>>> arguments 1 only accept \"cn\"!${NC}"
    exit 1
fi

# 1. Start downloading
echo -e "${GREEN}>>> Downloading geoip.dat to $DatDir...${NC}"
echo -e "${YELLOW}geoip URL: $GEOIP_URL${NC}"
curl -L $GEOIP_URL --output /tmp/$GEOIP

echo -e "${GREEN}>>> Downloading geosite.dat to $DatDir...${NC}"
echo -e "${YELLOW}geosite URL: $GEOSITE_URL${NC}"
curl -L $GEOSITE_URL --output /tmp/$GEOSITE

# 2. Clean old assets
echo -e "${GREEN}>>> Deleting old geoip/geosite files...${NC}"
rm -f $DatDir/$GEOIP $DatDir/$GEOSITE

# 3. Replace old assets
echo -e "${GREEN}>>> Replacing with new geoip/geosite files...${NC}"
mv /tmp/$GEOIP $DatDir/
mv /tmp/$GEOSITE $DatDir/

echo -e "${GREEN}Done${NC}"

# 4. Restart the right service
echo -e "${GREEN}>>> Restarting the service...${NC}"
if systemctl list-unit-files --type service | grep -Fq "xray"
then
systemctl restart xray
else
systemctl restart v2ray
fi
echo -e "${GREEN}All Done!!${NC}"
