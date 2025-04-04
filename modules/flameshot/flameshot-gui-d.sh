focusedwindow=$(xdotool getactivewindow)
flameshot gui -c -d "$1"
if [ "$focusedwindow" == "$(xdotool getactivewindow)" ]
then
	xdotool windowfocus "$focusedwindow"
fi
