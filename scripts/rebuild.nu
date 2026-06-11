#!/usr/bin/env nu
# @reference: modules/features/shell.nix

const FLAKE_DIR = "/persist/home/user/nixos"

def main [] {
  cd $FLAKE_DIR
  sudo nixos-rebuild switch --flake path:.
}

def "main push" [target: string] {
  cd $FLAKE_DIR
  nixos-rebuild switch --flake $"path:.#laptop" --target-host $"root@($target)"
}
