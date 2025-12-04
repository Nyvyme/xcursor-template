# XCursor Template
This is a set of scripts that will help you compile and install your xcursors.

## Usage
`vars.sh` file contains global variables for build, clean and install processes.

`compile.sh` will compile your cursors. Built themes can be found in `build`
directory. XCursor config files can be found in `cursors` directory. Rasterized
images for different resolutions can be found in `imgs` directory.

`install.sh` will install cursors themes that were built by `compile.sh` script.
If ran as root, it will place themes at `/usr/share/icons` directory.
Otherwise, it will place them at `$HOME/.local/share/icons` directory.

`clean.sh` will remove all build artifacts.

`src` directory contains your source `.SVG` cursor images <ins>__or__</ins>
directories with `.SVG` frames for animated cursors.

`symlinks` directory contains optional `.links` files for cursors.
In these files symlinks for cursors are defined.
Learn more in [`symlinks/README.md`](symlinks/README.md).

`hotspots` directory contains optional `.hotspot` files for cursors.
In these files hotspots for cursors are defined. If file is not provided,
`compile.sh` script will set cursor hotspots to `(0;0)`.
Learn more in [`hotspots/README.md`](hotspots/README.md).

`frametimes` directory contains optional `.frametime` files for animated
cursors. In these files frametimes (in milliseconds) are defined. If file is
not provided, `compile.sh` script will set frametime to a `$DEFAULT_FRAMETIME`
that can be changed in `var.sh` script.
Learn more in [`frametimes/README.md`](frametimes/README.md).

## Requirements
`bc`, `inkscape` and `xcursorgen` must be installed to compile cursor themes.
