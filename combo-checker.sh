#/bin/bash
#
# Combo Checkr v1.0
# 
# Kyle Colson - colsok
# Last Updated: May 15, 2018
# 
# Syntax: ./combo-checkr.sh <combo list>
#
# ##############################################
# 
# Reads combo list, tests passwords, creates new combo list with updated valid passwords. 
# 
################################################
################################################

# EDIT BELOW CONFIGURATION PER YOUR ORGANIZAION

SERVER_IP=10.1.1.1	#IP Address of your AD Domain Controller

################################################
### NO EDITS BELOW THIS LINE NECESSARY
################################################

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
