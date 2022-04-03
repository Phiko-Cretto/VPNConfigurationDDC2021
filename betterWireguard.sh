#!/bin/bash

presentation(){
	echo "$(tput setaf 1 && tput bold)  _____      _               __  __           _                _         _"
	echo "$(tput setaf 1 && tput bold) / ____|    | |             |  \/  |         | |              | |       | |"
	echo "$(tput setaf 1 && tput bold)| |    _   _| |__   ___ _ __| \  / | ___  ___| |_ ___ _ __ ___| | ____ _| |__   ___ _ __ _ __   ___"
	echo "$(tput setaf 1 && tput bold)| |   | | | | '_ \ / _ \ '__| |\/| |/ _ \/ __| __/ _ \ '__/ __| |/ / _' | '_ \ / _ \ '__| '_ \ / _ \ "
	echo "$(tput setaf 1 && tput bold)| |___| |_| | |_) |  __/ |  | |  | |  __/\__ \ ||  __/ |  \__ \   < (_| | |_) |  __/ |  | | | |  __/"
	echo "$(tput setaf 1 && tput bold) \_____\__, |_.__/ \___|_|  |_|  |_|\___||___/\__\___|_|  |___/_|\_\__,_|_.__/ \___|_|  |_| |_|\___|"
	echo "$(tput setaf 1 && tput bold)        __/ |  $(tput setaf 7)made by $(tput setaf 6)Cave $(tput setaf 7)<3"$(tput sgr0)
	echo "$(tput setaf 1 && tput bold)       |___/   $(tput setaf 7)graphics by $(tput setaf 6)Phiko"$(tput sgr0)
	echo -en "\n"
	echo -en "$(tput setaf 3 && tput bold)\n\nCave <3 and Phiko - Held og lykke til alle\n"
}

getConfFile(){
	echo -en "$(tput setaf 7 && tput bold)\nNote that the config file must be in the same directory as the shellscript\n"
	read -p "Name of your config file from event page (fx conn_0.conf): " confFile
	CONFSTRIP="$(basename $confFile .conf)"
}

installDependencies(){
	if [ -x "$(command -v apt-get)" ]; then apt-get update -y && apt-get install -y resolvconf wireguard
	elif [ -x "$(command -v dnf)" ]; then

		mkdir -p /etc/wireguard/
		if [[ -e /etc/fedora-release ]]; then dnf install -y wireguard-tools
		elif [[ -e /etc/rocky-release ]]; then dnf install -y --skip-broken epel-release elrepo-release && dnf install -y --skip-broken wireguard
		elif [[ /etc/almalinux-release || -e /etc/centos-release ]]; then
			os_version=$(grep -shoE '[0-9]+' /etc/almalinux-release /etc/rocky-release /etc/centos-release | head -1)

			if [[ "$os" -eq 8 ]]; then dnf install -y --skip-broken epel-release elrepo-release && dnf install -y --skip-broken kmod-wireguard wireguard-tools
			elif [[ "$os" -eq 7 ]]; then yum install -y epel-release https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm && yum install -y yum-plugin-elrepo && yum install -y kmod-wireguard wireguard-tools
			else echo "Unfortunately, this script isn't supported on older versions of CentOS 7. Jesus, dude, update your system.">&2 && exit 1; fi

		else echo "FAILED TO INSTALL RELEVANT PACKAGE. Package manager was recognized as dnf, but this system doesn't appear to be neither Rocky Linux nor Fedora. You must manually install the needed packages">&2 && exit 1; fi

	elif [ -x "$(command -v pacman)" ]; then pacman -S --noconfirm wireguard-tools
	else echo "FAILED TO INSTALL RELEVANT PACKAGE. Package manager not found. You must manually install the needed packages">&2 && exit 1; fi
}

checkPriviledges() {
	if [[ "$EUID" -ne 0 ]]; then
		echo "$(tput setaf 1)This installer needs to be run with superuser privileges. Often, this is achieved using sudo to run it."
		exit 1
	fi
}

main(){
	presentation

	checkPriviledges

	getConfFile
	if [ ! -f $confFile ];
	then
		echo "$(tput setaf 2 && tput bold)Go in and download the connection file."
		echo "$(tput setaf 2 && tput bold)On: $(tput setaf 1) https://vpntest.haaukins.com/info"
	else
		ln -s /usr/bin/resolvectl /usr/local/bin/resolvconf
		installDependencies
		cp $confFile /etc/wireguard
		if (wg-quick up $CONFSTRIP 2>&1 | grep "tun"); then
				sh -c "cd /etc/wireguard; sed -i \"/DNS = 1.1.1.1/d\" $confFile"
				wg-quick up $CONFSTRIP
		fi
		wg
	fi
}

main
