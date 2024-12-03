#!/bin/sh

threshold=10 # threshold percentage to trigger suspend

# Use `awk` to capture `acpi`'s percent capacity ($2) and status ($3) fields
# and read their values into the `status` and `capacity` variables
acpi -b | awk -F'[,:%]' '{print $2, $3}' | {
  read -r status capacity   
  echo $status $capacity

  # If battery is discharging with capacity below threshold
  if [ "${status}" = Discharging -a "${capacity}" -lt ${threshold} ];
  then
    systemctl suspend
  fi
}
