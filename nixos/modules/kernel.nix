{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "processor.max_cstate=1"
    "scsi_mod.use_blk_mq=1"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 50;

    "net.core.somaxconn" = 65535;
    "net.ipv4.tcp_max_syn_backlog" = 65535;
    "net.core.netdev_max_backlog" = 65535;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 87380 16777216";
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_fin_timeout" = 15;

    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "soft";
      value = "1048576";
    }
    {
      domain = "*";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];
}
