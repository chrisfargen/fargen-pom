#!/bin/bash
# fargen-pom.sh

pomodoro_timer=25
break_timer=5
set_timer=30
time_up_cmd=$(echo "Time is up!")

if [ -z "$1" ]
then
    echo "** No command given."
    exit 1
elif [ "$1" = "new" ]
then
    clear
    echo "** Starting..."
    echo "** You have $pomodoro_timer minutes." 
    echo "** What is your goal?"
    read goal

    start_unix=$(date)
    start_str=$(date +%F\ %R -d "$start_unix")
    end_str=$(date +%F\ %R -d "$start_unix + $pomodoro_timer minutes")
    echo -e "** START:\t$start_str"
    echo -e "** END:  \t$end_str"

    #http://www.unix.com/showpost.php?s=9bc2b8e5a791d32d259d221a61811f14&p=302358739&postcount=6
    (for (( i=60*$pomodoro_timer; i>0; i--)); do
        sleep 1 &
        printf "** REMAINING:\t$i \r"
        play -qn synth 0.01 noise A vol 0.002 &
        wait
    done) 
    
    echo "** TIME IS UP!"
    play -q /var/www/fargen-pom/bell.wav

    echo "** What did you accomplish?"
    read accomplishment

    echo "** Adding entry to sqlite..."
    # Quick and dirty insert.
    sqlite3 fargenpom <<-EOM
CREATE TABLE IF NOT EXISTS pomodoro(start datetime, end datetime, goal text, accomplishment text, submitted datetime default current_timestamp);
INSERT INTO pomodoro (start, end, goal, accomplishment) VALUES('$start_str','$end_str','$goal','$accomplishment');
EOM

    echo "Hurray!"

elif [ "$1" = "ls" ]
then
    sqlite3 fargenpom <<-EOM
.mode column
.headers on
SELECT * FROM pomodoro;
EOM

else
    echo "** What to do?"
fi

exit 0
