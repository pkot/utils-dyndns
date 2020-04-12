#/bin/sh

URL=https://api.ipify.org
DATE=`date "+%Y%m%d"`
SEARCH_DIR=.

# 1. Check current IP
IP=`curl -s $URL`
if [ $? -ne 0 ]
then
	exit 1
fi
# 2. Verify if IP has changed
if [ -s ip.txt ] && [ "$IP" = `cat ip.txt` ]
then
	exit 0
fi
# 3. Increase serial number
if [ -s date.txt ] && [ "$DATE" != `cat date.txt` ]
then
	echo $DATE > date.txt
	SEQ=1
else
	if [ -s serial.txt ]
	then
		SEQ=`cat serial.txt`
	else
		SEQ=0
	fi
	SEQ=$((SEQ+1))
fi

echo $IP > ip.txt
echo $SEQ > serial.txt
echo $DATE > date.txt

for entry in "$SEARCH_DIR"/*
do
	if [ -d "$entry" ]
	then
		cd $entry
		source ./.config
		echo $TMPl
		cat $TMPL | sed s/%SERIAL%/$DATE`printf "%02g" $SEQ`/g | sed s/%IP%/$IP/g > $OUTFILE
		scp $SCP_PARAMS $OUTFILE $SSH_SRV:$DESTFILE
		ssh $SSH_PARAMS $SSH_SRV "$SSH_CMD"
		cd ..
	fi
done
