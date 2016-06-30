Hello,

here you find a way how to update VPN App for Netgear ReadyNAS - specifically tested on ARM version of ReadyNAS RN 104.

Original post was put here: https://community.netgear.com/t5/Current-NETGEAR-and-Partners/How-can-I-update-SoftEther-VPN-App-to-Newest-Version-ReadyNAS/m-p/1072060#M4800

Maybe automated script can be developed to achieve automated update of this great and well supported VPN Solution (see my automated script update in the folder ../NZBGet-update.

Manual Update Instructions:
===========================

Tested on NETGEAR ReadyNAS 10400.
 
Current version of the VPN App is 1.5 which contains SoftEther VPN Server version 4.12.
 
I successfully updated the SoftEther VPN Server to latest version as of today 4.19 - Build 9605.
 
The solution is to download latest binary build for ARM (my ReadyNAS is ARM v7) and then copy it to the folder /apps/vpnserver/bin/arm/ . In this location there is a compilation script which can rebuild the vpnserver and vpncmd executables (ELF) using the latest binary release of the downloaded SoftEther VPN Server.
 
Steps - ssh root access is required:
 
1) Stop the VPN Server App in ReadyNAS Web UI
2) ssh to the ReadyNAS box (i.e. using PuTTy)
3) Become root by executing "sudo su" if your user is sudoer or logon directly as user root
4) Install build tools to be able to execute the SoftEther build:
 
apt-get update
apt-get install make libc6-dev gcc gdb libtag1-dev uuid-dev
5) download latest ARM EABI Binary release of the SoftEther VPN Server - in my case 4.19-Build 9605
 
wget http://www.softether-download.com/files/softether/v4.19-9605-beta-2016.03.06-tree/Linux/SoftEther_VP...
 
6) Untar the archive
tar xvf softether-vpnserver-v4.19-9605-beta-2016.03.06-linux-arm_eabi-32bit.tar.gz
The directory vpnserver is created.
 
7) Copy the content of the vpnserver directory (the archive extract) over the files in the directory /apps/vpnserver/bin/arm/
 
8) cd to /apps/vpnserver/bin/arm/ and build the new ELF executables:
 
cd  /apps/vpnserver/bin/arm/
./.install.sh - you have to view & accept the license agreement, after that the new executables (vpnserver and vpncmd) should be build using the files extracted from the latest binary release of the SoftEther VPN Server
9) Now copy everything from /apps/vpnserver/bin/arm/ also one level up to /apps/vpnserver/bin (dunno why it's duplicated there)
 
10) make sure you return the ownership of the files to the admin user:
cd  /apps/vpnserver
chown -R admin:admin bin/
11) Cleanup the extracted vpnserver directory and the downloaded archive
 
12) Start the VPN Server App from ReadyNAS Web UI and Enjoy new version (don't forget to use compatible VPN Client tools)

===============================================================================================================================
Additional Update from comunity user "brlathanjr":
===============================================================================================================================

 I was able to successfully upgrade the RN516. I wanted to shared these instructions, because it will simply future upgrades, because in the future you will need to change the file name and remove the apt-get install steps.
 
apt-get update
apt-get upgrade
apt-get install build-essential
apt-get install make libc6-dev gcc gdb libtag1-dev uuid-dev

mkdir /root/softether
cd /root/softether

wget http://www.softether-download.com/files/softether/v4.19-9605-beta-2016.03.06-tree/Linux/SoftEther_VP...

tar xvf softether-vpnserver-v4.19-9605-beta-2016.03.06-linux-x64-64bit.tar.gz

cp -avr /apps/vpnserver/bin/vpn_server.config /root/softether/vpnserver/
cp -avr /apps/vpnserver/bin/vpn_server.config.save /root/softether/vpnserver/

make

1
1
1

cp -avr /root/softether/vpnserver/* /apps/vpnserver/bin/arm
cp -avr /apps/vpnserver/bin/arm/* /apps/vpnserver/bin
cd /apps/vpnserver/bin/arm

./vpncmd
3
check
exit

cd /apps/vpnserver
chown -R admin:admin bin/


rm -rf /root/softether

