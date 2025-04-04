{ disks ? [ "/dev/sda" ], ...}: {
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = builtins.elemAt disks 0;
	    content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs_root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "znix";
              };
            };
          };
        };
      };
    };
    zpool = {
      znix = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "lz4";
	      atime = "off";
	      encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation =  "prompt";
          "com.sun:auto-snapshot" = "false";
        };
	    options.ashift = "13";
        postCreateHook = "zfs snapshot znix@blank";

        datasets = {
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          ROOT = {
                type = "zfs_fs";
                options.mountpoint = "none";
          };
          "ROOT/default" = {
                type = "zfs_fs";
                mountpoint = "/";
	       };
        };
      };
    };
  };
}
