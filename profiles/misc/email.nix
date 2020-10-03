{ config, pkgs, lib, ... }:
{
  accounts.email = {
    maildirBasePath = "mail";
    accounts.gmail = let 
      email = "sam.hernandez.amador@gmail.com";
    in {
      address = email;
      userName = email;
      passwordCommand = "pass Google/${email}_smtp";
      realName = "Samuel Hernandez";
      flavor = "gmail.com";
      imap.host = "imap.gmail.com";
      smtp.host = "smtp.gmail.com";
      gpg = {
        key = "9B5230E469C7207B";
        signByDefault = true;
      };
      mbsync = {
        enable = true;
        create = "both";
        patterns = [
          "*"
          "![Gmail]*"
          "[Gmail]/Sent Mail"
          "[Gmail]/Starred"
          "[Gmail]/All Mail"
        ];
        extraConfig = {
          channel = { Sync = "All"; };
          account = {
            Timeout = 120;
            PipelineDepth = 1;
          };
        };
      };
      msmtp.enable = true;
      primary = true;
    };
    accounts.school = import ../../secrets/school-email.nix;
  };
}
