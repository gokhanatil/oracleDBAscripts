#!/bin/bash

#---------------------------------------------------------------------
# rmanftp (C) 2013 Gokhan Atil http://www.gokhanatil.com
#---------------------------------------------------------------------

# Required Info to Connect Oracle
. oraenv <<EOF
ORCL
EOF
ORACLE_CREDENTIALS=gokhan/atil

# Required Info to Connect FTP Server
TARGETSERVER=192.168.0.10
FTPUSER=oracle
FTPPASS=oracle
TARGETDIR=DAILY_BACKUP

# Query Latest Backup
SENDFILES=(`$ORACLE_HOME/bin/sqlplus -s $ORACLE_CREDENTIALS @rmanfind.sql`)

COUNT=${#SENDFILES[*]}
IDX=0
SENDTHEMALL=''

while (( $IDX < $COUNT ))
do
LOCALPATH=`echo ${SENDFILES[$IDX]} | sed 's|\(.*\)/.*|\1|'`
FILENAME=`echo ${SENDFILES[$IDX]} | sed 's|.*/\(.*\)|\1|'`
SENDTHEMALL="${SENDTHEMALL}lcd $LOCALPATH\n"
SENDTHEMALL="${SENDTHEMALL}put $FILENAME\n"
IDX=$(($IDX+1))
done

# Convert Newlines to Enters?
FTPCMD=`echo -e $SENDTHEMALL`

# Upload Files
ftp -d -n $TARGETSERVER <<EOF
user $FTPUSER $FTPPASS
cd $TARGETDIR
bin
$FTPCMD
bye
EOF
