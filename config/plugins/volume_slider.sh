#!/bin/bash
[ -z "$PERCENTAGE" ] && exit 0
osascript -e "set volume output volume $PERCENTAGE"
