# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "hetzner-nix";

  services.xserver.enable = false;

  # Internationalisation/locale
  time.timeZone = "redacted";
  console = {
    keyMap = "redacted";
  };

  # doas > sudo (smaller attack surface).
  # CVE-2023-22809 concerning sudo is just one example.
  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        persist = true;
        keepEnv = true;
      }
    ];
  };
  security.sudo.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hodlinator = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  services.fail2ban.enable = true; # Recommended by https://nixos.wiki/wiki/SSH
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    31734 # Nginx
  ];

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    # Recommended by thelounge docs: https://thelounge.chat/docs/guides/reverse-proxies#nginx
    proxyTimeout = "1d";
    defaultSSLListenPort = 31734;
    virtualHosts = {
      "0.0.0.0" = {
        # Source: https://stackoverflow.com/questions/10175812/how-can-i-generate-a-self-signed-ssl-certificate-using-openssl
        # openssl req -x509 -newkey rsa:4096 -keyout thelounge_key.pem -out thelounge_cert.pem -sha256 -days 1000 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"
        sslCertificate = ./thelounge/thelounge_cert.pem;
        sslCertificateKey = ./thelounge/thelounge_key.pem;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:9000"; # TheLounge, configured below
        };
      };
    };
  };

  services.thelounge = {
    enable = true;
    port = 9000; # 9000=default
    # Requires users to be added via CLI: doas -u thelounge thelounge add testlounge
    public = false;
    extraConfig = {
      theme = "morning"; # Dark-ish mode
      leaveMessage = ""; # TODO: Verify it works
      defaults = {
        name = "Libera.Chat";
        host = "irc.libera.chat";
        port = 6697;
        password = "";
        tls = true;
        reverseProxy = true;
        rejectUnauthorized = true;
        nick = "thelounge%%";
        username = "thelounge";
      };
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
