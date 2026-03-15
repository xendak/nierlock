{
  pkgs ? import <nixpkgs> { },
}:

let
  qmlPackages = [
    pkgs.qt6.qtdeclarative
    pkgs.qt6.qtshadertools
    pkgs.quickshell
  ];

  getQmlPath =
    pkg:
    let
      path = "${pkg}/lib/qt-6/qml";
    in
    if builtins.pathExists path then path else null;

  validQmlPaths = builtins.filter (x: x != null) (map getQmlPath qmlPackages);

  qmlView = pkgs.symlinkJoin {
    name = "qml-bundle";
    paths = validQmlPaths;
  };
in
pkgs.mkShell {
  packages = qmlPackages ++ [
    pkgs.kdePackages.qtdeclarative
    pkgs.qt6.qtbase
    pkgs.procps
  ];

  shellHook = ''
    echo "[General]
    importPaths=${qmlView}" > .qmlls.ini

    export QML2_IMPORT_PATH="${qmlView}"
    export QT_PLUGIN_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}"

    echo "QML Path: ${qmlView}"
  '';
}
