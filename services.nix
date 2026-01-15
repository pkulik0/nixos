{
  pkgs,
  lib,
  config,
  ...
}:
{
  systemd.tmpfiles.rules = [
    "d /mnt/postgresql 0750 postgres postgres -"
  ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@kulik.sh";
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare-api-key-dns.path;
      };
    };
  };

  services = {
    dnsmasq = {
      enable = true;
      settings = {
        listen-address = [
          "127.0.0.1"
          "10.100.0.1"
        ];
        bind-interfaces = true;
        server = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        address = [
          "/git.kulik.sh/10.100.0.1"
          "/grafana.kulik.sh/10.100.0.1"
          "/vault.kulik.sh/10.100.0.1"
        ];
      };
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "git.kulik.sh" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
            proxyWebsockets = true;
          };
        };
        "grafana.kulik.sh" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true;
          };
        };
        "vault.kulik.sh" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8200";
            proxyWebsockets = true;
          };
        };
      };
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
      dataDir = "/mnt/postgresql";
      ensureDatabases = [
        "pk"
        "postgres"
        "gitlab"
      ];
      ensureUsers = [
        {
          name = "pk";
          ensureDBOwnership = true;
        }
        {
          name = "postgres-exporter";
        }
        {
          name = "gitlab";
          ensureDBOwnership = true;
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
          static_configs = [
            {
              targets = [ "127.0.0.1:9187" ];
            }
          ];
        }
        {
          job_name = "redis";
          static_configs = [
            {
              targets = [ "127.0.0.1:9121" ];
            }
          ];
        }
        {
          job_name = "nats";
          static_configs = [
            {
              targets = [ "127.0.0.1:7777" ];
            }
          ];
        }
        {
          job_name = "vault";
          metrics_path = "/v1/sys/metrics";
          params = {
            format = [ "prometheus" ];
          };
          static_configs = [
            {
              targets = [ "127.0.0.1:8200" ];
            }
          ];
        }
        {
          job_name = "gitlab";
          metrics_path = "/-/metrics";
          scheme = "http";
          static_configs = [
            {
              targets = [ "127.0.0.1:8080" ];
            }
          ];
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
          http_addr = "0.0.0.0";
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

    gitlab = {
      enable = true;
      host = "git.kulik.sh";
      port = 80;
      https = false;

      databaseCreateLocally = false;
      databaseHost = "/run/postgresql";
      databaseName = "gitlab";
      databaseUsername = "gitlab";
      databasePasswordFile = config.sops.secrets.gitlab-db-password.path;

      secrets = {
        secretFile = config.sops.secrets.gitlab-secret.path;
        otpFile = config.sops.secrets.gitlab-otp.path;
        dbFile = config.sops.secrets.gitlab-db.path;
        jwsFile = config.sops.secrets.gitlab-jws.path;
        activeRecordPrimaryKeyFile = config.sops.secrets.gitlab-ar-primary.path;
        activeRecordDeterministicKeyFile = config.sops.secrets.gitlab-ar-deterministic.path;
        activeRecordSaltFile = config.sops.secrets.gitlab-ar-salt.path;
      };
      initialRootPasswordFile = config.sops.secrets.gitlab-root-password.path;

      puma = { # web server
        workers = 2;
        threadsMin = 1;
        threadsMax = 4;
      };

      sidekiq = { # background jobs
        concurrency = 10;
      };

      extraConfig = {
        gitlab = {
          email_from = "gitlab@kulik.sh";
          email_display_name = "GitLab";
          default_projects_features = {
            issues = true;
            merge_requests = true;
            wiki = true;
            snippets = true;
            builds = true;
          };
        };
      };
    };
  };
}
