let
  secrets-dir = ./secrets;  
in
{
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";

  sops.secrets = {
    grafana-admin-password = {
      sopsFile = "${secrets-dir}/grafana.json";
      key = "admin_password";
      owner = "grafana";
    };

    gitlab-secret = {
      sopsFile = "${secrets-dir}/gitlab.json";
      key = "secret";
      owner = "gitlab";
    };

    gitlab-otp = {
      sopsFile = "${secrets-dir}/gitlab.json";
      key = "otp_secret";
      owner = "gitlab";
    };

    gitlab-db = {
      sopsFile = "${secrets-dir}/gitlab.json";
      key = "db_secret";
      owner = "gitlab";
    };

    gitlab-jws = {
      sopsFile = "${secrets-dir}/gitlab.json";
      key = "jws_private_key";
      owner = "gitlab";
    };

    gitlab-ar-primary = {
      sopsFile = "${secrets-dir}/gitlab.json";
      key = "active_record_primary_key";
      owner = "gitlab";
    };

    gitlab-ar-deterministic = {
      sopsFile = "${secrets-dir}/gitlab.json";
      key = "active_record_deterministic_key";
      owner = "gitlab";
    };

    gitlab-ar-salt = {
      sopsFile = "${secrets-dir}/gitlab.json";
      key = "active_record_salt";
      owner = "gitlab";
    };

    gitlab-root-password = {
      sopsFile = "${secrets-dir}/gitlab.json";
      key = "initial_root_password";
      owner = "gitlab";
    };

    gitlab-db-password = {
      sopsFile = "${secrets-dir}/gitlab.json";
      key = "db_password";
      owner = "gitlab";
    };

    wireguard-private-key = {
      sopsFile = "${secrets-dir}/wireguard.json";
      key = "wireguard_private_key";
    };

    cloudflare-dns-api-token = {
      sopsFile = "${secrets-dir}/cloudflare.json";
      key = "dns_api_token";
      owner = "acme";
    };
  };
}
