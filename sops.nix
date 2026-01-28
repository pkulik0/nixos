let
  secrets-dir = ./secrets;
in
{
  sops.age.keyFile = "/var/lib/sops/keys.txt";

  sops.secrets = {
    wireguard-private-key = {
      sopsFile = "${secrets-dir}/wireguard.yaml";
      key = "private_key";
    };
    k3s-token = {
      sopsFile = "${secrets-dir}/k3s.yaml";
      key = "token";
    };
  };
}
