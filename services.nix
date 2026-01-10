{ pkgs, lib, config, ... }:
{
  systemd.tmpfiles.rules = [
    "d /mnt/postgresql 0750 postgres postgres -"
  ];

  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
      dataDir = "/mnt/postgresql";
      ensureDatabases = [ "pk" "postgres" ];
      ensureUsers = [
        {
          name = "pk";
          ensureDBOwnership = true;
        }
        {
          name = "postgres-exporter";
        }
      ];
      settings = {
        listen_addresses = lib.mkForce "127.0.0.1";
      };
      authentication = ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
      '';
    };

    redis = {
      servers."" = {
        enable = true;
        port = 6379;
        bind = "127.0.0.1";
        settings = {
          protected-mode = "no";
        };
      };
    };

    nats = {
      enable = true;
      jetstream = true;
      settings = {
        http_port = 8222;
        host = "0.0.0.0";
      };
    };

    vault = {
      enable = true;
      package = pkgs.vault-bin;
      address = "0.0.0.0:8200";
      storageBackend = "file";
      storagePath = "/var/lib/vault";
      extraConfig = ''
        ui = true

        telemetry {
          prometheus_retention_time = "30s"
          disable_hostname = true
        }
      '';
    };

    prometheus = {
      enable = true;
      listenAddress = "0.0.0.0";
      port = 9090;
      exporters = {
        postgres = {
          enable = true;
          dataSourceName = "user=postgres-exporter database=postgres host=/run/postgresql sslmode=disable";
          listenAddress = "0.0.0.0";
          port = 9187;
        };
        redis = {
          enable = true;
          listenAddress = "0.0.0.0";
          port = 9121;
        };
        nats = {
          enable = true;
          listenAddress = "0.0.0.0";
          port = 7777;
          extraFlags = [
            "-varz"
            "-connz"
            "-healthz"
            "-subz"
            "-routez"
          ];
        };
      };
      scrapeConfigs = [
        {
          job_name = "postgres";
          static_configs = [{
            targets = [ "127.0.0.1:9187" ];
          }];
        }
        {
          job_name = "redis";
          static_configs = [{
            targets = [ "127.0.0.1:9121" ];
          }];
        }
        {
          job_name = "nats";
          static_configs = [{
            targets = [ "127.0.0.1:7777" ];
          }];
        }
        {
          job_name = "vault";
          metrics_path = "/v1/sys/metrics";
          params = {
            format = [ "prometheus" ];
          };
          static_configs = [{
            targets = [ "127.0.0.1:8200" ];
          }];
        }
      ];
    };

    grafana = {
      enable = true;
      declarativePlugins = with pkgs.grafanaPlugins; [
        redis-datasource
      ];
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
        };
        security = {
          admin_user = "pk";
          admin_password = "$__file{${config.sops.secrets.grafana-admin-password.path}}";
        };
      };
      provision.datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
        }
        {
          name = "PostgreSQL";
          type = "postgres";
          url = "127.0.0.1:5432";
          user = "pk";
          jsonData = {
            database = "pk";
            sslmode = "disable";
          };
        }
        {
          name = "Redis";
          type = "redis-datasource";
          url = "127.0.0.1:6379";
        }
      ];
    };
  };
}
