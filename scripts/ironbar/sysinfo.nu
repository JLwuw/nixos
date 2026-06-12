#!/usr/bin/env nu
# @reference: modules/features/ironbar.nix
# System info widget: CPU usage, memory, temperature, and battery (if present)

# CPU usage (delta from last run)
let cpu_state_file = "/tmp/.cpu_stat_prev"

let cpu_stats = (open /proc/stat | lines | first | split row ' ' | skip 1 | filter {|x| $x != ""} | each {|x| $x | into int})
let total = ($cpu_stats | math sum)
let idle = ($cpu_stats | get 3)
let used = ($total - $idle)

let cpu_pct = if ($cpu_state_file | path exists) {
    let prev = (open $cpu_state_file | split row ' ' | each {|x| $x | into int})
    let prev_total = ($prev | get 0)
    let prev_used = ($prev | get 1)
    let dt = ($total - $prev_total)
    let du = ($used - $prev_used)
    if $dt > 0 { (100 * $du / $dt | into int) } else { 0 }
} else {
    0
}

$"($total) ($used)" | save -f $cpu_state_file

# Memory usage
let mem_total = (open /proc/meminfo | lines | find "MemTotal" | first | split row ' ' | filter {|x| $x != ""} | get 1 | into int)
let mem_avail = (open /proc/meminfo | lines | find "MemAvailable" | first | split row ' ' | filter {|x| $x != ""} | get 1 | into int)
let mem_used = ($mem_total - $mem_avail)
let mem_pct = ($mem_used * 100 / $mem_total | into int)

# Temperature
let temp_c = if ("/sys/class/thermal/thermal_zone0/temp" | path exists) {
    ((open /sys/class/thermal/thermal_zone0/temp | into int) / 1000 | into int)
} else {
    0
}

# Battery (laptop only)
let battery_info = try {
    let upower_dev = (^upower -e | lines | find -r 'BAT|battery' | first | ansi strip)
    if ($upower_dev | is-empty) {
        null
    } else {
        let info = (^upower -i $upower_dev | lines)
        let state = ($info | find "state" | first | ansi strip | split row ':' | get 1 | str trim)
        let pct_line = ($info | find "percentage" | first | ansi strip | split row ':' | get 1 | str trim | str replace '%' '')
        let pct = ($pct_line | into int)
        {state: $state, pct: $pct}
    }
} catch {
    null
}

# Output
if ($battery_info | is-empty) {
    print $"󰍛 ($cpu_pct)% 󰾆 ($mem_pct)% 󰔏 ($temp_c)°C"
} else {
    let bat_icon = if $battery_info.state == "charging" {
        "󰂄"
    } else if $battery_info.state == "fully-charged" or $battery_info.state == "not charging" {
        "󰁹"
    } else if $battery_info.pct >= 90 {
        "󰂂"
    } else if $battery_info.pct >= 80 {
        "󰂁"
    } else if $battery_info.pct >= 70 {
        "󰂀"
    } else if $battery_info.pct >= 60 {
        "󰁿"
    } else if $battery_info.pct >= 50 {
        "󰁾"
    } else if $battery_info.pct >= 40 {
        "󰁽"
    } else if $battery_info.pct >= 30 {
        "󰁼"
    } else if $battery_info.pct >= 20 {
        "󰁻"
    } else if $battery_info.pct >= 10 {
        "󰁺"
    } else {
        "󰂃"
    }
    print $"󰍛 ($cpu_pct)% 󰾆 ($mem_pct)% 󰔏 ($temp_c)°C ($bat_icon) ($battery_info.pct)%"
}
