#!/bin/bash

export SELF_NAME=$(basename -s .sh $0)
export DIR_NAME=$(dirname $0)
export CTL_TO_HDL="$DIR_NAME/$SELF_NAME.to.pipe"
export CTL_FROM_HDL="$DIR_NAME/$SELF_NAME.from.pipe"

exit_main() {
    for _a_pid in $ASYNC_PID
    do
        ps -p $_a_pid &>/dev/null && kill -TERM $_a_pid
    done

    [ -p "$CTL_TO_HDL" ] && echo "end" > $CTL_TO_HDL
    [ -p "$CTL_FROM_HDL" ] && read -t 2 -u 6 _res
    exec 6>&-
    echo "Main: $_res"

    rm -f $CTL_TO_HDL $CTL_FROM_HDL &>/dev/null
    ps -p $PIPE_HDL_PID &>/dev/null && { echo "Killing $PIPE_HDL_PID"; kill $PIPE_HDL_PID &>/dev/null; }
}

trap 'exit_main' EXIT

[ -p "$CTL_TO_HDL" ] && rm -f $CTL_TO_HDL
[ -p "$CTL_FROM_HDL" ] && rm -f $CTL_FROM_HDL
mkfifo -m 600 $CTL_TO_HDL
mkfifo -m 600 $CTL_FROM_HDL
exec 6<>$CTL_FROM_HDL

echo -n "Exposing pipe handler: "
(
    trap '' INT

    declare -a _rc
    _rc=(); i=0

    [ -p "$CTL_TO_HDL" ] && exec 4<>$CTL_TO_HDL
    while true
    do
        read -u 4 _line
        if [ "$_line" = "end" ]
        then
            echo "${_rc[*]}" > $CTL_FROM_HDL
            exec 4>&-
            exit
        fi
        _rc[$((i++))]="$_line"
    done
)&
export PIPE_HDL_PID=$!
echo $PIPE_HDL_PID

echo "Start async processes..."
(trap '' INT; sleep 1; echo "$BASHPID: exit with 1"; false; echo "$BASHPID:$?" > $CTL_TO_HDL)& ASYNC_PID="$ASYNC_PID $!"
(trap '' INT; sleep 4; echo "$BASHPID: exit with 0"; true; echo "$BASHPID:$?" > $CTL_TO_HDL)& ASYNC_PID="$ASYNC_PID $!"
(trap '' INT; sleep 8; echo "$BASHPID: exit with 0"; true; echo "$BASHPID:$?" > $CTL_TO_HDL)& ASYNC_PID="$ASYNC_PID $!"
(trap '' INT; sleep 7; echo "$BASHPID: exit with 0"; true; echo "$BASHPID:$?" > $CTL_TO_HDL)& ASYNC_PID="$ASYNC_PID $!"
(trap '' INT; sleep 7; echo "$BASHPID: exit with 1"; false; echo "$BASHPID:$?" > $CTL_TO_HDL)& ASYNC_PID="$ASYNC_PID $!"
(trap '' INT; sleep 2; echo "$BASHPID: exit with 1"; false; echo "$BASHPID:$?" > $CTL_TO_HDL)& ASYNC_PID="$ASYNC_PID $!"
(trap '' INT; sleep 2; echo "$BASHPID: exit with 0"; true; echo "$BASHPID:$?" > $CTL_TO_HDL)& ASYNC_PID="$ASYNC_PID $!"

echo "Waiting for: $ASYNC_PID "
while [ -n "$ASYNC_PID" ]
do
    for _a_pid in $ASYNC_PID
    do
        ps -p $_a_pid &>/dev/null || ASYNC_PID=$(sed "s/$_a_pid//;s/^[[:space:]]*//;s/[[:space:]]*$//" <<< $ASYNC_PID)
    done
done
echo ""
