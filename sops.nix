let
  secrets-dir = ./secrets;  
in
{
  sops.age.keyFile = "/var/lib/sops/keys.txt";

  sops.secrets = {
    grafana-admin-password = {
      sopsFile = "${secrets-dir}/grafana.yaml";
      key = "admin_password";
      owner = "grafana";
    };

    wireguard-private-key = {
      sopsFile = "${secrets-dir}/wireguard.yaml";
      key = "private_key";
    };

    cloudflare-api-key-dns = {
      sopsFile = "${secrets-dir}/cloudflare.yaml";
      key = "api_key_dns";
      owner = "acme";
    };
  };
}
