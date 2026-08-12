#!/usr/bin/env bash
set -e

echo "Starting setup for TidalCycles environment..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

REPO_DIR="$PWD"

#0.a Creating a symlink from root to the app
ln -sf "$REPO_DIR" ~/tusa

# 0.b Ensure Homebrew is installed before relying on it
if ! command_exists brew ; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "Updating Homebrew..."
brew update

# 1. Install Haskell via ghcup
if ! command_exists ghc ; then
    echo "Installing Haskell via ghcup..."
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
    echo "Haskell installation complete. You may need to restart your terminal or source your shell profile."
else
    echo "Haskell already installed."
fi

# 1a. Install Python via homebrew
if ! command_exists python3 ; then
    echo "Installing Python via homebrew..."
    brew install python3
else
    echo "Python already installed."
fi

# 2. Install TidalCycles package
if ! ghc-pkg list 2>/dev/null | grep -q tidal ; then
    echo "Installing TidalCycles..."
    cabal update
    cabal install --lib tidal
else
    echo "TidalCycles already installed."
fi

# 3.a Install Nano editor
if ! command_exists nano ; then
    echo "Installing Nano editor..."
    brew install nano
else
    echo "Nano already installed."
fi

# 3.b Install Glow
if ! command_exists glow ; then
    echo "Installing Glow..."
    brew install glow
else
    echo "Glow already installed."
fi

# 3.c Install tmux
if ! command_exists tmux ; then
    echo "Installing tmux..."
    brew install tmux
else
    echo "tmux already installed."
fi

# 4. Install SuperCollider
if ! command_exists sclang ; then
    echo "Installing SuperCollider..."
    brew install --cask supercollider
else
    echo "SuperCollider already installed."
fi

# 5. Install necessary Quarks/extensions for TidalCycles
if [ ! -d ~/"Library/Application Support/SuperCollider/Extensions/SC3Plugins" ]; then
    echo "Installing sc3-plugins..."
    curl -fL https://github.com/supercollider/sc3-plugins/releases/download/Version-3.13.0/sc3-plugins-3.13.0-macOS.zip --output /tmp/sc3plugins.zip
    mkdir -p ~/"Library/Application Support/SuperCollider/Extensions/SC3Plugins"
    unzip -nq /tmp/sc3plugins.zip -d ~/"Library/Application Support/SuperCollider/Extensions/SC3Plugins"
    rm /tmp/sc3plugins.zip
    echo "sc3-plugins installed"
else
    echo "sc3-plugins already installed."
fi

echo "Installing SuperDirt and Dirt Samples Quarks..."
sclang -D <<EOL
Quarks.install("https://github.com/tidalcycles/Dirt-Samples");
Quarks.install("https://github.com/musikinformatik/SuperDirt");
Quarks.install("http://github.com/scztt/Require");

s.waitForBoot {
    "Quarks installed".postln;
    0.exit();
};
EOL

echo "Dirt Samples and SuperDirt are installed. Now everything should work."
