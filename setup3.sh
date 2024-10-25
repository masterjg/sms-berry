#!/bin/bash

sudo apt install gammu -y

cat <<- EOF > ~/.gammurc
	[gammu]
	connection = at
	device = /dev/sms-proxy
	synchronizetime = yes
	logfile = syslog
	logformat = textalldate
EOF

gammu identify

sudo apt install gammu-smsd -y

cat <<- 'EOF' > ~/process_sms.sh
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
chmod +x ~/process_sms.sh

cat <<- EOF | sudo tee /etc/gammu-smsdrc >/dev/null
	[gammu]
	connection = at
	device = /dev/sms-proxy
	synchronizetime = yes
	logformat = textalldate

	[smsd]
	service = files
	logfile = syslog
	debuglevel = 1
	statusfrequency = 0
	checksecurity = 0
	hangupcalls = 1
	checkbattery = 0
	checksignal = 0
	checknetwork = 0
	deliveryreport = log
	deliveryreportdelay = 7200
	runonreceive = /home/${USER}/process_sms.sh
	excludenumbersfile = 
	inboxpath = /var/spool/gammu/inbox/
	outboxpath = /var/spool/gammu/outbox/
	sentsmspath = /var/spool/gammu/sent/
	errorsmspath = /var/spool/gammu/error/
	outboxformat = unicode
	transmitformat = unicode
EOF

sudo systemctl enable --now gammu-smsd

sudo reboot