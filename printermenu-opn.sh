#!/bin/bash 
#
# printermenu-opn.sh
#
# History:
# 07/15/2003 JAM  Revised original script to log to HelpDesk LogFile
#
# 03/31/2004 JAM  Revised 1. Propagate printer changes to RPS Test
#                         2. Added mailinfo function                    
#
# 04/07/2004 JAM  Added check for success before sending new printer 
#                 mail message
#
# 20131112   JMD  Updated script; remove unused models
#
# 20131205   JMD  Modified menu to clean up unused options and group
#                 related tasks.
# 20140402   JMD  Modified for use on RPS print servers
#
#####################################################################
# Use for testing:
LogFile="/var/log/printermenu-opn_log"

# Test print file for HelpDesk:
etpfile="/usr/local/bin/etp.sh"

# Uncomment for production:
# Do we even need this since we are using logrotate?
#logsize=`ls -l $LogFile | awk '{print $5}'`

# Use for testing:
MailList="john.donovan@vanderbilt.edu"
# Uncomment for production:
#MailList="eai-unix@vanderbilt.edu"

# Use for testing:
TestPage="~donovaj1/mytestprint.txt"
# Uncomment for production:
#TestPage="/usr/local/bin/TestPage"

# Do we even need this?
HName=`hostname`

#
#Defineprinter function
#
function defineprinter {
#Add to RPS Prod:
   /usr/sbin/lpadmin -p "$1" -P <model> -o printer-error-policy=retry-job -v socket://<FQDN>:9100 -D "<make-model> -E -L "<location>"
   if [[ $? > 0 ]]
     then read dd?"Press Enter to Continue...."; return 1
     else echo "Queue created on RPS Prod"
     lpstat -p"$2"
   fi

# Add to RPS Test:
   ssh -q rxc01lt-vm /usr/sbin/lpadmin -p "$1" -D "$3" -q "$2" -h "$2" -x 9100 
   if [[ $? > 0 ]]
     then read dd?"Press Enter to Continue...."; return
     else echo "Queue created on RPS Test:"
     ssh rxc01lt-vm lpstat -p"$2"
   fi
   read dd?"Press Enter to Continue...."
   DTS=`date`
   logit "Created $1 printer $2 "
# Uncomment for production:
  echo $LOGNAME" created a "$1" printer with queue name "$pqname" at "$DTS >> "$LogFile"
   echo >> "$LogFile"
}

#
#Logit function
#
function logit {
   ldate=`date` 
   echo $LOGNAME ";" $ldate ";" "$1" >> "$LogFile"
}


#
logit 'Entered Printer Menu'
while true
do

  DTS=`date`
  clear
  echo "User ID: "$LOGNAME
  echo "Date Stamp: "$DTS
  echo "Host System: "$HName
  echo 
  echo "           Create a New Print Queue:"
#  echo "              1. Create a HPLJ4 Print Queue"
  echo "              2. Create a HPLJ4000 Print Queue"
  echo "             20. Create a Lexmark 2490 Encounter Form Print Queue"
  echo " "
  echo "           Troubleshoot a Print Queue:"
  echo "              8. Check Status of a Print Queue"
  echo "              9. Send a Test Print to a Print Queue"
  echo " "
  echo "           Print Queue Maintenance:"
  echo "             10. Enable a Print Queue"
  echo "             11. Disable a Print Queue"
  echo "             12. Remove All Print Jobs From a Print Queue"
  echo "             13. Remove a Single Print Job From a Print Queue"
  echo "             14. Display Print Queue Setup Details on Prod"
#  echo "             17. Locate any Disabled/Down Print Queues"

# Root Level Tasks:
#  if [ "$LOGNAME" = root ] || [ "$LOGNAME" = smithd8 ]
#  if [ "$LOGNAME" = root ]
#    then
      echo "        _________________________________________________"
      echo "           Root Level Tasks:"
      echo "            777. Delete a Print Queue"
      echo "        _________________________________________________"
#  fi
  echo
  echo "             99. Exit"
  echo
  read ans?"       Choice => "
#
#
  if [ "$ans" -eq 20 ]
    then
      echo
      read pqname?"Queue Name to Add => "
      defineprinter lex2490 "$pqname" asc
      if [ "$?" = 0 ]; then
        mailinfo "$pqname" lex2490
      fi
  fi
#
#
  if [ "$ans" -eq 98 ]
    then
      if [ "$LOGNAME" = root ]
        then
          clear
          cat "$LogFile" | pg
          echo;echo
          read we?"Press Enter to Continue...."
      fi
      DTS=`date`
      logit "Displayed The Log File"
#     echo $LOGNAME" displayed the log file at "$DTS >> "$LogFile"
  fi
#
  if [ "$ans" -eq 99 ]
    then
      DTS=`date`
      logit "Exited The Printer Menu System"
#     echo $LOGNAME" exited the printer menu system at "$DTS >> "$LogFile" 
      break
  fi
#
  if [ "$ans" -eq 3 ]
    then
      echo 
      read pqname?"Queue Name to Add => "
      defineprinter ibm2380-2 "$pqname" asc
      if [ "$?" = 0 ]; then
        mailinfo "$pqname" ibm2380-2
      fi
  fi
#
  if [ "$ans" -eq 2 ]
    then
      read pqname?"Queue Name to Add => "
      defineprinter hplj-4000 "$pqname" pcl
      if [ $? = 0 ] ;then 
        echo "Enabling 132 Columns on Print Queue..."
        echo
        changecolumns "$pqname" 132 
        echo
        mailinfo "$pqname" hplj-4000
      fi 
  fi
#
  if [ "$ans" -eq 1 ]
    then
      read pqname?"Queue Name to Add => "
      defineprinter hplj-4 "$pqname" pcl
      if [ $? = 0 ] ;then
        echo "Enabling 132 Columns on Print Queue..."
        echo
        changecolumns "$pqname" 132 
        echo
        mailinfo "$pqname" hplj-4
     fi
  fi
#
  if [ "$ans" -eq 5 ]
    then
      read pqname?"Queue Name to Add => "
      defineprinter hplj-5si "$pqname" pcl
      if [ $? = 0 ] ;then
        echo "Enabling 132 Columns on Print Queue..."
        echo
        changecolumns "$pqname" 132 
        mailinfo "$pqname" hplj-5si
      fi
  fi
#
  if [ "$ans" -eq 4 ]
    then
      read pqname?"Queue Name to Add => "
      defineprinter hplj-4500 "$pqname" pcl
      if [ $? = 0 ] ;then
        echo "Enabling 132 Columns on Print Queue..."
        echo
        changecolumns "$pqname" 132 
        mailinfo "$pqname" hplj-4500
      fi
  fi
#
  if [ "$ans" -eq 6 ]
    then
      read pqname?"Queue Name to Add => "
      defineprinter hplj-8000 "$pqname" pcl
      if [ $? = 0 ] ;then
        echo "Enabling 132 Columns on Print Queue..."
        echo
        changecolumns "$pqname" 132 
        mailinfo "$pqname" hplj-8000
      fi
  fi
#
  if [ "$ans" -eq 777 ]
    then
      read pqname?"Queue Name to Delete => "
# Delete on RPS Prod:
      /usr/sbin/lpadmin -x "$pqname"
# Delete on RPS Test:
      ssh -q rxc01lt-vm -- /usr/sbin/lpadmin -x "$pqname"
      read dd?"Press Enter to Continue...."
      DTS=`date`
      logit "Deleted printer $pqname"
# Uncomment for Production:
  fi
  if [ "$ans" -eq 8 ]
    then
      read pqname?"Queue Name to Check => "
# Check queue on RPS Prod:
      echo "Checking queue on RPS Prod:"
      lpstat -p"$pqname"
      echo
# Check queue on RPS Test:
      echo "Checking queue on RPS Test:"
      ssh -q rxc01lt-vm -- /usr/bin/lpstat -p"$pqname"
      read dd?"Press Enter to Continue...."
      DTS=`date`
      logit "Checked Printer $pqname"
  fi
  if [ "$ans" -eq 9 ]
    then
      read pqname?"Send Test Page to Print Queue => "
      lp -d"$pqname" "$TestPage"
      lpstat -p"$pqname"
      echo
      read dd?"Press Enter to Continue...."
      DTS=`date`
      logit "Sent Test Page To $pqname"
  fi
  if [ "$ans" -eq 10 ]
    then
      read pqname?"Enable Print Queue => "
      /usr/sbin/cupsenable "$pqname"
      echo
      lpstat -p"$pqname"
      echo
      read dd?"Press Enter to Continue...."
      DTS=`date`
      logit "Enabled Print Queue $pqname"
  fi
  if [ "$ans" -eq 11 ]
    then
      read pqname?"Disable Print Queue => "
      /usr/sbin/cupsdisable "$pqname"
      echo
      lpstat -p"$pqname"
      echo
      read dd?"Press Enter to Continue...."
      DTS=`date`
      logit "Disabled Print Queue $pqname"
  fi
  if [ "$ans" -eq 12 ]
    then
      read pqname?"Clear All Print Jobs From Print Queue => "
      /usr/bin/cancel -a "$pqname" 
      lpstat -o"$pqname"
      echo
      read dd?"Press Enter to Continue...."
      DTS=`date`
      logit "Removed All Print Jobs From Print Queue $pqname"
  fi
  if [ "$ans" -eq 13 ]
    then
      read pqname?"Remove a Print Job From Print Queue => "
      lpstat -o"$pqname" 
      echo
      read jobn?"Job Number =>"
      /usr/bin/cancel "$jobn" 
      echo
      lpstat -o"$pqname"
      echo
      read dd?"Press Enter to Continue...."
      DTS=`date`
      logit "Removed Print Job $jobn From Print Queue $pqname"
  fi
  if [ "$ans" -eq 0 ]
    then
      echo
      read pqname?"Queue Name to Add => "
      defineprinter lex2380-3 "$pqname" asc
      if [ "$?" = 0 ]; then
        mailinfo "$pqname" ibm2380-3
      fi
  fi
#
  if [ "$ans" -eq 14 ]
    then
      echo
      clear
      read pqname?"Print Queue Name => "
      echo;echo
      echo "Column Information [%IwX = Default of 80]:"
      lsvirprt -dhp@$pqname -q$pqname -a w | grep COL | awk '{print "Columns Per Page => "$5}'
      echo
      echo
      echo "Row Informations [%IwY = Default of 60]:"
      lsvirprt -dhp@$pqname -q$pqname -a l | grep LIN | awk '{print "Rows Per Page => "$5}'
      echo
      echo
      echo "Page Setup [! = Portrait and + = Landscape]:"
      lsvirprt -dhp@$pqname -q$pqname -a z | grep ORI | awk '{print "Printer Orientation => "$4}'
      echo
      echo
      echo "Printer Description:"
      lprdes=`lsvirprt -dhp@$pqname -q$pqname -a mL`
      echo $lprdes | cut -c47-
      echo
      echo
      echo "Host File Contains:"
      grep $pqname /etc/hosts 
      echo
      echo;echo
      read dd?"Press Enter to Continue...."
      DTS=`date`
      logit "Displayed Setup Info For Queue $pqname"
  fi
# Do we need this?
  if [ "$ans" -eq 17 ]
    then
      clear
      lpstat | grep DOWN
      echo
      read etp?"Enable These Printers (Y/N)?"
      if [ "$etp" = y ]
        then
          lpstat | grep DOWN | awk '{print "enable "$1}' > "$etpfile"
          chmod 700 "$etpfile"
          "$etpfile"
          clear
          echo "Enable Command Issued to DOWN State Printers"
          echo
          echo "Status is now:"
          lpstat | grep DOWN 
      fi
      if [ "$etp" = Y ]
        then
          lpstat | grep DOWN | awk '{print "enable "$1}' > "$etpfile"
          chmod 700 "$etpfile"
          "$etpfile"
          clear
          echo "Enable Command Issued to DOWN State Printers"
          echo
          echo "Status is now:"
          lpstat | grep DOWN
      fi  
      echo
      echo
      read fdr?"Press Enter to Continue...."
      DTS=`date`
      etplist=`cat "$etpfile" | awk '{print $2}'`
      logit "Enabled print queue(s) $etplist"
# Uncomment for Production:
#     echo $LOGNAME" Enabled the following print queues(s)  "$etplist" at "$DTS >> "$LogFile"
      echo >> "$LogFile"
  fi


done  
