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

    gitlab-secret = {
      sopsFile = "${secrets-dir}/gitlab.yaml";
      key = "secret";
      owner = "gitlab";
    };

    gitlab-otp = {
      sopsFile = "${secrets-dir}/gitlab.yaml";
      key = "otp_secret";
      owner = "gitlab";
    };

    gitlab-db = {
      sopsFile = "${secrets-dir}/gitlab.yaml";
      key = "db_secret";
      owner = "gitlab";
    };

    gitlab-jws = {
      sopsFile = "${secrets-dir}/gitlab.yaml";
      key = "jws_private_key";
      owner = "gitlab";
    };

    gitlab-ar-primary = {
      sopsFile = "${secrets-dir}/gitlab.yaml";
      key = "active_record_primary_key";
      owner = "gitlab";
    };

    gitlab-ar-deterministic = {
      sopsFile = "${secrets-dir}/gitlab.yaml";
      key = "active_record_deterministic_key";
      owner = "gitlab";
    };

    gitlab-ar-salt = {
      sopsFile = "${secrets-dir}/gitlab.yaml";
      key = "active_record_salt";
      owner = "gitlab";
    };

    gitlab-root-password = {
      sopsFile = "${secrets-dir}/gitlab.yaml";
      key = "initial_root_password";
      owner = "gitlab";
    };

    gitlab-db-password = {
      sopsFile = "${secrets-dir}/gitlab.yaml";
      key = "db_password";
      owner = "gitlab";
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
