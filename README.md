# PassCheckr
Simple script designed to try "easy" passwords against
your active directory users. There are two password lists
that will be used: 
 1. Common - i.e., Password123
 2. Custom - unique to your organization, 

In addition, current month/year combinations meeting 
complexity requirements will be included, for example: 
 april2018!  April2018  etc.


This script is basically a Hydra wrapper designed to 
not trip Active Directory lockout policies. By default, 
it'll try three attempts per user, for every user in the
input list, and then sleep for thirty minutes. Inside the 
script, you will need to set IP Address. The number of 
attempts per user, and how long to sleep before repeat 
are also edible at the top of the script.

******************************************************

Setup:
Inside the passcheckr.sh script, there are three 
hardcoded variables that need to be set:
 1. IP Address - AD Server to attack
 2. Attempts - number of tries per account, before sleep
 2. Sleep - how long to sleep before repeating attack


Execution is simple:
`./passcheckr.sh <userlist>`


NOTE:

This script was tested using Hydra v8.6 on Kali Linux.
Since this is a low & slow attack, it is best to run
this script in a separate screen session or similar 
environment.


#######################################################
#######################################################
# Hydra Commands
#######################################################

#SINGLE USER AND SINGLE PASSWORD
`hydra -l <username> -p <password> <IP_address of DC> smb`

#USER AND PASSWORD LIST
`hydra -L <list> -P <list> <IP ADDR> smb`

#COMBO LIST
`hydra -C <list> <IP> smb `

#NOTES 
'-V'  Show each attempt
'-o'  OUTPUT FILE

#EXAMPLE
`hydra -L users/all.lst -P passwords.txt 10.1.1.1 smb -V -o results.out`

########################################################
########################################################
# Powershell commands
########################################################

#List all LockedOut users
`Search-ADAccount -LockedOut | select name,SamAccountName`

#SETUP ACCOUNTS
#Export all enabled 
`PS> Get-ADUser -Filter 'enabled -eq $true' | select SamAccountName | export-csv <file>.csv`
