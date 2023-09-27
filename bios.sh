#!/bin/bash
wget https://gitlab.com/evlaV/jupiter-hw-support/-/raw/jupiter-3.4/usr/share/jupiter_bios/F7A0110_sign.fd -O '/home/deck/F7A0110_sign.fd'
wget https://github.com/Ma-cchiato/deck_bios_downgrade/raw/main/SD_Unlocker -O '/home/deck/SD_Unlocker'
sudo chmod +x /home/deck/SD_Unlocker
sudo steamos-readonly disable
sudo rm -rf /usr/share/jupiter_bios/F7A*.fd
sudo cp '/home/deck/F7A0110_sign.fd' '/usr/share/jupiter_bios/F7A0116_sign.fd'
sudo steamos-readonly enable
sudo /home/deck/SD_Unlocker
sudo /usr/share/jupiter_bios_updater/h2offt '/home/deck/F7A0110_sign.fd'
