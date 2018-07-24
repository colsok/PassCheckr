#/bin/bash
#
# Combo Checkr v1.1
# 
# Kyle Colson - colsok
# Last Updated: July 24, 2018
# 
# Syntax: ./combo-checkr.sh <combo list>
#
# ##############################################
# 
# Reads combo list, tests passwords, creates new combo list with updated valid passwords. 
# 
################################################
################################################

SERVER_IP=$(cat config.txt | grep SERVER_IP | cut -f 2 -d "=")

if [ "$SERVER_IP" == "1.1.1.1" ];then
                echo "IP Address is default.. have you updated config.txt?"
                echo "Quitting"
                exit
fi


if [ "$#" -ne 1 ];then
		echo "Combo list missing."
		echo "Syntax:"
		echo "./combo-checkr.sh <combo list>"
		exit
fi

INPUT_LIST=$1
DATE=`date +%Y-%m-%d`

## RUN HYDRA ON EACH SPLIT FILE, SLEEP 30 MINUTES
hydra -C $INPUT_LIST $SERVER_IP smb -V -o tmp-combo.out

cat tmp-combo.out | grep password | cut -d" " -f7,11 | sed s/\ /:/ > $DATE-combo.lst
mv *-combo.lst PassCheckr/Reports/
rm tmp-combo.out

echo "Complete!"
