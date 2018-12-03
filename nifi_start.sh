#!/bin/bash
export JAVA_HOME=/usr/jdk64/jdk1.8.0_112/
dir="/home/nifi/nifi-1.8.0.3.3.0.0-165/bin/"
cmd="nifi.sh"
user="nifi"


name="nifi"
pid_file="/home/nifi/nifi-1.8.0.3.3.0.0-165/run/$name.pid"
stdout_log="/home/nifi/nifi-1.8.0.3.3.0.0-165/logs/$name.log"
stderr_log="/home/nifi/nifi-1.8.0.3.3.0.0-165/logs/$name.err"

get_pid() {
    cat "$pid_file"
}

is_running() {
    [ -f "$pid_file" ] && ps -p `get_pid` > /dev/null 2>&1
}

case "$1" in
    start)
    if is_running; then
        echo "Already started"
    else
        echo "Starting $name"
        cd "$dir"
        if [ -z "$user" ]; then
            sudo ./$cmd $1>> "$stdout_log" 2>> "$stderr_log"
        else
            sudo -u "$user" ./$cmd $1>> "$stdout_log" 2>> "$stderr_log"
        fi
        if ! is_running; then
            echo "Unable to start, see $stdout_log and $stderr_log"
            exit 1
        fi
    fi
    ;;
    stop)
    if is_running; then
        echo -n "Stopping $name.."
        cd "$dir"
        if [ -z "$user" ]; then
            sudo ./$cmd $1>> "$stdout_log" 2>> "$stderr_log" &
        else
            sudo -u "$user" ./$cmd $1>> "$stdout_log" 2>> "$stderr_log" &
        fi
        for i in 1 2 3 4 5 6 7 8 9 10
        # for i in `seq 10`
        do
            if ! is_running; then
                break
            fi

            echo -n "."
            sleep 1
        done
        echo

        if is_running; then
            echo "Not stopped; may still be shutting down or shutdown may have failed"
            exit 1
        else
            echo "Stopped"
            if [ -f "$pid_file" ]; then
                rm "$pid_file"
            fi
        fi
    else
        echo "Not running"
    fi
    ;;
    restart)
    $0 stop
    if is_running; then
        echo "Unable to stop, will not attempt to start"
        exit 1
    fi
    $0 start
    ;;
    status)
    if is_running; then
        echo "Running"
    else
        echo "Stopped"
        exit 1
    fi
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0