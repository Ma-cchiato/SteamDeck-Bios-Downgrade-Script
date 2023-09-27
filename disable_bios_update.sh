#!/bin/bash
sudo steamos-readonly disable
sudo mkdir -p /foxnet/bios/
sudo touch /foxnet/bios/INHIBIT
sudo steamos-readonly enable