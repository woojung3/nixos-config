let
  theme = import ../../../themes/bloom.nix;
in
''
  pragma Singleton
  import QtQuick
  QtObject {
    readonly property color background: "#${theme.colors.background}"
    readonly property color foreground: "#${theme.colors.foreground}"
    readonly property color muted: "#${theme.colors.muted}"
    readonly property color accent: "#${theme.colors.accent}"
    readonly property color surface: "#${theme.colors.surfaceRaised}"
    readonly property string fontFamily: "${theme.fonts.ui}"
  }
''
