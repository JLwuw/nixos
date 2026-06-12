{ pkgs, ... }:
{
  # System packages installed among workstations (desktop, laptop)
  systemPackages = with pkgs; [
    # Database CLI tools
    sqlite # embedded database command-line shell
    postgresql # PostgreSQL database client and tools

    # Disk Management
    udisks2 # disk management daemon and CLI
    gparted # graphical partition editor

    # Codecs
    openh264 # Cisco H.264 video codec
    v4l-utils # Video4Linux device utilities

    # Security
    polkit_gnome # polkit authentication agent
  ];

  # User packages installed among workstations (desktop, laptop)
  homePackages = with pkgs; [
    # Browsers
    kdePackages.falkon # KDE QtWebEngine browser
    google-chrome # Google Chrome browser

    # Terminal & Shell
    lsd # ls replacement with icons and colors
    fzf # fuzzy finder (ctrl-R, ctrl-T integration)
    hyperfine # command-line benchmarking tool

    # Wayland utilities
    wdisplays # display configuration GUI (wlr-randr frontend)

    # Remote Desktop
    wayvnc # Wayland VNC server
    tigervnc # VNC client (vncviewer)
    freerdp # RDP client (FreeRDP)
    moonlight-qt # NVIDIA GameStream / Sunshine game streaming client

    # Version Control
    lazygit # terminal UI for git

    # Programming Languages & Runtimes
    zvm # Zig Version Manager
    nodejs # JavaScript runtime (npm for Node.js LSPs via Mason)
    go # Go programming language
    golangci-lint # Go linters runner
    gnumake # build system (R package compilation, Mason deps)
    gcc # GNU C compiler (gopls cgo, C compilation via Mason)
    php # PHP programming language
    (rWrapper.override {
      packages = with rPackages; [
        languageserver
        lintr
        roxygen2
        xml2
        ggplot2
        dplyr
        fpp3
      ];
    }) # R programming language with common packages
    rPackages.languageserver # R LSP server (Mason)
    rPackages.lintr # R linter (Mason)
    rPackages.roxygen2 # R documentation generator (Mason)
    rPackages.xml2 # R XML parser (Mason)
    libxml2 # XML C parser (R xml2 system dep, Mason)
    imagemagick # image manipulation toolkit
    lua51Packages.lua # Lua 5.1 interpreter (image.nvim dep)
    lua51Packages.luarocks # Lua package manager (image.nvim dep)
    pnpm # fast Node.js package manager
    bun # JavaScript runtime and toolkit
    ruby # Ruby programming language
    uv # fast Python package manager (uv)
    (import ../python-env.nix { inherit pkgs; }) # Python with data science packages

    # SDKs and Platforms
    flutter # Flutter UI toolkit SDK
    jdk17 # Java Development Kit 17
    gradle # Java build system
    dotnet-sdk # .NET SDK (csharp-ls LSP via Mason)
    icu # Unicode/globalization library (.NET dep for marksman LSP)

    # Development Tools
    cachix # Nix binary cache management
    nil # Nix language server (neovim dep)
    nixfmt # Nix code formatter (neovim dep)
    neovim-remote # control neovim from terminal
    shellcheck # shell script static analysis
    ctags # source code tag generator
    tree-sitter # parser generator tool (neovim dep)
    forgejo-cli # Forgejo Git server CLI
    gh # GitHub CLI
    kubectl # Kubernetes CLI
    talosctl # Talos Linux Kubernetes CLI
    ansible # configuration management and automation
    argocd # ArgoCD GitOps CLI
    kubernetes-helm # Kubernetes package manager
    minio-client # MinIO/S3-compatible object storage CLI
    openbao # HashiCorp Vault alternative CLI

    # System Utilities
    trash-cli # trash-can CLI (trash-put, trash-list, etc.)
    dconf2nix # convert dconf settings to Nix (for neovide)

    # Android Tools
    scrcpy # Android device screen mirroring and control

    # Disk Management
    gnome-disk-utility # GNOME Disks (GUI for disk management)

    # Network Tools
    wireshark # network protocol analyzer
    openconnect # VPN client (Cisco AnyConnect / Palo Alto)

    # Communication
    discord # Discord chat client
    telegram-desktop # Telegram messaging client

    # Media - Video
    vlc # media player
    handbrake # video transcoder
    ffmpeg # multimedia framework (convert, record, stream)
    droidcam # use Android phone as webcam
    guvcview # webcam viewer and configuration tool

    # Media - Graphics
    inkscape # vector graphics editor (SVG)
    krita # digital painting and illustration
    gcolor3 # color picker
    pqiv # minimal image viewer

    # 3D & CAD
    f3d # fast 3D model viewer
    blender # 3D creation suite
    freecad # parametric 3D CAD modeler

    # Office & Documents
    onlyoffice-desktopeditors # Office suite (compatible with MS Office)
    zotero # reference management
    pandoc # universal document converter
    pdftk # PDF toolkit (merge, split, rotate)
    img2pdf # convert images to PDF
    texliveFull # full TeX Live distribution
    poppler-utils # PDF utilities (pdftotext, pdfinfo, pdfimages)
    unstable.slidev-cli # presentation tool from Markdown (sli.dev)

    # Math & Science
    qalculate-gtk # multi-purpose calculator

    # Utilities
    libnotify # desktop notification client (notify-send)
    screenkey # on-screen keystroke display for screencasts
    gnome-calculator # GNOME calculator
    xed # Xfce text editor (minimal GUI editor)
    bat # cat replacement with syntax highlighting
    tokei # codebase line counter

    # Wine
    wineWow64Packages.staging # Windows compatibility layer (WoW64 + staging)

    # Gaming
    supertuxkart # SuperTuxKart racing game

    # Manufacture
    orca-slicer # 3D printer slicer

    # Productivity
    super-productivity # time tracking and task management
    trilium-desktop # hierarchical note taking (syncs with server)
  ];
}
