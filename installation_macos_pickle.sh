#!/usr/bin/env bash
set -e

echo "Starting setup for TidalCycles environment..."

SC3_PLUGINS_VERSION="3.13.0"
FLUCOMA_VERSION="1.0.9"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_brew() {
    if ! command_exists brew; then
        echo "Homebrew not found. Please install it first:"
        echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
}

brew_install_if_missing() {
    local cmd="$1"
    local package="$2"
    if ! command_exists "$cmd"; then
        echo "Installing $package..."
        brew install $package
    else
        echo "$package already installed."
    fi
}

echo "Updating Homebrew..."
brew update -q

check_brew

ln -sf "$PWD" ~/tcii

./config-util/setIcon.sh config-util/logo.png tcii.app
./config-util/setIcon.sh config-util/logo.png tcii.command

if ! command_exists ghc; then
    echo "Installing Haskell via ghcup..."
    curl -fsSL https://get-ghcup.haskell.org | sh
    echo "Haskell installation complete. You may need to restart your terminal or source your profile."
else
    echo "Haskell already installed."
fi

brew_install_if_missing python3 "python3"

if ! ghc-pkg list 2>/dev/null | grep -q tidal; then
    echo "Installing TidalCycles..."
    cabal update
    cabal install --lib tidal
else
    echo "TidalCycles already installed."
fi

brew_install_if_missing nano "nano"
brew_install_if_missing glow "glow"
brew_install_if_missing tmux "tmux"

if ! command_exists sclang; then
    echo "Installing SuperCollider..."
    brew install --cask supercollider
else
    echo "SuperCollider already installed."
fi

echo "Installing SuperCollider extensions..."

curl -fLsSL "https://github.com/supercollider/sc3-plugins/releases/download/Version-${SC3_PLUGINS_VERSION}/sc3-plugins-${SC3_PLUGINS_VERSION}-macOS.zip" -o /tmp/sc3plugins.zip
mkdir -p ~/Library/Application\ Support/SuperCollider/Extensions/SC3Plugins
unzip -nq /tmp/sc3plugins.zip -d ~/Library/Application\ Support/SuperCollider/Extensions/SC3Plugins
rm -f /tmp/sc3plugins.zip
echo "sc3-plugins installed"

curl -fLsSL "https://github.com/flucoma/flucoma-sc/archive/refs/tags/v${FLUCOMA_VERSION}.zip" -o /tmp/flucoma-sc.zip
mkdir -p ~/Library/Application\ Support/SuperCollider/Extensions/Flucoma
unzip -nq /tmp/flucoma-sc.zip -d ~/Library/Application\ Support/SuperCollider/Extensions/Flucoma/
rm -f /tmp/flucoma-sc.zip
echo "flucoma installed"

echo "Installing SuperDirt and Dirt Samples Quarks..."
sclang -D <<EOL
Quarks.install("https://github.com/tidalcycles/Dirt-Samples");
Quarks.install("https://github.com/musikinformatik/SuperDirt");

s.waitForBoot {
    "Quarks installed".postln;
    0.exit();
};
EOL

echo "Verifying installation..."
MISSING=()
for cmd in ghc python3 cabal nano glow tmux sclang; do
    if ! command_exists "$cmd"; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "All dependencies installed successfully!"
else
    echo "Warning: The following commands were not found: ${MISSING[*]}"
    echo "You may need to restart your terminal."
fi

echo "Setup complete. Now everything should work."
