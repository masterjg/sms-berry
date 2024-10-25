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
	runonreceive = /home/marius/process_sms.sh
	service = files
	logfile = syslog
	debuglevel = 1
	inboxpath = /var/spool/gammu/inbox/
	outboxpath = /var/spool/gammu/outbox/
	sentsmspath = /var/spool/gammu/sent/
	errorsmspath = /var/spool/gammu/error/
	inboxformat = unicode
	outboxformat = unicode
	transmitformat = auto
	deliveryreport = sms
	deliveryreportdelay = 7200
	checksecurity = 0
EOF

# sudo systemctl daemon-reload
# sudo systemctl enable --now gammu-smsd

sudo reboot