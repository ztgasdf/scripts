#!/bin/bash
# zsup - very flimsy zippyshare uploader
# requirements: curl
#
# usage: ./zsup.sh <file> [file2...]

for i
do
UPLOADURL=$(curl -s https://zippyshare.com | grep '"post" name="upload' | cut -f12 -d\" | sed 's/http/https/g')
SERVER=$(echo "${UPLOADURL}" | cut -d. -f1 | sed 's/https:\/\///g')
curl "${UPLOADURL}" -F file="@${i}" -F private=true | grep "${SERVER}" | head -3 | tail -1
done