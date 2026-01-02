{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    ensureDatabases = [ "pk" ];
    ensureUsers = [
      {
        name = "pk";
        ensureDBOwnership = true;
      }
    ];
  };

  services.dragonflydb = {
    enable = true;
  };

  services.nats = {
    enable = true;
  };
}
