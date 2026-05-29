{ pkgs, ... }:
{
  # system packages installed among all hosts
  # minimal since server does not need much
  systemPackages = with pkgs; [
    # Hardware & System
    pciutils
    usbutils
    efibootmgr
    sbctl

    # Shells & Core Utils
    nushell
    bash
    screen

    # Networking
    curl
    wget
    aria2
    rsync
    pv
    netcat-gnu
    inetutils # Ol' pal telnet
    net-tools
    dnsutils
    lsof
    tor
    # proxychains-ng
    nethogs

    # System Monitoring
    htop
    bottom
    iotop

    # File Management
    ncdu
    tree
    fd
    ripgrep
    file # check filetype - locate -i query | xargs file

    # Compression
    zstd
    p7zip
    zip
    unzip

    # Text Processing
    bc
    jq
    difftastic

    # Filesystems
    dosfstools
    mtools
    exfatprogs
    ntfs3g
    nfs-utils

    # Editors
    neovim

    # Cryptography
    openssl

    # Version Control
    git

    # Theming
    whitesur-gtk-theme
    whitesur-kde # gtk theme has kvantum files for some reason, ehh just in case tho
    whitesur-icon-theme

    # Virtualisation
    docker-compose
  ];

  # system packages installed among workstations (desktop, laptop)
  workstationSystemPackages = with pkgs; [
    # Database
    postgresql

    # X11 compatibility
    # xdotool
    # wmctrl
    # xclip
    # xsel

    # OCR
    tesseract
    tesseract5

    # Disk Management
    udisks2
    gparted

    # Codecs
    openh264
    v4l-utils

    # Security
    polkit_gnome

    # Virtualisation
    distrobox
  ];

  # user packages installed among workstations (desktop, laptop)
  workstationHomePackages = with pkgs; [
    # Browsers
    # librewolf
    # tor-browser
    # ungoogled-chromium
    google-chrome

    # Terminal & Shell
    lsd
    fzf
    fastfetch

    # Wayland Utilities
    uwsm
    mako
    swayosd
    grim
    slurp
    grimblast
    wl-clipboard
    hyprpicker
    wdisplays
    # hyprlock

    # File Managers
    nemo
    xfce.thunar # Nemo dependency for bulk rename
    nemo-fileroller

    # Version Control
    git
    # lazygit

    # Secrets Management
    sops

    # Programming Languages
    zvm
    nodejs # Mason dependency (npm for Node.js LSPs)
    go
    golangci-lint
    gnumake # Mason dependency (R packages compilation)
    gcc # Mason dependency (gopls cgo, C compilation)
    # phpPackages.composer # conflicts with Dart
    rPackages.languageserver # Mason dependency (R LSP)
    rPackages.lintr # Mason dependency (R linting)
    rPackages.roxygen2 # Mason dependency (R documentation)
    rPackages.xml2 # Mason dependency (R xml2 package)
    libxml2 # Mason dependency (R xml2 system library)
    # Python is defined per-host in hosts/{host}/nixos/packages.nix
    imagemagick
    # luajitPackages.magick # image.nvim dependency (C library for magick rock), @source: https://github.com/3rd/image.nvim#rendering-backend
    lua51Packages.lua # image.nvim dependency, @source: https://github.com/folke/lazy.nvim/issues/1570#issuecomment-2254159386
    lua51Packages.luarocks # image.nvim dependency, @source: https://github.com/folke/lazy.nvim/issues/1570#issuecomment-2254159386
    nodePackages.pnpm
    bun
    ruby
    uv
    (import ./python-env.nix { inherit pkgs; })

    # SDKs
    flutter
    dotnet-sdk # Mason dependency (csharp-ls)
    icu # .NET dependency (globalization support for marksman LSP)

    # Development Tools
    nil # Nix LSP (neovim dependency)
    nixfmt-rfc-style # Nix Formatter (neovim dependency)
    shellcheck
    ctags
    tree-sitter
    # vscode
    gh # Github CLI

    # System Utilities
    trash-cli
    playerctl
    pavucontrol
    qpwgraph
    dconf2nix

    # Android Tools
    # scrcpy

    # Disk Management
    # gnome-disk-utility

    # Printing & Scanning
    system-config-printer
    simple-scan

    # Theming
    lxappearance
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    qt6Packages.qt6ct

    # Network Tools
    wireshark
    networkmanagerapplet
    openconnect

    # Communication
    # kdePackages.kdeconnect-kde
    discord

    # Media - Video
    mpv
    yt-dlp
    vlc
    handbrake
    ffmpeg

    # Media - Audio
    audacity

    # Media - Graphics
    inkscape
    krita
    pqiv
    qimgv

    # Office & Documents
    onlyoffice-desktopeditors
    zotero
    kdePackages.okular
    foliate
    pandoc
    pdftk
    img2pdf
    texliveFull
    poppler-utils # includes pdftotext!
    unstable.slidev-cli

    # Math & Science
    qalculate-gtk

    # Utilities
    libnotify
    screenkey
    gnome-calculator
    xed
    bat
    tokei

    # Wine
    wineWowPackages.staging

    # Gaming
    superTuxKart

    # Productivity
    super-productivity
  ];
}
