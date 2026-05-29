#!/usr/bin/env nu

# Get icon based on device name
def get_icon [name: string] {
    if ($name | str contains -i 'soundcore') or ($name | str contains -i 'Earphones') or ($name | str contains -i 'earphone') or ($name | str contains -i 'R50i') {
        "🎧"
    } else if ($name | str contains -i 'Built-in') or ($name | str contains -i 'Speaker') or ($name | str contains -i 'Analog') {
        "🔊"
    } else {
        "🌀"
    }
}

# Get sinks: skip EasyEffects and junk
def get_sinks [] {
    let status = (^wpctl status | lines)
    let sinks_start = ($status | enumerate | where item =~ 'Sinks:' | get 0.index)
    let sources_start = ($status | enumerate | where item =~ 'Sources:' | get 0.index)

    $status
    | skip ($sinks_start + 1)
    | take ($sources_start - $sinks_start - 1)
    | filter {|line| not ($line | str contains 'Easy Effects Sink')}
    | filter {|line| $line | str contains -r '\d+\.'}
    | each {|line|
        let cleaned = ($line | str replace -ar '[*│]' '' | str trim)
        let parts = ($cleaned | parse -r '(\d+)\.\s+(.+?)\s+\[vol:')
        if ($parts | is-empty) {
            null
        } else {
            {id: ($parts.0.capture0.0), name: ($parts.0.capture1.0 | str trim)}
        }
    }
    | filter {|x| $x != null}
}

# Get current default sink ID
def get_current_sink_id [] {
    let line = (^wpctl status | lines | find 'Default Sink:' | first)
    $line | parse -r 'Default Sink:\s+(\d+)' | get 0.capture0
}

# Get current sink's name
def get_current_sink_name [] {
    let id = (get_current_sink_id)
    let sinks = (get_sinks)
    let sink = ($sinks | where id == $id | first)
    $sink.name
}

# MAIN
def main [action?: string] {
    let sinks = (get_sinks)

    # Only show icon if no argument
    if ($action | is-empty) {
        let current_name = (get_current_sink_name)
        print (get_icon $current_name)
        exit 0
    }

    let current_id = (get_current_sink_id)
    let current_index = ($sinks | enumerate | where item.id == $current_id | get 0.index)

    # Compute new index
    let next_index = if $action == "next" {
        ($current_index + 1) mod ($sinks | length)
    } else if $action == "prev" {
        ($current_index - 1 + ($sinks | length)) mod ($sinks | length)
    } else {
        print $"Unknown action: ($action)"
        exit 1
    }

    # Switch sink
    let new_sink = ($sinks | get $next_index)
    ^wpctl set-default $new_sink.id
    print $"Switched to: ($new_sink.name)"
}
