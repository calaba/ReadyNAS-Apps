This is automated script for updating the application NZBGet for the Netgear ReadyNAS - specifically tested on ARM version of the ReadyNAS RN 104.

Netgear Apps (http://apps.readynas.com/pages/?page_id=9) currently offer NZBGet App - version 1.0.4 - which includes old distribution of nzbget - version 11. 
The NZBBGet App debian installation package can be downloaded here - http://apt.readynas.com/packages/readynasos/dists/apps/pool/n/nzbget-app/nzbget-app_1.0.4_all.deb 

You can download nzbget tool used by the NZBGet Netgaer App from https://github.com/nzbget - specifically you look for linux binary distribution named "nzbget-16.4-bin-linux.run".

Currently released version is 16.4 - https://github.com/nzbget/nzbget/releases/download/v16.4/nzbget-16.4-bin-linux.run

I have created script - repackage-latest-nzbget-for-ReadyNAS.sh - to automate the repackaging of the NZBGet App so it can use newer version of nzbget and thus also resolve the bugs and use new features.

One of the newest features in version 17.x (testing, not yet released) contains a new feature "Retry Failed Articles" is the one which can be very handy I hope.

WARNING: 

	1) No guaranties provided, try on your own risk.
	2) Backup the NZBGet App settings (Setting -> System -> Backup) so you can restore it back after doing the new updated/repackaged install of the NZBGet App.
	3) If anything goes wrong - you can uninstall the updated/repackaged version of NZBGet App and put back the official version.

To update the NZBGet App you need:

	1) Shell Access to the ReadyNAS (tested with root, might work with regular user) - in theory might be repackaged on any linux distribution as long as the nzbget installer packages "nzbget-16.4-bin-linux.run" can be executed (unpacked).
	2) You might need those tools to be installed on your ReadyNAS linux box:
	
		- apt-get install git
		- apt-get install dpkg-deb
		- apt-get install wget
		
	3) You need to download the "base package" - nzbget-app_1.0.4_all.deb - which structure is used and content is replaced with updated nzbget version. You can download the nzbget-app_1.0.4_all.deb by:
		
		- wget http://apt.readynas.com/packages/readynasos/dists/apps/pool/n/nzbget-app/nzbget-app_1.0.4_all.deb

To update the NZBGet on your ReadyNAS:

	1) Logon as root to your ReadyNAS box (or logon as regular user and execute 'sudo su' to become root)
	2) cd ~ (to make home dir working directory)
	3) wget http://apt.readynas.com/packages/readynasos/dists/apps/pool/n/nzbget-app/nzbget-app_1.0.4_all.deb (will download base package)
	4) git clone 
./repackage-latest-nzbget-for-ReadyNAS.sh https://github.com/nzbget/nzbget/releases/download/v16.4/nzbget-16.4-bin-linux.run nzbget-app_1.0.4_all

