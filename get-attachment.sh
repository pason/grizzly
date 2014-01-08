
#!/bin/bash
#
# Author: Mykola Bespaliuk
# Fetches attachment by ID into a file
# Usage: ./get-attachment.sh 12345 /path/to/output/file

USAGE="Usage: ./get-attachment.sh 12345 /path/to/output/file"

if [[ $# -ne 2 ]]; then
    echo "Wrong arguments number"
    echo $USAGE
    exit 1
fi

if [ ! -f cjar ]; then
    echo "Cookies file not found. Run ./login first"
    exit 1
fi

BASE_URL="https://www.pivotaltracker.com/resource/download/"
ATT_ID=$1
OUT_FILE=$2

curl --silent --cookie cjar --cookie-jar cjar --output $OUT_FILE "$BASE_URL$ATT_ID"

