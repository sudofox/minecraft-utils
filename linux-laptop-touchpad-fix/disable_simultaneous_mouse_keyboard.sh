#!/bin/bash

XINPUT_DEV=$(xinput | grep -Po "SynPS/2 Synaptics TouchPad.*id=\K.+?(?=\t)")

OPTION_ID=$(xinput --list-props $XINPUT_DEV | grep -Po "libinput Disable\ While\ Typing\ Enabled\ \(\K.+?(?=\))")

xinput --set-prop $XINPUT_DEV $OPTION_ID 1

echo "Updated Option ID $OPTION_ID of device $XINPUT_DEV to 1 (true). You can no longer move the mouse and type at the same time"
