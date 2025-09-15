{ pkgs, ... }: {
  # extraPlugins = with pkgs.vimPlugins;
  #   [
  #     (pkgs.vimUtils.buildVimPlugin {
  #       name = "darcula";
  #       src = pkgs.fetchFromGitHub {
  #         owner = "doums";
  #         repo = "darcula";
  #         rev = "faf8dbab27bee0f27e4f1c3ca7e9695af9b1242b";
  #         hash = "sha256-1c4gm7inn510x87wdr8rak3i5wxqkbc540gsj3wwymnfx0rsf0z7";
  #       };
  #     })
  #   ];
}
