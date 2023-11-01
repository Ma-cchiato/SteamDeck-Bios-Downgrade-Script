#!/bin/bash
sudo systemctl enable jupiter-biosupdate.service
sudo systemctl unmask jupiter-biosupdate
sudo steamos-readonly disable
sudo rm -rf /foxnet
sudo steamos-readonly enable
echo $(zenity --width=180 --height=20 --warning --title="Reboot Required" --text "Proceed with the reboot to enable the Bios Update.")
sudo reboot
