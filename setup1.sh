#!/bin/bash

sudo apt update
sudo apt dist-upgrade -y
sudo sed -i "s/HuaweiAltModeGlobal=.*/HuaweiAltModeGlobal=1/" /etc/usb_modeswitch.conf
sudo reboot