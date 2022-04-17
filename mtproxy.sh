#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#================================================================
#	System Required: CentOS 6/7/8,Debian 8/9/10,Ubuntu 16/18/20
#	Description: MTProxy v2 One-Click Installation
#	Version: 0.1
#	Author: Vincent Young
# 	Telegram: https://t.me/missuo
#	Github: https://github.com/missuo/MTProxy
#	Latest Update: April 17, 2022
#=================================================================

# Define Color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Make sure run with root
[[ $EUID -ne 0 ]] && echo -e "[${red}Errot${plain}]Please run this script with ROOT!" && exit 1

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
        echo -e "${red}Failure to detect mtp version may be due to exceeding Github API limitations, please try again later."
        exit 1
    fi
    echo -e "Latest version of mtp detected: ${last_version}, start installing..."
    version=$(echo ${last_version} | sed 's/v//g')
    wget -N --no-check-certificate -O /usr/bin/mtg-${last_version}-linux-{$bit}.tar.gz https://github.com/9seconds/mtg/releases/download/${last_version}/mtg-${version}-linux-{$bit}.tar.gz
    if [[ ! -f "/usr/bin/mtg-${last_version}-linux-${bit}.tar.gz" ]]; then
        echo -e "${red}Download mtp-${last_version}-linux-${bit}.tar.gz failed, please try again."
        exit 1
    fi
    tar -xzf /usr/bin/mtg-${last_version}-linux-${bit}.tar.gz -C /usr/bin
    rm -rf /usr/bin/mtg-${last_version}-linux-${bit}.tar.gz
    chmod +x /usr/bin/mtg
    echo -e "mtp-${last_version}-linux-${bit}.tar.gz installed successfully, start to configure..."
}

configure_mtp(){
    echo -e "Configuring mtp..."
    wget -N --no-check-certificate -O /etc/mtp.toml https://raw.githubusercontent.com/missuo/MTProxy/main/mtp.toml
    
    echo ""
    read -p "Please enter a spoofed domain (default google.com): " domain
	[ -z "${domain}" ] && domain="google.com"

	echo ""
    read -p "Enter the port to be listened to (default 8443):" port
	[ -z "${port}" ] && port="8443"

    secret=$(mtg generate-secret --hex $domain)
    
    echo "Waiting configuration..."

    sed -i "s/secret.*/secret = \"${secret}\"/g" /etc/mtp.toml
    sed -i "s/bind-to.*/bind-to = \"0.0.0.0:${port}\"/g" /etc/mtp.toml

    echo "mtp configured successfully, start to configure systemctl..."
}

configure_systemctl(){
    echo -e "Configuring systemctl..."
    wget -N --no-check-certificate -O /etc/systemd/system/mtp.service https://raw.githubusercontent.com/missuo/MTProxy/main/mtp.service
    systemctl enable mtp
    systemctl start mtp
    echo "mtp configured successfully, start to configure firewall..."
    systemctl disable firewalld
    systemctl stop firewalld
    ufw disable
    echo "mtp start successfully, enjoy it!"
    echo ""
    echo "mtp configuration:"
    mtp_config=$(mtg access /etc/mtg.toml)
    echo -e "${mtp_config}"
}

start_menu() {
    clear
    echo ""
    echo && echo -e "  MTProxy v2 One-Click Installation
---- by Vincent | github.com/missuo/MTProxy ----
 ${green} 1.${plain} Install MTProxy
 ${green} 2.${plain} Uninstall MTProxy
————————————
 ${green} 3.${plain} Start MTProxy
 ${green} 4.${plain} Stop MTProxy
 ${green} 5.${plain} Restart MTProxy
————————————
 ${red} 0.${plain} Exit
————————————" && echo

	read -e -p " Please enter the number [0-5]:" num
	case "$num" in
    1)
		download_file
        configure_mtp
        configure_systemctl
		;;
    2)
        echo "Uninstall MTProxy..."
        systemctl stop mtp
        systemctl disable mtp
        rm -rf /usr/bin/mtg
        rm -rf /etc/mtp.toml
        rm -rf /etc/systemd/system/mtp.service
        echo "Uninstall MTProxy successfully!"
        ;;
    3) 
        echo "Starting MTProxy..."
        systemctl start mtp
        systemctl enable mtp
        echo "MTProxy started successfully!"
        ;;
    4) 
        echo "Stopping MTProxy..."
        systemctl stop mtp
        systemctl disable mtp
        echo "MTProxy stopped successfully!"
        ;;
    5)  echo "Restarting MTProxy..."
        systemctl restart mtp
        echo "MTProxy restarted successfully!"
        ;;
    0) exit 0
        ;;
    *) echo -e "${Error} Please enter a number [0-5]"
        ;;
    esac
}
start_menu