#!/bin/bash

## date format ##
NOW=$(date +"%m-%d-%y-%H%M%S")
DEVICE=$(cat /system/build.prop | grep -E 'product.device=' | cut -d"=" -f2)

########################## QUICK MENU ###############################

f_interface(){
clear
echo "			KALI ANDROID QUICK MENU"
echo ""
echo ""
echo "[1]	Wireless Attacks	[6] Exploit Tools"
echo "[2]	Sniffing/Spoofing	[7] OpenVPN Setup"
echo "[3]	Reverse Shells		[8] VNC Setup"
echo "[4]	Info Gathering		[9] Log/Capture Menu"
echo "[5]	Vulnerability Scan	"
echo ""
echo "[10]	Settings"
echo "[11]	Services"
echo ""
echo "[q]	Exit To Command Line"
echo ""

# wait for character input

read -p "Choice: " menuchoice

case $menuchoice in

1) clear; f_wireless_attacks ;;
2) clear; f_sniffing ;;
3) clear; f_reverse ;;
4) clear; f_information_gathering ;;
5) clear; f_vulnerability ;;
6) clear; f_exploitation ;;
7) clear; f_vpnmenu ;;
8) clear; f_vncmenu ;;
9) clear; f_capture ;;
10) clear; f_settings ;;
11) clear; f_services ;;
q) clear; exit 1 ;;
*) echo "Incorrect choice..." ;
esac
}

########################## WIRELESS MENU ###############################

f_wireless_attacks(){
clear
f_wlan1check
echo "				WIRELESS ATTACKS MAIN MENU"
echo ""
echo ""
echo "[1]	Wifite"
echo "[2]	Kismet"
echo ""
echo "[0]	Exit"
echo ""
read -p "Choice: " wirelesschoice

case $wirelesschoice in

1) clear; f_wifite ;;
2) clear; f_kismet ;;
0) clear; f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_wlan1check(){
adaptor=`ip addr | grep wlan1`
if [ -z "$adaptor" ]; then
    ifconfig wlan1 up
    sleep 2
    echo "Attempting to bring wlan1 up"
    if [ -z "$adaptor" ]; then
    	echo "Still not detecting wlan1, please try plugging it in again."
    	sleep 5
    	clear
    	echo -e "\e[31mWLAN1: NOT FOUND\e[0m"
    	echo ""
    fi
else
	echo -e "\e[92mWLAN1: FOUND\e[0m" 
	echo ""
fi
}

f_wifite(){
cd /captures/wifite
while :
do
clear
echo "* WIFITE QUICK SELECT *"
echo ""
echo "[1] Regular Wifite"
echo "[2] Attack all WEP"
echo "[3] Capture all WPA and use dictionary"
echo "[4] Attack WPS with power over 40+"
echo ""
echo "[0] Exit to Wirelss Attack Menu"
echo ""
echo -n "Enter your menu choice [1-3]: "
read yourch
case $yourch in
1) clear; wifite ;;
2) clear; wifite -all -wep ;;
3) clear; wifite -all -wpa -dict /opt/dic/89.txt ;;
4) clear; wifite -p 40 -wps ;;
0) clear; f_wireless_attacks ;;
*) echo "Incorrect choice..." ;
echo "Press Enter to continue. . ." ; read ;; esac
done
}

f_kismet(){
#!/bin/bash
echo "Make sure BlueNMEA is running before starting with GPS support"
sleep 3
read -p "Would you like to run Kismet with GPS enabled? (y/n)" CONT
if [ "$CONT" == "y" ]; then
	(socat TCP:127.0.0.1:4352 PTY,link=/tmp/gps & gpsd /tmp/gps) & kismet -g;
	killall gpsd
	f_giskismet;
	wipe -f -P 5 /tmp/gps
else
  echo "Running Kismet WITHOUT GPS support..."
  sleep 2
  kismet -g;
  clear
fi
}

f_giskismet(){
clear
# create database folder or check if one exsists
if [ ! -d "/captures/kismet_db" ]; then
	mkdir -p "/captures/kismet_db"
fi
# process all netxml files
cd /captures/kismet/
for capture in $(find . -iname '*.netxml'); do
echo "Adding $capture to datbase"
sleep 5
giskismet -x "$capture" --database "/captures/kismet_db/wireless.dbl"
done
# export kml of all wireless data and copy files to sdcard
giskismet --database "/captures/kismet_db/wireless.dbl" -q "select * from wireless" -o "/captures/kismet/kismet-$NOW.kml"
echo "Created kismet-$NOW.kml file for Google Earth"
if [ -d "/sdcard/kali-nh/captures/" ]; then
	echo "Detected kali-nh capture folder, moving capture files"
	/sdcard/kali-nh/captures/
	zip -rj "kismet-captures-$NOW.zip" /captures/kismet/
	echo "Successfully copied to /sdcard/kali-nh/captures/kismet-captures-$NOW.zip"
	sleep 3
else
	cd /sdcard/
	zip -rj "kismet-captures-$NOW.zip" /captures/kismet/
	echo "Successfully copied to /sdcard/kismet-captures-$NOW.zip"
	sleep 3
fi
# option to erase files
read -p "Would you like to secure erase all files in Kismet /captures folder and database? (y/n): " CONT
if [ "$CONT" == "y" ]; then
	echo "Removing capture files..."
	wipe -f -i -r /captures/kismet/*
	wipe -f -i -r /captures/kismet_db/*
else
  echo "All files copied successfully!";
fi
}

##########################   SNIFFING MENU     ###############################

f_sniffing(){
clear
echo "				SNIFFING/SPOOFING MAIN MENU"
echo ""
echo ""
echo "[1]	tcpdump"
echo "[2]	tshark"
echo "[3]	urlsnarf"
echo "[4]	dsniff"
echo ""
echo "[0]	Exit to main menu"
echo ""
read -p "Choice: " sniffchoice

case $sniffchoice in

1) clear; trap 'f_sniffing' 2; f_tcpdump ;;
2) clear; trap 'f_sniffing' 2; f_tshark ;;
3) clear; trap 'f_sniffing' 2; f_urlsnarf ;;
4) clear; trap 'f_sniffing' 2; f_dsniff ;;
0) clear; f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_tcpdump(){
	f_pick_interface
	echo "ctrl-c to quit and return to sniffing menu"
	tcpdump -i $pickinterface -w /captures/tcpdump/tcpdump-$NOW.cap;
	f_sniffing
}
f_tshark(){
	f_pick_interface
	echo "ctrl-c to quit and return to sniffing menu"
	tshark -i $pickinterface -w /captures/tshark/tshark-$NOW.cap;
	f_sniffing
}
f_urlsnarf(){
	f_pick_interface
	echo "ctrl-c to quit and return to sniffing menu"
	urlsnarf -i $pickinterface > /captures/urlsnarf/urlsnarf-$NOW.log
	f_sniffing
}
f_dsniff(){
	f_pick_interface
	echo "ctrl-c to quit and return to sniffing menu"
	dsniff -i $pickinterface  -w /captures/dsniff/urlsnarf-$NOW.cap;
	f_sniffing
}

########################## INFO GATHER MENU ##############################

f_information_gathering(){
clear
echo "		INFORMATION GATHERING MAIN MENU"
echo ""
echo ""
echo "[1]	Spiderfoot - Footprinting Tool"
echo "[2]	Recon-ng - Web Reconnaissance Framework"
echo ""
echo "[0]	Exit to main menu"
echo ""
read -p "Choice: " infochoice

case $infochoice in
1) clear; trap 'f_information_gathering' 2; f_spiderfoot;;
2) clear; recon-ng; f_information_gathering;;
*) echo "Incorrect choice..." ;
esac
}

f_spiderfoot(){
python /opt/spiderfoot/sf.py
}

########################## VULNERABILITY MENU ###########################

f_vulnerability(){
if [ ! -d "/var/lib/openvas/" ]; then
	clear
	echo "Openvas is not currently installed.  The installation can take a few hours."
	read -p "Would you like to install OpenVas (1GB+ space needed)? (y/n): " installopenvas
		if [ "$installopenvas" == "y" ]; then
			apt-get update && apt-get install -y openvas
			openvas-mkcert -q
			openvas-nvt-sync
			openvas-mkcert-client -n om -i
			service openvas-manager stop
			service openvas-scanner stop
			openvassd
			openvasmd --migrate
			openvasmd --rebuild
			openvas-scapdata-sync
			openvas-certdata-sync
			openvasad -c adduser -n admin -r Admin
			killall openvassd
			sleep 15
			service openvas-scanner start
			service openvas-manager start
			service openvas-administrator restart
			service greenbone-security-assistant restart
			openvas-check-setup
		fi
fi
clear
echo "				VULNERABILITY MENU"
echo ""
echo ""
echo "[1] Start Openvas (https://127.0.0.1:9392)"
echo "[2] Update OpenVas Feeds"
echo ""
echo "[0] Exit to main menu"
echo ""
read -p "Choice: " vulnchoice

case $vulnchoice in
1) clear; service greenbone-security-assistant start; service openvas-scanner start; service openvas-administrator start; service openvas-manager start; f_vulnerability ;;
2) clear; openvas-nvt-sync; openvas-scapdata-sync; openvas-certdata-sync; f_vulnerability ;;
0) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

########################## EXPLOITATION MENU ############################

f_exploitation(){
clear
echo "				EXPLOITATION MAIN MENU"
echo ""
echo ""
echo "[1]	Metasploit"
echo "[2]	Beef-XSS"
echo "[3]	Social-Engineering Toolkit"
echo ""
echo "[0]	Exit to main menu"
echo ""
read -p "Choice: " webchoice

case $webchoice in
1) clear; echo "Msfconsole may take up to 5 minutes to load, please wait..."; service postgresql start; service metasploit start; msfconsole; f_exploitation ;;
2) clear; service beef-xss start; echo "Open browser to local ip on port 3000 (beef/beef)"; sleep 8; f_exploitation ;;
3) clear; setoolkit ; f_exploitation ;;
*) echo "Incorrect choice..." ;
esac
}

f_metasploit(){
msf4
}

########################## REVERSE MENU ################################

f_reverse(){
echo "				REVERSE SHELLS"
echo ""
echo ""
echo "[1] Setup AutoSSH"
echo "[2] Start AutoSSH"
echo ""
echo "[3] Start pTunnel - (TCP over ICMP)"
echo "[4] Stop pTunnnel"
echo ""
#echo "[5] Start iodine (DNS Tunnel)"
#echo "[6] Stop iodine"
echo "[0] Exit to main menu"
echo ""
read -p "Choice: " serviceschoice

case $serviceschoice in
1) clear; f_autossh ;;
2) clear; f_start_autossh ;;
3) clear; f_ptunnel ;;
4) clear; echo "Attempting to shutdown ptunnel" ; kill -KILL $(cat /opt/ptunnel.pid) ; sleep 5 ;;
#5) clear; f_iodine ;;
0) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_autossh(){
clear
if [ -e "/root/.ssh/auto_id_rsa" ]; then
        echo "SSH keys found at /root/.ssh/auto_id_rsa"
        read -p "Would you like to generate new SSH keys? (y/n):" autossh_new_keys
        if [ "$autossh_new_keys" == "y" ]; then
        	rm -rf /root/.ssh/auto_id*
        	f_generate_autossh_keys
        fi
else
	echo "KEY AUTO_ID_RSA NOT FOUND: Generate new SSH keys?"
	f_generate_autossh_keys
fi

	f_generate_autossh_keys()
	{
		echo "Generating new keys"
		chmod 700 /root/.ssh
		ssh-keygen -b 1024 -N '' -f /root/.ssh/auto_id_rsa -t rsa -q
		chmod 600 /root/.ssh/auto_id_rsa
		chmod 644 /root/.ssh/auto_id_rsa.pub
		sleep 4
	}

read -p "Copy keys to remote (middle) server? (y/n): " copykeymiddle
if [ "$copykeymiddle" == "y" ]; then
		echo "Enter remote host connection details:"
		echo ""
		read -p "Enter remote server username: " -e -i "root" amu
		read -p "Enter remote server address (ip/domain): " amh
		read -p "Enter remote server port: " -e -i "22" amp
		ssh-copy-id -i /root/.ssh/auto_id_rsa.pub "-p $amp $amu@$amh"
fi
f_reverse
}

f_start_autossh(){
#
# For help setting up autossh, I utilized the guide here:
# https://raymii.org/s/tutorials/Autossh_persistent_tunnels.html
#
clear
if [ -e "/root/autossh_config" ]; then
	read -p "Use previous autossh configuration? (y/n): " autossh_previous
		if [ "$autossh_previous" == "y" ]; then
			echo "Starting autossh..."
			/root/autossh_config
			f_reverse
		fi
	else
	read -p "Would you like to remove previous configuration? (y/n): " autossh_remove
		if [ "autossh_remove" == "y" ]; then
			rm -rf /root/autossh_config
		fi
fi
clear
read -p "Enter local autossh monitoring port: " -e -i "1010" autossh_local_port
read -p "Enter local autossh reverse tunnel port: " -e -i "6666" autossh_forward_port
read -p "Enter remote server username: " -e -i "root" amu
read -p "Enter remote server address (ip/domain): " amh
read -p "Enter remote server port: " -e -i "22" amp
echo ""
echo "Starting autossh..."
autossh -M $autossh_local_port -o "PubkeyAuthentication=yes" -o "PasswordAuthentication=no" -i /root/.ssh/auto_id_rsa -R $autossh_forward_port:localhost:22 $amu@$amh -p $amp
echo "You can now access this Android device from the remote server using:"
echo "ssh -p $autossh_forward_port $amu@127.0.0.1"
sleep 8
clear
echo "*** The following file will not be secure and will contain server/username information ***"
echo ""
read -p "Would you like to save configuration as an executable file? (y/n): " autossh_file
	if [ "$autossh_file" == "y"]; then
		echo "autossh -M $autossh_local_port -o "PubkeyAuthentication=yes" -o "PasswordAuthentication=no" -i /root/.ssh/auto_id_rsa -R $autossh_forward_port:localhost:22 $amu@$amh -p $amp" > /root/autossh_config
		chmod +x /root/autossh_config
		echo "File saved to /root/autossh_config"
		sleep 5
	fi
f_reverse
}

f_ptunnel(){
	echo "Pick interface to start ptunnel on"
	sleep 3
	f_pick_interface
	clear
	echo "P(ing)tunnel allows you to tunnel TCP connections over ICMP "
	echo "It requires a server running ptunnel with a password set."
	echo "The ptunnel server will then connect to a SSH server. e.g.:"
	echo "Your Device (localhost) <> Ptunnel Proxy Server <> SSH Server"
	echo ""
	read -p "pTunnel server password: " ptunpassword
	read -p "pTunnel server address: " pserver
	read -p "SSH Server address/name you wish to connect to: " pdest
	read -p "SSH server port: " -e -i "22" pport
	# iptables
	#iptables -F
	#iptables -P INPUT ACCEPT
	#iptables -A INPUT -i lo -j ACCEPT
	#iptables -A INPUT -p icmp -j ACCEPT
	#iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	#iptables -A INPUT -j DROP
	ptunnel -p $pserver -lp 8000 -da $pdest -dp $pport -x $ptunpassword -c $pickinterface -daemon /opt/ptunnel.pid &
	clear
	echo "Some example connections to $pserver:"
	echo "ssh -p 8000 localhost"
	echo "sftp -P 8000 localhost"
	sleep 3
f_reverse
}

#f_iodine(){
#	clear
#	echo "Iodine allows you to tunnel traffic through DNS."
#	echo "It must be running on a server with a domain and"
#	echo "DNS records setup properly."
#	echo ""
#	read -p "iodine server password: " iopassword
#	read -p "pTunnel server address: " ioservername
#	iodine -F /opt/iodine.pid -P $iopassword $ioservername
#	sleep 3
#f_reverse
#}

########################## SERVICES MENU ###############################

f_services(){
clear
echo "				SERVICES"
echo ""
echo ""
echo "[1] Start SSH Server"
echo "[2] Stop SSH Server"
echo ""
echo "[3] Start VNC Server"
echo "[4] Stop VNC Server"
echo ""
echo "[5] Start OpenVPN Server"
echo "[6] Stop OpenVPN Server"
echo ""
echo "[7] Start XServer on localhost (Android Applicaiton XServer XSDL)"
echo ""
echo "[0] Exit to main menu"
echo ""
read -p "Choice: " serviceschoice

case $serviceschoice in
1) clear; f_ssh ;;
2) clear; service ssh stop ;;
3) clear; f_vncstart ;;
4) clear; f_vnckill ;;
5) clear; f_startvpn ;;
6) clear; service openvpn stop ; iptables -F ; iptables -X ; echo "Stopping Openvpn" ;;
7) clear; DISPLAY=127.0.0.1:0.0 startxfce4; echo "Server started on localhost to be used with Xserver XSDL application" ;;
0) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_ssh(){
	service ssh start
	echo "Starting SSHD"
	sleep 3
}

f_vncstart(){
clear
if [ ! -e "/etc/vnc.conf" ]; then
	echo "VNC Configuration file not found in /etc/vnc.conf"
	echo "Please run VNC Setup before starting VNC."
	sleep 5
	f_vncmenu
fi
echo "VNC START MENU"
echo ""
echo "[1] Start VNC on all interfaces"
echo "[2] Start VNC on localhost only"
echo ""
echo "[0] Exit to main menu"
echo ""
echo -n "Enter your menu choice [1-5]: "
read -p "Choice:" vncmenustart

case $vncmenustart in
1) clear ; f_vnc_allint ;;
2) clear ; f_vnc_local ;;
0) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_vnc_allint(){
vncserver
echo "Display Number :X will be port 590X."
read -p "Press any key to continue..."
f_interface
}

f_vnc_local(){
vncserver -localhost -nolisten tcp
echo "Display Number :X will be port 590X."
read -p "Press any key to continue..."
f_interface
}

f_vnckill(){
	echo "Removing all PID and log files from /root/.vnc/"
	echo "Killing all VNC process ID's"
	sleep 2
	kill $(ps aux | grep 'Xtightvnc' | awk '{print $2}')
	echo "Removing PID files"
	sleep 2
	vncdisplay=$(ls ~/.vnc/*.pid | sed -e s/[^0-9]//g)
	for x in $vncdisplay; do tightvncserver -kill :$x; done;
	echo "Removing log files"
	sleep 2
	rm /root/.vnc/*.log;
	echo "Removing lock file"
	sleep 2
	rm -r /tmp/.X*
	echo "All VNC process/logs have hopefully been removed"
	sleep 3
	f_services
}

########################## VPN MENU ###############################

f_vpnmenu(){
clear
echo "				OPENVPN MAIN MENU"
echo ""
echo ""
echo "[1] Generate VPN Server Keys *will remove previous old keys"
echo "[2] Generate Client Keys"
echo "[3] Export Client Keys to sdcard"
echo ""
echo "[0] Exit to Settings Menu"
echo -n "Enter your menu choice [1-6]: "
read -p "Choice: " vpnkeychoice

case $vpnkeychoice in
1) f_server_key ;;
2) f_domain_clientkey ;;
3) f_exportkeys ;;
0) f_settings ;;
*) echo "Incorrect choice..." ;
esac
}

f_server_key(){
cd /etc/openvpn
echo "Removing previous server..."
rm -rf easy-rsa
cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 ./easy-rsa
cd easy-rsa
echo 'export EASY_RSA="/etc/openvpn/easy-rsa"' >> vars
source vars
./clean-all
./pkitool --initca
ln -s openssl-1.0.0.cnf openssl.cnf
echo "Building Server Certificates"
sleep 3
echo "Generating Certificate Authority Key..."
./build-ca OpenVPN
echo "Generating Server Key..."
./build-key-server server
echo "Generating client1 Key..."
./build-key client1
./build-dh
cd /etc/openvpn
echo "Creating configuration file in /etc/opevpn/openvpn.conf"
cat << EOF > /etc/openvpn/openvpn.conf
dev tun
proto udp
port 1194
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key
dh /etc/openvpn/easy-rsa/keys/dh1024.pem
user nobody
group nobody
server 10.8.0.0 255.255.255.0 
# server and remote endpoints 
ifconfig 10.8.0.1 10.8.0.2 
keepalive 10 60
persist-key
persist-tun
log-append /var/log/openvpn
#status /var/log/openvpn-status.log
verb 5
client-to-client
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
script-security 3
comp-lzo
EOF

# RETURN TO VPN MENU

f_vpnmenu
}

f_domain_clientkey(){
clear
#PUBLIC_IP=$(curl www.icanhazip.com)
#echo "Your current ip is: $PUBLIC_IP"
#echo ""
read -p "Enter custom domain/IP/dynamic IP (e.g. your public/local ip): " DOMAIN_IP
cat << EOF > /etc/openvpn/easy-rsa/keys/kaliserver.ovpn
dev tun
client
proto udp
remote $DOMAIN_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client1.crt
key client1.key
comp-lzo
verb 3	
EOF
echo "Finished. Client key created at /etc/openvpn/easy-rsa/keys/kaliserver.ovpn"
sleep 5

# RETURN TO VPN MENU

f_vpnmenu
}

f_exportkeys(){
echo "Zipping client keys to /sdcard/openvpn-kaliserver-clientcert.zip"
sleep 5
cd /etc/openvpn/easy-rsa/keys/
zip -r6 /sdcard/kali-nh/openvpn-kaliserver-clientcert.zip ca.crt ca.key client1.crt client1.csr client1.key kaliserver.ovpn #openvpn-keys.tgz
echo "If you received an error things may have gone wrong when generating a certificate..."
sleep 6

# RETURN TO VPN MENU

f_vpnmenu
}

f_startvpn(){
if [ ! -e "/etc/openvpn/openvpn.conf" ]; then
	echo "Default openvpn configuration was not found in /etc/openvpn/openvpn.conf:"
	echo "Please use OpenVPN Setup from main menu."
	sleep 3
	f_vpnmenu
fi
echo "Starting OpenVPN"
sleep 3
# Flush iptables
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
# Start iptables
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -s 10.8.0.0/24 -j ACCEPT
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o wlan0 -j MASQUERADE
service openvpn start
echo "OpenVPN started"
sleep 5
f_vpnmenu
}

########################## VNC MENU ###############################

f_vncmenu(){
clear
echo "				VNC SETTINGS"
echo ""
echo "[1] Add/change VNC Password"
echo "[2] Set VNC default resolution"
echo ""
echo "[0] Exit to main menu"
echo ""
read -p "Choice: " vncsettingschoice

case $vncsettingschoice in
1) clear; echo "Change your VNC password:"; vncpasswd; f_vncmenu ;;
2) clear; f_vncres ;;
0) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_vncres(){
if [ "$DEVICE" == "hammerhead" ]; then
	vncres="1920x1080"
fi
if [ "$DEVICE" == "flo" ] || [ "$DEVICE" == "deb" ]; then
	vncres="1920x1200"
fi
if [ "$DEVICE" == "grouper" ] || [ "$DEVICE" == "tilapia" ]; then
	vncres="1280x1024"
fi
if [ "$DEVICE" == "manta" ]; then
	vncres="2650x1600"
fi

echo ""
echo "Detected ${DEVICE}: will set resolution to ${vncres} in /etc/vnc.conf "
echo ""
read -p "Would you like to set a different resolution? (y/n): " -e -i "n" customvncres
if [ $customvncres == "y" ]; then
	read -p "Enter custom display size (e.g. 1920x1080): " vncres
fi

cat << EOF > /etc/vnc.conf
\$geometry ="$vncres";
\$depth = "24";
EOF
clear
echo "Configuration file created at /etc/vnc.conf:"
echo "============================================"
cat /etc/vnc.conf
sleep 7
f_vncmenu
}

########################## CAPTURE MENU ###############################

f_capture(){
clear
echo "				LOG/CAPTURE MENU"
echo ""
echo "[1] Sync all captures to SDCARD"
echo "[2] Wipe all captures on local device"
echo ""
echo "[0] Exit to main menu"
echo ""
read -p "Choice: " logchoice

case $logchoice in
1) clear; f_sync_cap ;;
2) clear; f_wipe_cap ;;
0) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_sync_cap(){
if [ ! -d /sdcard/kali-nh/captures ]; then
	echo "Created folder /sdcard/kali-nh/captures"
	mkdir -p /sdcard/kali-nh/captures
fi
echo "Copying captures to /sdcard/kali-nh/captures..."
sleep 3	
rsync -avP /captures /captures/ /sdcard/kali-nh/captures
f_capture
}

f_wipe_cap(){
read -p "Are you sure you want to wipe all files in /captures? (y/n) : " wipecaptures
	if [ $wipecaptures == "y" ]; then
		find /captures -type f -exec wipe -f {} \;
		echo "Success! All files wiped in /captures"
		sleep 4
		f_capture
	else
		f_capture
	fi
}

########################## SETTINGS MENU ###############################

f_settings(){
clear
echo "				SETTINGS"
echo ""
echo "[1] Configure Timezone"
echo "[2] Create Metasploit User and Database"
echo "[3] Macchanger"
echo "[4] Install NodeJS"
echo "[0] Exit to main menu"
echo ""
read -p "Choice:" settingschoice

case $settingschoice in
1) clear; dpkg-reconfigure tzdata ;;
2) clear; f_msuser ;;
3) clear; f_macchanger ;;
4) clear; f_nodejs ;;
0) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_nodejs(){
cd /tmp
echo "Downloading install script"
wget https://raw.github.com/creationix/nvm/master/install.sh && chmod +x install.sh
source ~/.nvm/nvm.sh
echo "Starting NodeJS install.  This will take a while..."
sleep 5
nvm install 0.11.11
rm -rf ~/.nvm
rm -rf /tmp/install.sh
f_settings
}

f_msuser() {
	service postgresql start
	echo "Switching to user postgres"
	su postgres	
	read -p "Enter Metasploit database username:" msuser
	createuser -D -P -R -S $msuser
	read -p "Enter Metasploit database name:" dbname
	createdb --owner=$msuser $dbname
	su root
	echo "You can now add database connection to startup at ~/.msf4/msfconsole.rc"
	echo "Add:"
	echo "db_connect $msuser:YOURPASSWORD@127.0.0.1:5432/$dbname"
	sleep 4
	f_settings
}

f_macchanger(){
# make sure ifconfig wlan1 is up already
adaptor=`ip addr | grep wlan1`
if [ -z "$adaptor" ]; then
    ifconfig wlan1 up
fi
f_pick_interface
read -p "Use random MAC address on ${pickinterface}? (y/n)" randommac
if [ "$randommac" == "y" ]; then
	macchanger --random $pickinterface
	else
		read -p "Would you like to set a specific MAC address for ${pickinterface}?" specificmac
		if [ "$specificmac" == "y" ]; then
			read -p "Enter your specific MAC address: " spec_evil_mac
			macchanger --mac=$spec_evil_mac $pickinterface
		fi
fi
f_settings
}

##############################################
# PICK INTERFACE USED FOR MULTPILE FUNCTIONS
##############################################

f_pick_interface(){
echo ""
echo "Choose which interface to use"
echo ""
echo "[1]	wlan0"
echo "[2]	wlan1 (External wireless USB)"
echo "[3]	rmnet0 (3G)"
echo "[4]	eth0 (Ethernet)"
echo "[5]	rndis0 (USB > Ethernet)"
echo ""
read -p "Choice: " sniffinterface

case $sniffinterface in
1) clear; pickinterface=wlan0 ;;
2) clear; pickinterface=wlan1 ;;
3) clear; pickinterface=rmnet0 ;;
4) clear; pickinterface=eth0 ;;
5) clear; pickinterface=rndis0 ;;
*) echo "Incorrect choice..." ;;
esac
}

# **** START **** #

f_interface