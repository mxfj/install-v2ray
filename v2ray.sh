#!/bin/sh

echo -n  "please input uuid: "
read uuid

mkdir -p /usr/local/v2ray/
mkdir -p /var/log/v2ray/
cd /usr/local/v2ray/

wget https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip
unzip v2ray-linux-64.zip
rm -rf v2ray-linux-64.zip config.json


sed -i "s/nobody/root/g" systemd/system/v2ray.service
sed -i 's/\/usr\/local\/bin\//\/usr\/local\/v2ray\//g' systemd/system/v2ray.service
sed -i 's/\/usr\/local\/etc\/v2ray\//\/usr\/local\/v2ray\//g' systemd/system/v2ray.service

cp systemd/system/v2ray.service /etc/systemd/system/


cat << EOF > config.json 
{
        "log": {
                "access": "/var/log/v2ray/access.log",
                "error": "/var/log/v2ray/error.log",
                "loglevel": "warning"
        },
        "inbounds": [
                {
                        "port": 443,
                        "protocol": "vmess",
                        "settings": {
                                "clients": [
                                        {
                                                "id": "$uuid",
                                                "level": 1,
                                                "alterId": 0
                                        }
                                ]
                        },
                        "streamSettings": {
                                "network": "tcp"
                        },
                        "sniffing": {
                                "enabled": true,
                                "destOverride": [
                                        "http",
                                        "tls"
                                ]
                        }
                }
                //include_ss
                //include_socks
                //include_mtproto
                //include_in_config
                //
        ],
        "outbounds": [
                {
                        "protocol": "freedom",
                        "settings": {
                                "domainStrategy": "UseIP"
                        },
                        "tag": "direct"
                },
                {
                        "protocol": "blackhole",
                        "settings": {},
                        "tag": "blocked"
        }
                //include_out_config
                //
        ],
        "dns": {
                "servers": [
                        "https+local://dns.google/dns-query",
                        "8.8.8.8",
                        "1.1.1.1",
                        "localhost"
                ]
        },
        "routing": {
                "domainStrategy": "IPOnDemand",
                "rules": [
            {
                "type": "field",
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "blocked"
            }
                        ,
                        {
                                "type": "field",
                                "domain": [
                                        "domain:epochtimes.com",
                                        "domain:epochtimes.com.tw",
                                        "domain:epochtimes.fr",
                                        "domain:epochtimes.de",
                                        "domain:epochtimes.jp",
                                        "domain:epochtimes.ru",
                                        "domain:epochtimes.co.il",
                                        "domain:epochtimes.co.kr",
                                        "domain:epochtimes-romania.com",
                                        "domain:erabaru.net",
                                        "domain:lagranepoca.com",
                                        "domain:theepochtimes.com",
                                        "domain:ntdtv.com",
                                        "domain:ntd.tv",
                                        "domain:ntdtv-dc.com",
                                        "domain:ntdtv.com.tw",
                                        "domain:minghui.org",
                                        "domain:renminbao.com",
                                        "domain:dafahao.com",
                                        "domain:dongtaiwang.com",
                                        "domain:falundafa.org",
                                        "domain:wujieliulan.com",
                                        "domain:ninecommentaries.com",
                                        "domain:shenyun.com"
                                ],
                                "outboundTag": "blocked"
                        }                       ,
                {
                    "type": "field",
                    "protocol": [
                        "bittorrent"
                    ],
                    "outboundTag": "blocked"
                }
                        //include_ban_ad
                        //include_rules
                        //
                ]
        },
        "transport": {
                "kcpSettings": {
            "uplinkCapacity": 100,
            "downlinkCapacity": 100,
            "congestion": true
        }
        }
}
EOF


systemctl start v2ray
systemctl enable v2ray
