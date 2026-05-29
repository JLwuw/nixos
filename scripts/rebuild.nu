#!/usr/bin/env nu
# @reference: modules/features/shell.nix

const FLAKE_DIR = "/persist/home/user/nixos"
const SYNCTHING_CONFIG = "/home/user/.config/syncthing/config.xml"

const IP_TO_HOST = {
  "10.100.0.1": "server"
  "10.100.0.2": "desktop"
  "10.100.0.3": "laptop"
}

def get-api-key [] {
  open $SYNCTHING_CONFIG
    | get content
    | where tag == "gui" | first
    | get content
    | where tag == "apikey" | first
    | get content.0.content
}

def get-device-id [headers: record, name: string] {
  http get -H $headers http://localhost:8384/rest/config/devices
    | where name == $name | first | get deviceID
}

def sync-wait [ip: string] {
  let host = $IP_TO_HOST | get -o $ip
  if $host == null {
    error make { msg: $"Unknown host: ($ip)" }
  }

  if $host == (hostname) {
    return
  }

  let api_key = (get-api-key)
  let headers = { X-API-Key: $api_key }
  let device_id = (get-device-id $headers $host)

  http post -H $headers "http://localhost:8384/rest/db/scan?folder=Core" "" | ignore

  print $"Waiting for Core to sync to ($host)..."

  loop {
    let comp = (http get -H $headers $"http://localhost:8384/rest/db/completion?folder=Core&device=($device_id)")
    if $comp.completion == 100 and $comp.needBytes == 0 {
      print $"Synced to ($host)."
      break
    }
    print $"  ($comp.completion | math round -p 1)% — ($comp.needBytes) bytes remaining"
    sleep 1sec
  }
}

# rebuild — rebuild current host locally
def main [ip?: string] {
  if $ip == null {
    cd $FLAKE_DIR
    sudo nixos-rebuild switch --flake path:.
  } else {
    sync-wait $ip
    bash -c $"ssh -t ($ip) \"sh -c 'cd ($FLAKE_DIR) && sudo nixos-rebuild switch --flake path:.'\""
  }
}

# rebuild push <ip> — build locally, send closure over SSH
def "main push" [ip: string] {
  cd $FLAKE_DIR
  nixos-rebuild switch --flake path:. --target-host $"root@($ip)"
}
