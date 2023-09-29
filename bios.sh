#!/bin/bash
wget https://gitlab.com/evlaV/jupiter-hw-support/-/raw/jupiter-3.4/usr/share/jupiter_bios/F7A0110_sign.fd -O '/home/deck/F7A0110_sign.fd'
wget https://github.com/Ma-cchiato/deck_bios_downgrade/raw/main/SD_Unlocker -O '/home/deck/SD_Unlocker'
chmod +x /home/deck/SD_Unlocker
sudo steamos-readonly disable
sudo rm -rf /usr/share/jupiter_bios/F7A*.fd
sudo cp '/home/deck/F7A0110_sign.fd' '/usr/share/jupiter_bios/F7A0116_sign.fd' # For SteamOS 3.5 ~ Stable 
sudo cp '/home/deck/F7A0110_sign.fd' '/usr/share/jupiter_bios/F7A0118_sign.fd' # For SteamOS 3.6 
sudo /usr/share/jupiter_bios_updater/h2offt '/home/deck/bios_backup.fd' -O # 기존 바이오스 백업, 복구 가이드는 https://gall.dcinside.com/mgallery/board/view/?id=steamdeck&no=91558 참고
sudo steamos-readonly enable
sudo /home/deck/SD_Unlocker
sudo /usr/share/jupiter_bios_updater/h2offt '/home/deck/F7A0110_sign.fd'
