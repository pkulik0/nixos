{ config, ... }:

{
  # Generate the secretsFile for wpa_supplicant from SOPS secrets
  sops.templates."wifi-secrets" = {
    content = ''
      wifi_password=${config.sops.placeholder.wifi-password}
    '';
  };

  networking.wireless = {
    enable = true;

    # Allow imperative network management via wpa_cli as fallback
    allowAuxiliaryImperativeNetworks = true;

    # Declarative WiFi networks
    networks = {
      "Toppi 5GHz" = {
        pskRaw = "ext:wifi_password";
      };
    };

    # Read secrets from SOPS template (key=value format)
    secretsFile = config.sops.templates."wifi-secrets".path;

    # Allow wpa_cli/wpa_gui control for debugging
    userControlled = true;
  };
}
