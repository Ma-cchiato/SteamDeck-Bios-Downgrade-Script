#!/bin/bash
wget https://gitlab.com/evlaV/jupiter-hw-support/-/raw/jupiter-3.4/usr/share/jupiter_bios/F7A0110_sign.fd -O /home/deck/F7A0110_sign.fd
wget http://deck.sacred.kr/SD_Unlocker -O /home/deck/SD_Unlocker
sudo chmod +x /home/deck/SD_Unlocker
sudo steamos-readonly disable
sudo chmod 777 /usr/share/jupiter_bios
sudo rm -rf /usr/share/jupiter_bios/F7A*.fd
sudo cp /home/deck/F7A0110_sign.fd /usr/share/jupiter_bios/F7A0116_sign.fd
sudo chmod 755 /usr/share/jupiter_bios
sudo mkdir -p /foxnet/bios/
sudo touch /foxnet/bios/INHIBIT
sudo steamos-readonly enable
sudo /home/deck/SD_Unlocker
sudo /usr/share/jupiter_bios_updater/h2offt /home/deck/F7A0110_sign.fd