{ pkgs }:


{

let

nixbuild = pkgs.writeShellScriptBin "nixbuild" ''
    
    current_host=$(${pkgs.neofetch}/bin/neofetch --stdout | grep Host)

    if echo "$current_host" | grep -q "Razer"; then
        sudo nixos-rebuild switch --flake /etc/nixos#razer

    elif echo "$current_host" | grep -q "KVM/QEMU"; then
        sudo nixos-rebuild switch --flake /etc/nixos#WM

    elif echo "$current_host" | grep -q "ASUS"; then
        sudo nixos-rebuild switch --flake /etc/nixos#asus
    '';

in {
    environment.systemPackages = [ nixbuild ];
}
};
