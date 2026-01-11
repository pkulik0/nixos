{
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";

  sops.secrets.grafana-admin-password = {
    sopsFile = ./secrets/grafana.json;
    key = "admin_password";
    owner = "grafana";
  };

  # GitLab secrets
  sops.secrets.gitlab-secret = {
    sopsFile = ./secrets/gitlab.json;
    key = "secret";
    owner = "gitlab";
  };

  sops.secrets.gitlab-otp = {
    sopsFile = ./secrets/gitlab.json;
    key = "otp_secret";
    owner = "gitlab";
  };

  sops.secrets.gitlab-db = {
    sopsFile = ./secrets/gitlab.json;
    key = "db_secret";
    owner = "gitlab";
  };

  sops.secrets.gitlab-jws = {
    sopsFile = ./secrets/gitlab.json;
    key = "jws_private_key";
    owner = "gitlab";
  };

  sops.secrets.gitlab-ar-primary = {
    sopsFile = ./secrets/gitlab.json;
    key = "active_record_primary_key";
    owner = "gitlab";
  };

  sops.secrets.gitlab-ar-deterministic = {
    sopsFile = ./secrets/gitlab.json;
    key = "active_record_deterministic_key";
    owner = "gitlab";
  };

  sops.secrets.gitlab-ar-salt = {
    sopsFile = ./secrets/gitlab.json;
    key = "active_record_salt";
    owner = "gitlab";
  };

  sops.secrets.gitlab-root-password = {
    sopsFile = ./secrets/gitlab.json;
    key = "initial_root_password";
    owner = "gitlab";
  };

  sops.secrets.gitlab-db-password = {
    sopsFile = ./secrets/gitlab.json;
    key = "db_password";
    owner = "gitlab";
  };
}
