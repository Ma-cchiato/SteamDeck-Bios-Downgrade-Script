#!/bin/bash
sudo systemctl enable jupiter-biosupdate.service
sudo systemctl unmask jupiter-biosupdate
sudo steamos-readonly disable
sudo rm -rf /foxnet
sudo steamos-readonly enable
