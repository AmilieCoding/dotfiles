#!/bin/bash
VOLUME=$(pamixer --get-volume-human)
ICON="🔉"

if pamixer --get-mute | grep -q true; then
    ICON="🔇"
fi

echo "$ICON $VOLUME"
