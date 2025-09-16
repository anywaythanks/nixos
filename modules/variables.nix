{ lib, ... }: {
  options = {
    ideNetwork = lib.mkOption {
      default = "10.0.0.2";
      description = "Value for ide in ";
    };
  };
}
