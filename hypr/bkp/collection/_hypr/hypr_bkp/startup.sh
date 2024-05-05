#to start the bar
~/.config/waybar/launch.sh & #primary
# ~/.config/waybar_min/launch.sh & #minimal
# ~/.config/waybar_/launch.sh &
#waybar &

#wlsunset for nightlight
wlsunset &

#to start the notification system
dunst &
#to start the bluetooth
blueman-applet &
blueman-tray &
#to set the wallpaper
~/bg.sh &
#to start the polkit agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
#to enable the network manager applet
nm-applet &

#for the kde-connect
~/phone.sh &
kdeconnect-indicator &

#batt
slimbookbattery &

~/.config/hypr/scripts/wrappedhl.sh
