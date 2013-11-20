#!/bin/bash
# fargen-pom.sh

pomodoro_timer=25
break_timer=5
set_timer=30
db="$HOME/.config/fargenpom/db"

mkdir -p ~/.config/fargenpom

if [ -z "$1" ]
then
    echo "** No command given."
    exit 1
elif [ "$1" = "start" ]
then
    clear
    echo "** Starting..."
    echo "** T: $pomodoro_timer minutes" 
    read -p "** G: " goal

    start_unix=$(date -d "+ 1 minute")
    start_str=$(date +%F\ %R -d "$start_unix")
    end_str=$(date +%F\ %R -d "$start_unix + $pomodoro_timer minutes")
    echo "** S: $start_str"
    echo "** E: $end_str"

    # SOUND
    #http://www.unix.com/showpost.php?s=9bc2b8e5a791d32d259d221a61811f14&p=302358739&postcount=6
    (for (( i=$pomodoro_timer; i>0; i--)); do
        sleep 1m &
        printf "** R: $i minutes\r"
        #play -qn synth 0.01 noise A vol 0.01 &
        wait
    done) 
    
    #echo "** Time is up!"
    play -q /var/www/fargen-pom/bell.wav vol 0.25

    INIT=""
    accomplishment=$(whiptail --inputbox "What did you accomplish?" 8 78 $INIT --title "Take a break!" 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    
    if [ $exitstatus = 0 ]
    then
        echo "** D: $accomplishment"
    else
        echo "** Pomodoro canceled."
        exit 0
    fi
     
    echo "** Adding entry to sqlite..."
    # Quick and dirty insert.
    sqlite3 $db <<-EOM
CREATE TABLE IF NOT EXISTS pomodoro(start datetime, end datetime, goal text, accomplishment text, submitted datetime default current_timestamp);
INSERT INTO pomodoro (start, end, goal, accomplishment) VALUES('$start_str','$end_str','$goal','$accomplishment');
EOM

    echo "** Hurray!"

elif [ "$1" = "ls" ]
then
    sqlite3 $db <<-EOM
.mode column
.headers on
SELECT * FROM pomodoro;
EOM

else
    echo "** What to do?"
fi

exit 0

