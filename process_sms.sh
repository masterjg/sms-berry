#!/bin/bash

FROM="${SMS_1_NUMBER}"
MESSAGE=

MESSAGE_FILE_NAMES=("$@")

for MESSAGE_FILE_NAME in "${MESSAGE_FILE_NAMES[@]}"; do
	MESSAGE_FILE="/var/spool/gammu/inbox/${MESSAGE_FILE_NAME}"
	MESSAGE+="$(cat "${MESSAGE_FILE}")"
	rm -f "${MESSAGE_FILE}"
done

logger "${FROM}: ${MESSAGE}"

# journalctl -xef