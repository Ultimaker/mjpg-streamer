#!/bin/bash

################################################################################
#
# Upload image using FTP and the tool wput
#
################################################################################

# Configuration ################################################################
USERNAME="username"
PASSWORD="password"
SERVER="server.com"

# if the filename should be constant, just define it here as well
# if subfolders do not exists, wput will create them automatically
SERVERPATH="/path/to/file.jpg"

################################################################################
# check if required tool exists
if ! command -v wput > /dev/null 2>&1; then
  echo "please install the tool wput"
  exit 1
fi

# upload it now
if ! wput --reupload "$1" "ftp://${USERNAME}:${PASSWORD}@${SERVER}${SERVERPATH}"; then
  echo "wput failed"
  exit 1
fi

exit 0
