focusedwindow=$(xdotool getactivewindow)
flameshot gui -c
if [ "$focusedwindow" == "$(xdotool getactivewindow)" ]
then
	xdotool windowfocus "$focusedwindow"
fi
