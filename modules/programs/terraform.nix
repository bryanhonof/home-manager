{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.terraform;

in {
  meta.maintainers = [ maintainers.bryanhonof ];

  options.programs.terraform = {

    enable = mkEnableOption ''
      Terraform is an open-source infrastructure as code software tool that
      provides a consistent CLI workflow to manage hundreds of cloud services.
      Terraform codifies cloud APIs into declarative configuration files.

      https://www.terraform.io/
    '';

    package = mkOption {
      type = types.package;
      default = pkgs.terraform;
      defaultText = "pkgs.terraform";
      description = "The Terraform package to use";
    };

    providers = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "A list of Terraform providers.";
    };

    installCompletion = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Wether or not to install the autocomplete functionality. Normally this
        is done by running <literal>terraform -install-autocomplete</literal>.
        Currently only installs for bash.
      '';
    };

  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package.withPlugins (p: with p; cfg.providers) ];

    programs.bash.bashrcExtra = let program = "terraform";
    in mkIf cfg.installCompletion ''
      complete -C ${cfg.package}/bin/${program} ${program}
    '';
  };
}
