{ pkgs, ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Audio ducking: lower other streams when Open-LLM-VTuber speaks
  # Uses WirePlumber's role-based linking policy with loopback virtual sinks
  # SPA format required for wireplumber.components (JSON serialization breaks provides/requires)
  # Reference: wireplumber.conf.d.examples/media-role-nodes.conf
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/50-ducking.conf" ''
      wireplumber.profiles = {
        main = {
          policy.linking.role-based.loopbacks = required
        }
      }

      wireplumber.settings = {
        node.stream.default-media-role = Multimedia
        linking.role-based.duck-level = 0.15
      }

      wireplumber.components.rules = [
        {
          matches = [
            {
              provides = "~loopback.sink.*"
            }
          ]
          actions = {
            merge = {
              arguments = {
                capture.props = {
                  policy.role-based.target = true
                  audio.position = [ FL, FR ]
                  media.class = Audio/Sink
                }
                playback.props = {
                  node.passive = true
                  media.role = Loopback
                }
              }
              requires = [ support.export-core, pw.node-factory.adapter ]
            }
          }
        }
      ]

      wireplumber.components = [
        {
          type = virtual, provides = policy.linking.role-based.loopbacks
          requires = [ loopback.sink.role.multimedia
                       loopback.sink.role.communication ]
        }
        {
          name = libpipewire-module-loopback, type = pw-module
          arguments = {
            node.name = "loopback.sink.role.multimedia"
            node.description = "Multimedia"
            capture.props = {
              device.intended-roles = [ "Music", "Movie", "Game", "Multimedia" ]
              policy.role-based.priority = 10
              policy.role-based.action.same-priority = "mix"
              policy.role-based.action.lower-priority = "mix"
            }
          }
          provides = loopback.sink.role.multimedia
        }
        {
          name = libpipewire-module-loopback, type = pw-module
          arguments = {
            node.name = "loopback.sink.role.communication"
            node.description = "Communication"
            capture.props = {
              device.intended-roles = [ "Communication" ]
              policy.role-based.priority = 50
              policy.role-based.action.same-priority = "mix"
              policy.role-based.action.lower-priority = "duck"
            }
          }
          provides = loopback.sink.role.communication
        }
      ]

    '')
  ];

  # Assign media.role on Open-LLM-VTuber streams via PipeWire pulse rules
  # (pulse.rules sets properties on the PipeWire node before WirePlumber sees it)
  services.pipewire.extraConfig.pipewire-pulse."50-ducking" = {
    "pulse.rules" = [
      {
        matches = [{ "application.process.binary" = "electron"; }];
        actions.update-props = {
          "media.role" = "Communication";
        };
      }
    ];
  };

  home-manager.users.user.home.packages = with pkgs; [
    pavucontrol # PulseAudio volume control GUI
    qpwgraph # PipeWire graph editor
    audacity # audio editor and recorder
    playerctl # media player control (MPRIS)
    songrec # Shazam audio recognition client
  ];
}
