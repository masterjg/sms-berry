#!/bin/bash

sudo apt install gawk gammu gammu-smsd -y

#sudo rm -f /dev/gsmmodem2 #double check if exists

MODEM_VENDOR_ID=""
MODEM_PRODUCT_ID=""
while [[ -z "$MODEM_VENDOR_ID" || -z "$MODEM_PRODUCT_ID" ]]; do
	read MODEM_VENDOR_ID MODEM_PRODUCT_ID < <(lsusb | gawk 'match($0, "([0-9a-f]{4}):([0-9a-f]{4}).*HUAWEI_MOBILE.*", r) { print r[1] " " r[2] }')
	sleep 1
done

cat <<- EOF | sudo tee /etc/udev/rules.d/999-sms-proxy.rules >/dev/null
	SUBSYSTEM=="tty", KERNEL=="ttyUSB*", ATTRS{idVendor}=="${MODEM_VENDOR_ID}", ATTRS{idProduct}=="${MODEM_PRODUCT_ID}", SYMLINK+="sms-proxy", RUN+="/usr/bin/systemctl reload gammu-smsd"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger --attr-match=idVendor="${MODEM_VENDOR_ID}" --attr-match=idProduct="${MODEM_PRODUCT_ID}"

cat <<- EOF | sudo tee /root/.gammurc >/dev/null
	[gammu]

	port = /dev/sms-proxy
	model = 
	connection = at19200
	synchronizetime = yes
	logfile = 
	logformat = nothing
	use_locking = 
	gammuloc = 
EOF

sudo gammu --identify

cat <<- 'EOF' > /home/marius/process_sms.sh
	#!/bin/bash

	FROM="${SMS_1_NUMBER}"
	MESSAGE=

	MESSAGE_FILE_NAMES=("$@")

	for MESSAGE_FILE_NAME in "${MESSAGE_FILE_NAMES[@]}"; do
		MESSAGE_FILE="/var/spool/gammu/inbox/${MESSAGE_FILE_NAME}"
		MESSAGE+="$(cat "${MESSAGE_FILE}")"
		rm -f "${MESSAGE_FILE}"
	done

	logger "${FROM}: ${MESSAGE}" # journalctl -xef
EOF
chmod +x /home/marius/process_sms.sh

cat <<- EOF | sudo tee /etc/gammu-smsdrc >/dev/null
	[gammu]
	port = /dev/sms-proxy
	connection = at19200

	[smsd]
	RunOnReceive = /home/marius/process_sms.sh
	service = files
	logfile = syslog
	debuglevel = 0

	inboxpath = /var/spool/gammu/inbox/
	outboxpath = /var/spool/gammu/outbox/
	sentsmspath = /var/spool/gammu/sent/
	errorsmspath = /var/spool/gammu/error/
EOF

sudo systemctl reload gammu-smsd

sudo reboot