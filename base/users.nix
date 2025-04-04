{ pkgs, ... }:
let
 #mkpasswd -m sha-512
 hp = "$6$.nyA5ZZNvI23ERqI$V/lUeBYhmJEKq6kC1RdFbVhxl4Ta3FIa.RVJZ1a8ljtKW/WVvxw2n2gU9VRG9WzJZxBsRzqophwydVagunMEu.";
in
{
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;
    users = {
        users.any = {
            isNormalUser = true;
            description = "user for Any task";
            extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user. hostID
            hashedPassword = hp;
        };
        users.root = {
            hashedPassword = hp;
        };
    };

    users.mutableUsers = false;
}