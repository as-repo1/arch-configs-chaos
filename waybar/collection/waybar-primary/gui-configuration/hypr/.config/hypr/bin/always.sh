#!/usr/bin/env bash

# This script is a continues running service on a time gap of 1 sec

if on_ac_power; then
	runAC=true
	runBAT=false
else
	runAC=false
	runBAT=true
fi

is_gif=false
[ -f "$HOME/.cache/setwal/is_gif" ] && is_gif="$(cat "$HOME/.cache/setwal/is_gif")"

check() {
	command -v "$1" &>/dev/null
}

notify() {
	check notify-send || {
		echo "$@"
		return
	}
	notify-send "$@"
}

play_aud() {
	exec mpv --no-video --no-terminal --really-quiet /usr/share/sounds/freedesktop/stereo/device-added.oga
}

power_run=true

AC_once() {
	runAC=false # Setting the flag that AC_once has been run
	runBAT=true # Setting the flag that BAT_once has to run
	$is_gif && {
		[ -f "$HOME/bin/setwal" ] && {
			"$HOME/bin/setwal" -l
			notify "Switching to gif mode"
		}
	}
	"$HOME/.config/waybar/bin/battsaver-toggle" normal
	play_aud &
}

BAT_once() {
	runAC=true   # Setting the flag that AC_once has to run
	runBAT=false # Setting the flag that BAT_once has been run
	$is_gif && {
		[ -f "$HOME/bin/setwal" ] && {
			"$HOME/bin/setwal" -S
			notify "Switching to static wallpaper"
		}
	}
	if [[ "$class" != "normal" ]]; then
		"$HOME/.config/waybar/bin/battsaver-toggle" normal
		play_aud &
	fi
}

AC() {
	# always invoked on ac

	class="$($HOME/.config/waybar/bin/battsaver-toggle getdata | jq -r '.class')"
	local perf=false

	pgrep -x heroic && perf=true
	pgrep -x lutris && perf=true
	pgrep -x steam && perf=true

	if $perf; then
		if [[ "$class" != "performance" ]]; then
			"$HOME/.config/waybar/bin/battsaver-toggle" performance
			play_aud &
		fi
	else
		if [[ "$class" != "normal" ]]; then
			"$HOME/.config/waybar/bin/battsaver-toggle" normal
			play_aud &
		fi
	fi

}

BAT() {
	# always invoked on bat
	[ -f "$HOME/.cache/setwal/curr_is_gif" ] && is_curr_gif="$(cat "$HOME/.cache/setwal/curr_is_gif")" || return
	$is_curr_gif && {
		setwal -S
	}

}

power() {
	check jq || {
		notify "jq is not installed"
		power_run=false
		return
	}

	check on_ac_power || {
		notify "on_ac_power is not installed"
		power_run=false
		return
	}

	if on_ac_power; then
		AC
		$runAC && AC_once
	else
		BAT
		$runBAT && BAT_once
	fi

}

game() {
	pgrep -x gamemoded || return
	pgrep -x heroic || {
		killall gamemoded
	}
}

kde() {
	check kdeconnect-cli && {
		pgrep -x kdeconnectd >/dev/null || setsid /usr/lib/kdeconnectd &>/dev/null
		pgrep -x kdeconnect-indi >/dev/null || setsid kdeconnect-indicator &>/dev/null
	}
}

while true; do
	$power_run && power
	kde
	game
	sleep 1
done
