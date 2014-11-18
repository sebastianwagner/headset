#!/bin/bash


Sennheiser=`basename $0`

USAGE=$(cat <<USAGE
 #
 # mkmageext.sh
 # @author 2000sw@gmail.com
 # @see https://unix.stackexchange.com/a/67398
 #
 $Sennheiser application [application]
USAGE
)

if [ -z "$1" ]; then
    echo "$USAGE"
    exit 1
fi

DEFAULT_SINKEXPRESSION="Sennheiser"
FILTER_APPLICATION="$1"

#todo allow toggling
#echo "looking for $FILTER_APPLICATION"

# get sink id
SINK=$(pactl list short sinks | grep "$DEFAULT_SINKEXPRESSION" | head -n 1| cut '-d	' -f1)

# #pactl list sink-inputs | grep -oP '(?<=Sink Input #|application.process.binary = ")[^"]*'
# read streamid per application
pactl list sink-inputs | grep -oP '(?<=Sink Input #|application.process.id = "|application.process.binary = "|Sink: )[^"]*' | while read STREAMID; do
 read OLDSINK
 read PID
 read APPLICATION
 if [ -z "$APPLICATION" ]; then
    echo "no application for stream $STREAMID"
    exit 1
 fi
 if [ "$APPLICATION" == "$FILTER_APPLICATION" -a "$SINK" != "$OLDSINK" ]; then
  echo "switching stream $STREAMID($APPLICATION pid $PID) to sink $SINK(now $DEFAULT_SINKEXPRESSION was $OLDSINK)"
  pactl move-sink-input "$STREAMID" "$SINK"
 else
  echo "ignoring stream $STREAMID($APPLICATION pid $PID) from $SINK($DEFAULT_SINKEXPRESSION)"
 fi
done
