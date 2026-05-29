#!/usr/bin/env nu

let status = (^volumectl get)

let result = if ($status | str contains -i "muted") {
    {icon: "󰝟", vol: "0%"}
} else {
    let vol_num = ($status | parse -r '(\d+)' | get 0.capture0 | into int)
    let vol = $"($vol_num)%"
    let icon = if $vol_num > 66 {
        "󰕾"
    } else if $vol_num > 33 {
        "󰖀"
    } else {
        "󰕿"
    }
    {icon: $icon, vol: $vol}
}

print $"($result.icon) ($result.vol)"
