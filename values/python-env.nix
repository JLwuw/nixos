{ pkgs }:
pkgs.python3.withPackages (
  ps: with ps; [
    # Core
    pip
    virtualenv
    debugpy
    mutagen
    # Data science
    numpy
    pandas
    scipy
    statsmodels
    matplotlib
    seaborn
    plotly
    # ML frameworks
    torch
    torchvision
    torchaudio
    scikit-learn
    # Computer vision
    opencv4
    pillow
    # Jupyter/molten integration
    jupyter
    ipykernel
    ipython
    pynvim
    cairosvg
    # Utilities
    urllib3
    tqdm
    requests
    pyyaml
    pytest
  ]
)
