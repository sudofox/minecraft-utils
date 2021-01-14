#!/bin/bash

XINPUT_DEV=$(xinput |grep -Po "SynPS/2 Synaptics TouchPad.*id=\K.+?(?=\t)")

OPTION_ID=$(xinput --list-props $XINPUT_DEV|grep -Po "libinput Disable\ While\ Typing\ Enabled\ \(\K.+?(?=\))")

xinput --set-prop $XINPUT_DEV $OPTION_ID 0

echo "Updated Option ID $OPTION_ID of device $XINPUT_DEV to 0 (false). You can now move the mouse and type."
