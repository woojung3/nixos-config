{ pkgs }:
let
  inherit (pkgs) lib;
  source = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../home/jwlee/quickshell
      ../home/jwlee/crt
      ./quickshell
      ./crt
    ];
  };
  controls = [
    "BloomButton"
    "BloomSlider"
    "ChoicePicker"
    "MediaIconButton"
    "PanelSession"
  ];
  theme = pkgs.writeText "Theme.qml" (import ../home/jwlee/quickshell/theme.nix);
in
{
  desktop-logic =
    pkgs.runCommand "bloom-desktop-logic-tests"
      {
        nativeBuildInputs = with pkgs; [
          bash
          nodejs
          jq
          util-linux
        ];
      }
      ''
        cp -r ${source} source
        chmod -R u+w source
        chmod +x source/tests/crt/hyprctl-mock.sh
        patchShebangs source/tests
        cd source
        bash tests/quickshell/run.sh
        bash tests/crt/run.sh
        touch "$out"
      '';

  crt-shader =
    pkgs.runCommand "bloom-crt-shader-check"
      {
        nativeBuildInputs = [ pkgs.glslang ];
      }
      ''
        glslangValidator -S frag ${../home/jwlee/crt/bloom-crt.frag}
        touch "$out"
      '';

  desktop-ui =
    pkgs.runCommand "bloom-desktop-ui-tests"
      {
        nativeBuildInputs = [ pkgs.qt6.qtdeclarative ];
        LC_ALL = "C.UTF-8";
        QT_QPA_PLATFORM = "offscreen";
        QT_QUICK_BACKEND = "software";
        QT_QUICK_CONTROLS_STYLE = "Basic";
        QML_IMPORT_PATH = "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml";
        QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/lib/qt-6/plugins";
        FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; };
      }
      ''
        export HOME="$TMPDIR/home"
        export XDG_RUNTIME_DIR="$TMPDIR/runtime"
        mkdir -p "$HOME" "$XDG_RUNTIME_DIR" components
        chmod 700 "$XDG_RUNTIME_DIR"
        cp -r ${./quickshell/ui} ui
        ${lib.concatMapStringsSep "\n" (name: ''
          cp ${../home/jwlee/quickshell}/${name}.qml components/
          echo '${name} 1.0 ${name}.qml' >> components/qmldir
        '') controls}
        cp ${theme} components/Theme.qml
        echo 'singleton Theme 1.0 Theme.qml' >> components/qmldir
        qmltestrunner -input ui -o "$out",txt -o -,txt
      '';
}
