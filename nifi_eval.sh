#!/bin/bash
name="nifi"
pid_file="/home/nifi/nifi-1.8.0.3.3.0.0-165/run/$name.pid"

get_pid() {
    cat "$pid_file"
}

is_running() {
    [ -f "$pid_file" ] && ps -p `get_pid` > /dev/null 2>&1
}

while[ is_running() ]
do

# Put python code here.

done