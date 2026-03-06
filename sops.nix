{
  sops.age.keyFile = "/var/lib/sops/keys.txt";

  sops.defaultSopsFile = ./secrets.yaml;

  sops.secrets = {
    wireguard-private-key = {
      key = "wireguard_private_key";
    };
    k3s-token = {
      key = "k3s_token";
    };
  };
}
