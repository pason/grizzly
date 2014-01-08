#!/bin/bash
#
# Author: Mykola Bespaliuk
# Goes through authentication on Pivotal Tracker.
# After the script has finished you can make curl requests using obtained cookies.
#
# Usage: ./login username@example.com secret

USAGE="Usage: ./login username@example.com secret"

if [[ $# -ne 2 ]]; then
    echo "Wrong arguments number"
    echo $USAGE
    exit 1
fi;

USERNAME=$1
PASSWORD=$2
USER_AGENT="Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.22 (KHTML, like Gecko) Ubuntu Chromium/25.0.1364.160 Chrome/25.0.1364.160 Safari/537.22"
SIGNIN_URL="https://www.pivotaltracker.com/signin"
OUT_FILE="/tmp/loginresult.html"

curl --silent --cookie-jar cjar --user-agent "$USER_AGENT" --output $OUT_FILE $SIGNIN_URL

# first get line with authenticity_token that corresponds to /signin action, than retrieve the token from it
AUTH_TOKEN=$(grep "action=\"/signin.*authenticity_token.*div>" $OUT_FILE | sed s/'.*value="\([^"]\+\)".*'/'\1'/)
TZ_OFFSET="+2"

# echo "Got authenticity_token: $AUTH_TOKEN"

curl --silent --cookie cjar --cookie-jar cjar --user-agent "$USER_AGENT" \
--data "credentials[username]=$USERNAME" \
--data "credentials[password]=$PASSWORD" \
--data "time_zone_offset=$TZ_OFFSET" \
--data "authenticity_token=$AUTH_TOKEN" \
--location \
--output $OUT_FILE $SIGNIN_URL