{
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";

  sops.secrets.grafana-admin-password = {
    sopsFile = ./secrets/grafana.json;
    key = "admin_password";
    owner = "grafana";
  };
}
