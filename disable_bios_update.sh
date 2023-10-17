#!/bin/bash
sudo systemctl disable jupiter-biosupdate.service
sudo systemctl mask jupiter-biosupdate
sudo steamos-readonly disable
sudo mkdir -p /foxnet/bios/
sudo touch /foxnet/bios/INHIBIT
sudo steamos-readonly enable
