#Ness VMS Server Setup Script
#https://github.com/kvellaNess/NxVMS
#Disable Auto Updates for now
set -e
function killService() {
    service=$1
    sudo systemctl stop $service
    sudo systemctl kill --kill-who=all $service
    # Wait until the status of the service is either exited or killed.
    while ! (sudo systemctl status "$service" | grep -q "Main.*code=\(exited\|killed\)")
    do
        sleep 10
    done
}
function disableTimers() {
    sudo systemctl disable apt-daily.timer
    sudo systemctl disable apt-daily-upgrade.timer
}
function killServices() {
    killService unattended-upgrades.service
    killService apt-daily.service
    killService apt-daily-upgrade.service
}
function main() {
    disableTimers
    killServices
}
main
sudo pkill unattended-upgrades
#Grab some dependencies
echo "Grab some dependencies"
sudo apt update
sudo apt -y install figlet beep gdebi cockpit
#Remove Amazon Crap
echo "Remove Amazon Stuff" | figlet
sudo rm /usr/share/applications/ubuntu-amazon-default.desktop
sudo rm /usr/share/unity-webapps/userscripts/unity-webapps-amazon/Amazon.user.js
sudo rm /usr/share/unity-webapps/userscripts/unity-webapps-amazon/manifest.json
#Remove Extra stuff
echo "Remove Other Apps" | figlet
sudo apt -y purge libreoffice* thunderbird rhythmbox
sudo apt -y clean
sudo apt -y autoremove
#Update Server
echo "Update Server" | figlet
sudo apt -y upgrade
#Download the latest Nx Server Release
echo "Download NxWitness" | figlet
wget "http://updates.networkoptix.com/default/29987/linux/nxwitness-server-4.0.0.29987-linux64.deb" -P ~/Downloads
#Download the latest Nx Desktop Client Release
wget "http://updates.networkoptix.com/default/29987/linux/nxwitness-client-4.0.0.29987-linux64.deb" -P ~/Downloads
#Install NX Server
echo "Install NxWitness" | figlet
sudo gdebi --non-interactive ~/Downloads/nxwitness-server-4.0.0.29987-linux64.deb
#Install Nx Client
sudo gdebi --non-interactive ~/Downloads/nxwitness-client-4.0.0.29987-linux64.deb
#Download Wallpaper
wget "https://github.com/kvellaNess/NxVMS/raw/master/NxBG.png" -P ~/Pictures
wget "https://github.com/kvellaNess/NxVMS/raw/master/NxLock.png" -P ~/Pictures
#Set Wallpaper
gsettings set org.gnome.desktop.background picture-uri 'file:////home/user/Pictures/NxBG.png'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:////home/user/Pictures/NxLock.png'
#Restart Auto Updates
sudo service unattended-upgrades start
#Finished!
echo "All Done!" | figlet