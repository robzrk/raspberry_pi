#!/bin/bash
LOG_EMAIL=/tmp/log_email
LOGS="/tmp/launcher.log
/tmp/post_update_setup.log
/tmp/get_location.log
/tmp/get_timezone.log
/tmp/check_email.log
/tmp/read_email.log
/tmp/pi_ui.log
"

GROUP=`cat ~/my_group`
if [ "$GROUP" == "" ]; then
    GROUP="unknown"
fi

echo "Subject: Debug log for $GROUP" > $LOG_EMAIL
for LOG in $LOGS; do
    echo "******************************************************" >> $LOG_EMAIL
    echo "**** $LOG ****" >> $LOG_EMAIL
    echo "******************************************************" >> $LOG_EMAIL
    tail -n 10 $LOG >> $LOG_EMAIL
    echo "" >> $LOG_EMAIL
    echo "" >> $LOG_EMAIL
done

#sendmail sendittopi@gmail.com < $LOG_EMAIL
mail -s "`date`: $GROUP log" sendittopi@gmail.com < $LOG_EMAIL
