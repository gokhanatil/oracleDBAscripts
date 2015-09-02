#!/bin/sh

# SSO username and password
SSO_USERNAME=YOUREMAIL@YOURDOMAIN.COM
SSO_PASSWORD=YOURPASSWORD

# Path + options to wget command
WGET="/usr/bin/wget --secure-protocol=TLSv1"

# Location of cookie file
COOKIE_FILE=/tmp/$$.cookies

# Log file
LOGFILE=downloadem12c.log

# Contact updates site so that we can get SSO Params for logging in
SSO_RESPONSE=`$WGET --user-agent="Mozilla/5.0" "https://updates.oracle.com/Orion/Services/download" 2>&1|grep Location`

rm -f download

# Extract request parameters for SSO
SSO_TOKEN=`echo $SSO_RESPONSE| cut -d '=' -f 2|cut -d ' ' -f 1`
SSO_SERVER=`echo $SSO_RESPONSE| cut -d ' ' -f 2|cut -d 'p' -f 1,2`
SSO_AUTH_URL=sso/auth
AUTH_DATA="ssousername=$SSO_USERNAME&password=$SSO_PASSWORD&site2pstoretoken=$SSO_TOKEN"

# Login to Oracle Using SSO
$WGET --user-agent="Mozilla/5.0" --post-data $AUTH_DATA --save-cookies=$COOKIE_FILE --keep-session-cookies $SSO_SERVER$SSO_AUTH_URL -O sso.out >> $LOGFILE 2>&1

# Set Cookie to Accept License Agreement
echo ".oracle.com       TRUE    /       FALSE   0       oraclelicense   accept-gridcontrol_linx8664-cookie"     >> $COOKIE_FILE

rm -f sso.out

echo "Downloading em12105_linux64_disk1.zip"
$WGET --user-agent="Mozilla/5.0" --load-cookies=$COOKIE_FILE --save-cookies=$COOKIE_FILE --keep-session-cookies "http://download.oracle.com/otn/linux/oem/12105/em12105_linux64_disk1.zip" >> $LOGFILE 2>&1
echo "Downloading em12105_linux64_disk2.zip"
$WGET --user-agent="Mozilla/5.0" --load-cookies=$COOKIE_FILE --save-cookies=$COOKIE_FILE --keep-session-cookies "http://download.oracle.com/otn/linux/oem/12105/em12105_linux64_disk2.zip" >> $LOGFILE 2>&1
echo "Downloading em12105_linux64_disk3.zip"
$WGET --user-agent="Mozilla/5.0" --load-cookies=$COOKIE_FILE --save-cookies=$COOKIE_FILE --keep-session-cookies "http://download.oracle.com/otn/linux/oem/12105/em12105_linux64_disk3.zip" >> $LOGFILE 2>&1
