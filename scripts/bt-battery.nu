#!/usr/bin/env nu

# --- Configuration ---
let HEADPHONE_ICON = ""

# --- Main Logic ---

# 1. Check if bluetoothctl command exists
let bt_available = (which bluetoothctl | is-not-empty)

if not $bt_available {
    print $"($HEADPHONE_ICON)  Disconnected"
    exit 0
}

# 2. Check if Bluetooth is powered on.
#    If not, print the disconnected message and exit immediately.
let is_powered = try {
    (^bluetoothctl show | lines | find "Powered: yes" | is-not-empty)
} catch {
    false
}

if not $is_powered {
    print $"($HEADPHONE_ICON)  Disconnected"
    exit 0
}

# 3. If powered on, check if a device is connected.
#    Get the line of the first connected device.
let device_line = try {
    (^bluetoothctl devices Connected | lines | find -r '^Device' | first)
} catch {
    ""
}

# 4. If no device line was found, print the disconnected message and exit.
if ($device_line | is-empty) {
    print $"($HEADPHONE_ICON)  Disconnected"
    exit 0
}

# 5. If we are here, a device IS connected. Extract its info.
let parts = ($device_line | split row ' ')
let blu_connected_mac = ($parts | get 1)
let blu_connected_name = ($parts | skip 2 | str join ' ')

# 6. Get the battery level using bluetoothctl info command.
let dev_battery = try {
    let info_output = (^bluetoothctl info $blu_connected_mac | lines)
    let battery_line = ($info_output | find "Battery Percentage" | first)
    if ($battery_line | is-empty) {
        ""
    } else {
        ($battery_line | parse -r '\((\d+)\)' | get 0.capture0)
    }
} catch {
    ""
}

# 7. Format and print the final "Connected" output.
if ($dev_battery | is-not-empty) {
    # Battery percentage is available
    print $"($HEADPHONE_ICON)  ($dev_battery)% ($blu_connected_name)"
} else {
    # No battery percentage, just show the device name
    print $"($HEADPHONE_ICON)  ($blu_connected_name)"
}
