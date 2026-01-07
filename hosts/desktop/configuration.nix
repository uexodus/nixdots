{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../disk-config.nix
  ];

  nixpkgs.config.allowUnfree = true;

  sops = {
    defaultSopsFile = ../../secrets/shared.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/var/lib/sops-nix/key.txt";
    
    secrets = {
      "user-jamie-password" = {
        neededForUsers = true;
      };
    };
  };

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    sops
  ];

  users.users.root.openssh.authorizedKeys.keys =
  [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtH9o3fgNsIOAkp75kK4vejVdHuiKZKPoMxupOhEBYO jamie@laptop"
  ] ++ (args.extraPublicKeys or []); # this is used for unit-testing this module and can be removed if not needed

  system.stateVersion = "24.05";


  users.users.jamie = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    hashedPasswordFile = config.sops.secrets."user-jamie-password".path;
  };
}

