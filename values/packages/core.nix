{ pkgs, ... }:
{
  # System packages installed among all hosts
  systemPackages = with pkgs; [
    # Hardware & System
    pciutils # lspci, setpci
    usbutils # lsusb
    efibootmgr # manage UEFI boot entries

    # Shells & Core Utils
    screen # terminal multiplexer

    # Networking
    curl # HTTP requests, URL transfers
    wget # HTTP downloads
    aria2 # multi-protocol download utility (HTTP/BT/Metalink)
    rsync # file sync and copy
    pv # monitor data progress through pipe
    netcat-gnu # arbitrary TCP/UDP connections (nc)
    inetutils # ping, telnet, hostname
    net-tools # ifconfig, netstat (legacy network tools)
    dnsutils # dig, nslookup DNS lookup tools
    nmap # network discovery and security scanning
    lsof # list open files and network connections
    tor # anonymity network (socks proxy)
    nethogs # per-process network bandwidth monitoring
    iperf # network bandwidth measurement tool

    # System Monitoring
    bottom # graphical process viewer (btm)
    iotop # I/O usage per process

    # File Management
    ncdu # disk usage analyzer (ncurses)
    tree # directory tree listing
    fd # fast file find alternative to find
    ripgrep # fast text search alternative to grep
    file # detect file type by magic bytes

    # Compression
    zstd # fast real-time compression (zstd)
    p7zip # 7-Zip archiver (7z, xz, lzma)
    zip # zip archiver
    unzip # zip extractor

    # Text Processing
    bc # arbitrary precision calculator language
    jq # JSON processor and query tool
    difftastic # structural diff tool by syntax tree

    # Filesystems
    dosfstools # FAT filesystem utilities (mkfs.fat, fsck.fat)
    mtools # MS-DOS filesystem utilities
    exfatprogs # exFAT filesystem utilities
    ntfs3g # NTFS filesystem driver with write support
    nfs-utils # NFS client and server utilities

    # Editors
    neovim # extensible text editor (primary editor)

    # Cryptography
    openssl # general-purpose cryptography toolkit

    # Virtualisation
    docker-compose # multi-container Docker orchestration
  ];

  # User packages installed among all hosts
  homePackages = with pkgs; [ ];
}
