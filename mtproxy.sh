#!/bin/bash
###
 # @Author: Vincent Young
 # @Date: 2022-07-01 15:29:23
 # @LastEditors: Vincent Young
 # @LastEditTime: 2022-07-30 19:26:45
 # @FilePath: /MTProxy/mtproxy.sh
 # @Telegram: https://t.me/missuo
 # 
 # Copyright © 2022 by Vincent, All Rights Reserved. 
### 

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Define Color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Make sure run with root
[[ $EUID -ne 0 ]] && echo -e "[${red}Error${plain}]Please run this script with ROOT!" && exit 1

download_file(){
	echo "Checking System..."

	bit=`uname -m`
	if [[ ${bit} = "x86_64" ]]; then
		bit="amd64"
    elif [[ ${bit} = "aarch64" ]]; then
        bit="arm64"
    else
	    bit="386"
    fi

    last_version=$(curl -Ls "https://api.github.com/repos/9seconds/mtg/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [[ ! -n "$last_version" ]]; then
        echo -e "${red}Failure to detect mtg version may be due to exceeding Github API limitations, please try again later."
        exit 1
    fi
    echo -e "Latest version of mtg detected: ${last_version}, start installing..."
    version=$(echo ${last_version} | sed 's/v//g')
    wget -N --no-check-certificate -O mtg-${version}-linux-${bit}.tar.gz https://github.com/9seconds/mtg/releases/download/${last_version}/mtg-${version}-linux-${bit}.tar.gz
    if [[ ! -f "mtg-${version}-linux-${bit}.tar.gz" ]]; then
        echo -e "${red}Download mtg-${version}-linux-${bit}.tar.gz failed, please try again."
        exit 1
    fi
    tar -xzf mtg-${version}-linux-${bit}.tar.gz
    mv mtg-${version}-linux-${bit}/mtg /usr/bin/mtg
    rm -f mtg-${version}-linux-${bit}.tar.gz
    rm -rf mtg-${version}-linux-${bit}
    chmod +x /usr/bin/mtg
    echo -e "mtg-${version}-linux-${bit}.tar.gz installed successfully, start to configure..."
}

configure_mtg(){
    echo -e "Configuring mtg..."
    wget -N --no-check-certificate -O /etc/mtg.toml https://raw.githubusercontent.com/missuo/MTProxy/main/mtg.toml
    
    echo ""
    read -p "Please enter a spoofed domain (default itunes.apple.com): " domain
	[ -z "${domain}" ] && domain="itunes.apple.com"

	echo ""
    read -p "Enter the port to be listened to (default 8443):" port
	[ -z "${port}" ] && port="8443"

    secret=$(mtg generate-secret --hex $domain)
    
    echo "Waiting configuration..."

    sed -i "s/secret.*/secret = \"${secret}\"/g" /etc/mtg.toml
    sed -i "s/bind-to.*/bind-to = \"0.0.0.0:${port}\"/g" /etc/mtg.toml

    echo "mtg configured successfully, start to configure systemctl..."
}

configure_systemctl(){
    echo -e "Configuring systemctl..."
    wget -N --no-check-certificate -O /etc/systemd/system/mtg.service https://raw.githubusercontent.com/missuo/MTProxy/main/mtg.service
    systemctl enable mtg
    systemctl start mtg
    echo "mtg configured successfully, start to configure firewall..."
    systemctl disable firewalld
    systemctl stop firewalld
    ufw disable
    echo "mtg start successfully, enjoy it!"
    echo ""
    # echo "mtg configuration:"
    # mtg_config=$(mtg access /etc/mtg.toml)
    public_ip=$(curl -s ipv4.ip.sb)
    subscription_config="tg://proxy?server=${public_ip}&port=${port}&secret=${secret}"
    subscription_link="https://t.me/proxy?server=${public_ip}&port=${port}&secret=${secret}"
    echo -e "${subscription_config}"
    echo -e "${subscription_link}"
}

change_port(){
    read -p "Enter the port you want to modify(default 8443):" port
	[ -z "${port}" ] && port="8443"
    sed -i "s/bind-to.*/bind-to = \"0.0.0.0:${port}\"/g" /etc/mtg.toml
    echo "Restarting MTProxy..."
    systemctl restart mtg
    echo "MTProxy restarted successfully!"
}

change_secret(){
    echo -e "Please note that unauthorized modification of Secret may cause MTProxy to not function properly."
    read -p "Enter the secret you want to modify:" secret
	[ -z "${secret}" ] && secret="$(mtg generate-secret --hex itunes.apple.com)"
    sed -i "s/secret.*/secret = \"${secret}\"/g" /etc/mtg.toml
    echo "Secret changed successfully!"
    echo "Restarting MTProxy..."
    systemctl restart mtg
    echo "MTProxy restarted successfully!"
}

update_mtg(){
    echo -e "Updating mtg..."
    download_file
    echo "mtg updated successfully, start to restart MTProxy..."
    systemctl restart mtg
    echo "MTProxy restarted successfully!"
}

start_menu() {
    clear
    echo -e "  MTProxy v2 One-Click Installation
---- by Vincent | github.com/missuo/MTProxy ----
 ${green} 1.${plain} Install MTProxy
 ${green} 2.${plain} Uninstall MTProxy
————————————
 ${green} 3.${plain} Start MTProxy
 ${green} 4.${plain} Stop MTProxy
 ${green} 5.${plain} Restart MTProxy
 ${green} 6.${plain} Change Listen Port
 ${green} 7.${plain} Change Secret
 ${green} 8.${plain} Update MTProxy
————————————
 ${green} 0.${plain} Exit
————————————" && echo

	read -e -p " Please enter the number [0-8]: " num
	case "$num" in
    1)
		download_file
        configure_mtg
        configure_systemctl
		;;
    2)
        echo "Uninstall MTProxy..."
        systemctl stop mtg
        systemctl disable mtg
        rm -rf /usr/bin/mtg
        rm -rf /etc/mtg.toml
        rm -rf /etc/systemd/system/mtg.service
        echo "Uninstall MTProxy successfully!"
        ;;
    3) 
        echo "Starting MTProxy..."
        systemctl start mtg
        systemctl enable mtg
        echo "MTProxy started successfully!"
        ;;
    4) 
        echo "Stopping MTProxy..."
        systemctl stop mtg
        systemctl disable mtg
        echo "MTProxy stopped successfully!"
        ;;
    5)  
        echo "Restarting MTProxy..."
        systemctl restart mtg
        echo "MTProxy restarted successfully!"
        ;;
    6) 
        change_port
        ;;
    7)
        change_secret
        ;;
    8)
        update_mtg
        ;;
    0) exit 0
        ;;
    *) echo -e "${Error} Please enter a number [0-5]: "
        ;;
    esac
}
start_menu
