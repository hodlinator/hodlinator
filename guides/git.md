# Git tidbits

## Diff two squashed commit ranges against each other

Useful after a rebase when one wants to get an overview of what changed without immediately digging into each commit with `git range-diff`, or when some commits have been merged/split/altered too much for `git range-diff`.

```shell
meld <(git diff 53341ea10dc2f7df371b416060863bbc094b8773~9..53341ea10dc2f7df371b416060863bbc094b8773) <(git diff eb0f41ee1ed9ea54019fcaa4e3ce33481da4459d~8..eb0f41ee1ed9ea54019fcaa4e3ce33481da4459d)
```

## Nix home-manager configuration

```nix
    git = {
      enable = true;

      userEmail = "...";
      userName = "...";

      aliases = {
        br = "branch";
        ci = "commit";
        co = "checkout";
        st = "status";

        # From https://gist.github.com/gnarf/5406589
        pr = "!f() { git fetch -fu \${2:-\$(git remote |grep ^upstream || echo origin)} refs/pull/\$1/head:pr/\$1 && git checkout pr/\$1; }; f";
      };

      ignores = [ ".cache" "compile_commands.json" "shell.nix" "*.sublime-workspace" "*.sublime-project" "*.o.tmp" ];

      signing = {
        signByDefault = true;
        key = "~/.ssh/hodlinator_signing_key.id_ed25519.pub";
      };

      extraConfig = {
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";

        core.editor = "subl -w";
        diff.tool = "meld";
        diff.colorMoved = "dimmed-zebra";
        diff.colorMovedWS = "allow-indentation-change";

        gpg.mintrustlevel = "marginal";
        init.defaultBranch = "master";
        log.showSignature = true;
        merge.conflictstyle = "diff3"; # Includes "original" as well as "yours" & "theirs".
        merge.verifySignatures = false;
        pull.rebase = false; # Not so fast mister.
      };
    };
```