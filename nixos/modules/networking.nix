{
  config,
  pkgs,
  lib,
  ...
}: {
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Tomsk";

  services.prometheus = {
    enable = true;
    port = 9090;

    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "5s";
        static_configs = [
          {
            targets = ["127.0.0.1:9100"];
          }
        ];
      }
      {
        job_name = "nginx";
        scrape_interval = "5s";
        static_configs = [
          {
            targets = ["127.0.0.1:9113"];
          }
        ];
      }
    ];
  };

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = ["systemd" "btrfs"];
    port = 9100;
  };

  services.prometheus.exporters.nginx = {
    enable = true;
    port = 9113;
    scrapeUri = "http://127.0.0.1:8080/stub_status";
  };

  services.grafana = {
    enable = true;

    security.secretKey = "$__file{/etc/nixos/secrets/grafana_secret}";

    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
      users.allow_sign_up = false;
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          access = "proxy";
          isDefault = true;
        }
      ];
    };
  };

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/nixos/secrets/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/nixos/secrets/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [3000];
}
