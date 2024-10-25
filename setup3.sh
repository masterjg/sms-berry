#!/bin/bash

# sudo apt install gammu gammu-smsd -y

# cat <<- EOF | sudo tee /root/.gammurc >/dev/null
# 	[gammu]

# 	port = /dev/sms-proxy
# 	model = 
# 	connection = at19200
# 	synchronizetime = yes
# 	logfile = 
# 	logformat = nothing
# 	use_locking = 
# 	gammuloc = 
# EOF

sudo apt install gammu-smsd -y

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