#!/usr/bin/env nu

# Language mapping (Tesseract language codes)
const languages = {
    "Spanish": "spa",
    "English": "eng",
    "German": "deu",
    "Japanese": "jpn"
}

# Cache directory and file
let cache_dir = ($env.XDG_CACHE_HOME? | default $"($env.HOME)/.cache") | path join "screenshot-ocr"
mkdir $cache_dir
let cache_file = $cache_dir | path join "last-language.txt"

# Build language list with cached choice at top
let lang_list = if ($cache_file | path exists) {
    let cached = open $cache_file | str trim
    let others = $languages | columns | where $it != $cached
    [$cached] | append $others | str join "\n"
} else {
    $languages | columns | str join "\n"
}

# Show fuzzel menu for language selection
let language_result = (echo $lang_list | fuzzel --dmenu --prompt "OCR Language: " | complete)
if $language_result.exit_code != 0 { exit 0 }

let language_key = $language_result.stdout | str trim
if ($language_key | is-empty) { exit 0 }

# Get language code and cache selection
let lang_code = $languages | get $language_key
$language_key | save -f $cache_file

# Capture screenshot area
let slurp_result = (slurp | complete)
if $slurp_result.exit_code != 0 { exit 0 }

let selection = $slurp_result.stdout | str trim

# OCR pipeline: screenshot → preprocess → tesseract → clipboard
let ocr_result = (
    grim -g $selection -
    | magick - -colorspace Gray -resize 400% -sharpen 0x1 png:-
    | tesseract -l $lang_code --psm 6 stdin stdout
    | complete
)

if $ocr_result.exit_code != 0 {
    notify-send "Screenshot OCR" $"Error: ($ocr_result.stderr | str trim)"
    exit 1
}

let text = $ocr_result.stdout | str trim

if not ($text | is-empty) {
    $text | wl-copy
    notify-send "Screenshot OCR" $"Copied \(($language_key)\)"
} else {
    notify-send "Screenshot OCR" "No text detected"
}
