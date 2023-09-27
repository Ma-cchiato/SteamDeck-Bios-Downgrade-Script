#!/bin/bash
sudo systemctl enable jupiter-biosupdate.service
sudo steamos-readonly disable
sudo rm -rf /foxnet
sudo steamos-readonly enable
