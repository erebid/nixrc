{ config, lib, pkgs, domains, ... }:

with lib;
let cfg = config.programs.git;
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs.gitAndTools; [
      git-bug
      git-appraise
      hub
      lab
      git-crypt
      git-secrets
      gh
    ];

    programs.git = {
      package = pkgs.hiPrio pkgs.gitAndTools.gitFull;
      aliases = lib.mkForce { };
      ignores = [ ];
      delta = {
        enable = true;
        options = [ "--dark --width=variable" ];
      };
      signing = {
        gpgPath = "${pkgs.gnupg}/bin/gpg2";
        signByDefault = true;
      };

      attributes = [ ".rs filter=spacify_trim" ];
      extraConfig = {
        credential.helper = "store";

        extensions.worktreeConfig = "true";
        pull.rebase = "merges";
        push = {
          default = "simple";
          followTags = true;
        };
        rebase.abbreviateCommands = true;

        url = {
          "git://github.com/" = { insteadOf = "github:"; };
          "git@github.com:" = {
            insteadOf = "gh:";
            pushInsteadOf = [ "github:" "git://github.com/" ];
          };

          "git://gitlab.com/" = { insteadOf = "gitlab:"; };
          "git@gitlab.com:" = {
            insteadOf = "gl:";
            pushInsteadOf = [ "gitlab:" "git://gitlab.com/" ];
          };

          "git://gist.github.com/" = { insteadOf = "gist:"; };
          "git@gist.github.com:" = {
            insteadOf = "gst:";
            pushInsteadOf = [ "gist:" "git://gist.github.com/" ];
          };
        };

        format.pretty = "oneline";
        log.decorate = "full";
        diff = {
          guitool = "gvimdiff";
          tool = "vimdiff";
        };
        merge = {
          guitool = "gvimdiff";
          tool = "vimdiff";
        };
        filter = {
          spacify = {
            clean = "expand --tabs=4 --initial";
            required = true;
          };
          spacify_trim = {
            clean = ''sh -c "expand --tabs=4 --initial %f | git-stripspace"'';
            required = true;
          };
          trim = {
            clean = "git-stripspace";
            required = true;
          };
        };
      };
    };
  };
}
