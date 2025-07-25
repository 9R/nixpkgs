{
  lib,
  callPackage,
  python3Packages,
  gtk3,
  cairo,
  adwaita-icon-theme,
  librsvg,
  xvfb-run,
  dbus,
  libnotify,
  wrapGAppsHook3,
  which,
  gettext,
  gobject-introspection,
  gdk-pixbuf,
  texliveSmall,
  imagemagick,
  perlPackages,
  writeScript,
}:

let
  documentation_deps = [
    (texliveSmall.withPackages (
      ps: with ps; [
        wrapfig
        gensymb
      ]
    ))
    xvfb-run
    imagemagick
    perlPackages.Po4a
  ];
  inherit (callPackage ./src.nix { }) version src sample_documents;
in

python3Packages.buildPythonApplication rec {
  inherit src version;
  pname = "paperwork";
  format = "pyproject";

  sample_docs = sample_documents // {
    # a trick for the update script
    name = "sample_documents";
    src = sample_documents;
  };

  sourceRoot = "${src.name}/paperwork-gtk";

  postPatch = ''
    chmod a+w -R ..
    patchShebangs ../tools

    export HOME=$(mktemp -d)
  '';

  preBuild = ''
    make l10n_compile
  '';

  postInstall = ''
    # paperwork-shell needs to be re-wrapped with access to paperwork
    for exe in paperwork-cli paperwork-json; do
      cp ${python3Packages.paperwork-shell}/bin/.$exe-wrapped $out/bin/$exe
    done
    # install desktop files and icons
    XDG_DATA_HOME=$out/share $out/bin/paperwork-gtk install --user

    # fixes [WARNING] [openpaperwork_core.resources.setuptools] Failed to find
    # resource file paperwork_gtk.icon.out/paperwork_128.png, tried at path
    # /nix/store/3n5lz6y8k9yks76f0nar3smc8djan3xr-paperwork-2.0.2/lib/python3.8/site-packages/paperwork_gtk/icon/out/paperwork_128.png.
    site=$out/${python3Packages.python.sitePackages}/paperwork_gtk
    for i in $site/data/paperwork_*.png; do
      ln -s $i $site/icon/out;
    done

    export XDG_DATA_DIRS=$XDG_DATA_DIRS:${adwaita-icon-theme}/share
    # build the user manual
    PATH=$out/bin:$PATH PAPERWORK_TEST_DOCUMENTS=${sample_docs} make data
    for i in src/paperwork_gtk/model/help/out/*.pdf; do
      install -Dt $site/model/help/out $i
    done
  '';

  nativeCheckInputs = [ dbus ];

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    python3Packages.setuptools-scm
    (lib.getBin gettext)
    which
    gdk-pixbuf # for the setup hook
  ]
  ++ documentation_deps;

  buildInputs = [
    adwaita-icon-theme
    libnotify
    librsvg
    gtk3
    cairo
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  checkPhase = ''
    runHook preCheck

    # A few parts of chkdeps need to have a display and a dbus session, so we not
    # only need to run a virtual X server + dbus but also have a large enough
    # resolution, because the Cairo test tries to draw a 200x200 window.
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus}/share/dbus-1/session.conf \
      $out/bin/paperwork-gtk chkdeps

    $out/bin/paperwork-cli chkdeps
    $out/bin/paperwork-json chkdeps

    # content of make test, without the dep on make install
    python -m unittest discover --verbose -s tests

    runHook postCheck
  '';

  propagatedBuildInputs = with python3Packages; [
    paperwork-backend
    paperwork-shell
    openpaperwork-gtk
    openpaperwork-core
    pypillowfight
    pyxdg
    setuptools
  ];

  disallowedRequisites = documentation_deps;

  passthru.updateScript = writeScript "update.sh" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl common-updater-scripts
    version=$(list-git-tags | sed 's/^v//' | sort -V | tail -n1)
    update-source-version paperwork "$version" --file=pkgs/applications/office/paperwork/src.nix
    docs_version="$(curl https://gitlab.gnome.org/World/OpenPaperwork/paperwork/-/raw/$version/paperwork-gtk/src/paperwork_gtk/model/help/screenshot.sh | grep TEST_DOCS_TAG= | cut -d'"' -f2)"
    update-source-version paperwork.sample_docs "$docs_version" --file=pkgs/applications/office/paperwork/src.nix --version-key=rev
  '';

  meta = {
    description = "Personal document manager for scanned documents";
    homepage = "https://openpaper.work/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      aszlig
      symphorien
    ];
    platforms = lib.platforms.linux;
  };
}
