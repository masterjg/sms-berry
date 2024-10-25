#!/bin/bash

# Wait for GSM modem to show up
# dmesg | grep "GSM modem (1-port) converter now attached to ttyUSB1"

# echo 'SUBSYSTEM=="tty", ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="155f", ENV{ID_USB_INTERFACE_NUM}=="00", SYMLINK+="sms", RUN+="/usr/bin/killall -SIGHUP gammu-smsd"' > /etc/udev/999-sms-gateway.rules

sudo apt install gammu gammu-smsd gawk -y

MODEM_VENDOR_ID=""
MODEM_PRODUCT_ID=""
while [[ -z "$MODEM_VENDOR_ID" || -z "$MODEM_PRODUCT_ID" ]]; do
	read MODEM_VENDOR_ID MODEM_PRODUCT_ID < <(lsusb | gawk 'match($0, "([0-9a-f]{4}):([0-9a-f]{4}).*HUAWEI_MOBILE.*", r) { print r[1] " " r[2] }')
	sleep 1
done

for TTY_DEVICE in /sys/bus/usb-serial/devices/ttyUSB*; do
	USB_PATH="$(dirname "$(readlink -f "${TTY_DEVICE}")")"
	while [[ -n "${USB_PATH}" && ! -e "${USB_PATH}/idVendor" ]]; do
		USB_PATH="$(dirname "${USB_PATH}")"
	done
	if [[ -e "${USB_PATH}/idVendor" && -e "${USB_PATH}/idProduct" ]]; then
		DEVICE_VENDOR_ID="$(cat "${USB_PATH}/idVendor")"
		DEVICE_PRODUCT_ID="$(cat "${USB_PATH}/idProduct")"
		if [[ "${DEVICE_VENDOR_ID}" == "${MODEM_VENDOR_ID}" && "${DEVICE_PRODUCT_ID}" == "${MODEM_PRODUCT_ID}" ]]; then
			MODEM_TTY="/dev/$(basename "${TTY_DEVICE}")"
			break
		fi
	fi
done

cat <<- EOF | sudo tee /root/.gammurc >/dev/null
	[gammu]

	port = ${MODEM_TTY}
	model = 
	connection = at19200
	synchronizetime = yes
	logfile = 
	logformat = nothing
	use_locking = 
	gammuloc = 
EOF

sudo gammu --identify