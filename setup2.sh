#!/bin/bash

sudo apt install gawk gammu gammu-smsd -y

MODEM_VENDOR_ID=""
MODEM_PRODUCT_ID=""
while [[ -z "$MODEM_VENDOR_ID" || -z "$MODEM_PRODUCT_ID" ]]; do
	read MODEM_VENDOR_ID MODEM_PRODUCT_ID < <(lsusb | gawk 'match($0, "([0-9a-f]{4}):([0-9a-f]{4}).*HUAWEI_MOBILE.*", r) { print r[1] " " r[2] }')
	sleep 1
done

sudo systemctl disable --now ModemManager

cat <<- EOF | sudo tee /etc/udev/rules.d/999-sms-proxy.rules >/dev/null
	SUBSYSTEM=="tty", KERNEL=="ttyUSB*", ATTRS{idVendor}=="${MODEM_VENDOR_ID}", ATTRS{idProduct}=="${MODEM_PRODUCT_ID}", ENV{ID_USB_INTERFACE_NUM}=="00", SYMLINK+="sms-proxy", RUN+="/usr/bin/systemctl reload gammu-smsd"
EOF

sudo reboot
