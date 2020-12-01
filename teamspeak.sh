#!/bin/bash

if [[ $# -le 1 ]];
	then echo usage URL NAME;
	exit;
fi

if [[ "$EUID" -ne 0 ]];
	then echo "Please run as root";
	exit;
fi

re='^[0-9]+$'


if  [[ $(id -u $2) =~ $re ]];
	then echo "User $2 already exist";
	exit;
else
	adduser --disabled-login $2;
fi

USER=$2
URL=$1

if [[ `wget -S --spider $URL  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; 
	then echo "File found"
	echo $URL
	wget $URL
else
	echo "File Not found Please set correct URL";
#	exit;
fi

tar -jxvf teamspeak3-server_linux_amd*.tar.bz2

# 1 if minor problems 
# 2 if serious trouble 

if [[ $? -eq 0 ]]; 
	then echo "The command tar was successful"
else
	echo "Have a minor problems or serious trouble"
	exit;
fi

if [ -d teamspeak3-server_linux_amd64 ];
	then mv teamspeak3-server_linux_amd64 /usr/local/teamspeak;
else
	echo "Have a problem with mv teamspeak3-server_linux_amd64 in destination";
	exit;
fi

chown -R $USER:$USER /usr/local/teamspeak

ln -s /usr/local/teamspeak/ts3server_startscript.sh /etc/init.d/teamspeak

if [[ $? -eq 0 ]];
	then echo "The lynk symbolic of ts3server_startscript.sh was successfull";
else
	echo "Have a problem with a ln command";
	exit;
fi

sudo update-rc.d teamspeak defaults 

sudo ufw allow 9987/udp
sudo ufw allow 10011/tcp
sudo ufw allow 3033/tcp  

#sudo service teamspeak start
/etc/init.d/./teamspeak start "license_accepted=1"
