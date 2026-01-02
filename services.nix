{ pkgs, ... }:
{
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
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
    };

    redis = {
      servers."" = {
        enable = true;
        port = 6379;
      };
    };

    nats = {
      enable = true;
      jetstream = true;
      settings = {
        http_port = 8222;
      };
    };

    vault = {
      enable = true;
      address = "127.0.0.1:8200";
      extraConfig = ''
        telemetry {
          prometheus_retention_time = "30s"
          disable_hostname = true
        }
      '';
    };

    prometheus = {
      enable = true;
      package = pkgs.prometheus;
      exporters = {
        postgres = {
          enable = true;
          dataSourceName = "user=postgres-exporter database=postgres host=/run/postgresql sslmode=disable";
        };
        redis = {
          enable = true;
        };
        nats = {
          enable = true;
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
  };
}
