#!/bin/sh

threshold=10 # threshold percentage to trigger suspend

# There's grep because mouse battery can also be there.
# Mouse battery does not have 'remaining/until' info and I exploit it.
acpi -b | grep 'remaining\|until' | awk -F'[,:%]' '{print $2, $3}' | {
  read -r status capacity   
  echo $status $capacity

  # If battery is discharging with capacity below threshold
  if [ "${status}" = Discharging -a "${capacity}" -lt ${threshold} ];
  then
    systemctl suspend
  fi
}
