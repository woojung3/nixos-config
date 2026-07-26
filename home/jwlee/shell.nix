{ pkgs, ... }:
let
  theme = import ../../themes/bloom.nix;
  c = theme.colors;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      path = "$XDG_STATE_HOME/zsh/history";
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
    };
    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      sudo = "sudo ";
      ls = "eza --group-directories-first";
      ll = "eza -la --group-directories-first --git";
      cat = "bat --plain --paging=never";
      rebuild = "nh os switch";
    };
    initContent = ''
      setopt LOCAL_OPTIONS RM_STAR_SILENT PROMPT_SUBST
      autoload -Uz add-zsh-hook vcs_info
      add-zsh-hook precmd vcs_info
      zstyle ':vcs_info:git:*' formats ' %F{#${c.muted}}(%b)%f'
      PROMPT='%F{#${c.accent}}%n%f %F{#${c.muted}}%1~%f''${vcs_info_msg_0_} %F{#${c.secondary}}›%f '
    '';
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g status-position top
      set -g status-style "bg=#${c.background},fg=#${c.muted}"
      set -g window-status-current-style "bg=#${c.accent},fg=#${c.background},bold"
      set -g pane-border-style "fg=#${c.surfaceRaised}"
      set -g pane-active-border-style "fg=#${c.accent}"
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Jinwoo Lee";
      user.email = "woojung3@postech.ac.kr";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = [ pkgs.zoxide ];
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
