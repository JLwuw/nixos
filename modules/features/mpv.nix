{ config, lib, ... }:
{
  home-manager.users.user = {
    programs.mpv = {
      enable = true;

      config = {
        # Display media title when playing
        term-playing-msg = "\${media-title}";

        # YouTube-DL options for subtitles
        ytdl-raw-options = "sub-lang=none,write-sub=";

        # Default audio filter (dynamic audio normalization)
        af = "dynaudnorm=targetrms=1:altboundary=1";

        # --- FIX FOR OVERSATURATION/BRIGHTNESS ---
        vo = "gpu-next";
        gpu-api = "vulkan";
        # Force the colorspace to NOT use the source's HDR/Wide-gamut metadata
        target-colorspace-hint-mode = "source";
        target-colorspace-hint = "no";
        # Force the brightness curve to Standard Gamma
        # mpv 0.41 often defaults to BT.1886 which is too punchy/saturated.
        target-trc = "gamma2.2";
        target-prim = "bt.709";
        # Disable the brightness-boosting "Peak Detection"
        # Stops player from trying to make whites "glow."
        hdr-compute-peak = "no";
        # Tone mapping (if you play an HDR file, force it to look like SDR)
        tone-mapping = "bt.2446a";
      };

      # Audio normalization profiles
      profiles = {
        dynaudnorm = {
          # -20dB average loudness measured
          # -5dB true peak measured
          # Adjust the peak parameter to increase or decrease the average loudness.
          # WARNING: The peak parameter also controls the true peak.
          af = "dynaudnorm=gausssize=3:peak=0.5:maxgain=100:targetrms=1:altboundary=1";
        };

        loudnorm = {
          # -20dB average loudness measured
          # -5dB true peak measured
          # Adjust the I parameter to increase or decrease the average loudness
          # Maximum true peak limited to -5dB by TP parameter
          af = "loudnorm=I=-20:LRA=50:TP=-5";
        };
      };
    };
  };
}
