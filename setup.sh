#!/usr/bin/env bash
set -e

DOTFILES_REPO="https://github.com/alecsandrei/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "Installing git"
sudo apt update -y
sudo apt install -y git

echo "Cloning dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "Dotfiles repo already exists"
fi

echo "Checking out dotfiles"
git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout || (
    echo "Backing up conflicting files"
    mkdir -p "$HOME/.dotfiles-backup"
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout 2>&1 \
      | grep -E "^\s+\." \
      | awk '{print $1}' \
      | while read -r file; do
            mv "$HOME/$file" "$HOME/.dotfiles-backup/"
        done

    git submodule update --init --recursive
    git -C ~/.config/nvim/ checkout master

    echo "Retrying checkout"
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout
)

echo "Configuring git status visibility"
git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config status.showUntrackedFiles no

echo "Installing zsh and curl"
sudo apt install -y zsh curl

echo "Installing Oh My Zsh"
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "Installing Neovim"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

echo "Installing development dependencies"
sudo apt install -y xclip
sudo apt install -y python3-venv
sudo apt install -y python3-pip
sudo apt install -y cmake
sudo apt install -y clang
sudo apt install -y luarocks
sudo apt install -y fzf
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "Installing nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
source "$HOME/.zshrc"
nvm install node

echo "Installing rust"
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"
cargo install --locked tree-sitter-cli
cargo install ripgrep

npm install -g markdownlint

echo "Installing tombi"
curl -fsSL https://tombi-toml.github.io/tombi/install.sh | sh

echo "Installing fonts"
source "$HOME/.local/scripts/font_installer.sh" ZedMono

echo "Installing other applications"
sudo apt install -y variety
sudo apt install -y tmux
sudo apt install -y virtualbox-qt

echo "Installing assistant agents"
curl -fsSL https://opencode.ai/install | bash
npm install -g @github/copilot
npm install -g @openai/codex

echo "Installing GitHub CLI"
(type -p wget >/dev/null || sudo apt install wget -y)
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -nv -O /tmp/githubcli.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg
sudo mv /tmp/githubcli.gpg /etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

echo "Configuring QGIS repository"
KEYRING_DIR="/etc/apt/keyrings"
KEYRING="$KEYRING_DIR/qgis-archive-keyring.gpg"
SOURCES_FILE="/etc/apt/sources.list.d/qgis.sources"

sudo mkdir -p -m 755 "$KEYRING_DIR"
sudo wget -O "$KEYRING" "https://download.qgis.org/downloads/qgis-archive-keyring.gpg"

. /etc/os-release
CODENAME="$VERSION_CODENAME"

sudo tee "$SOURCES_FILE" >/dev/null <<EOF
Types: deb deb-src
URIs: https://qgis.org/debian
Suites: ${CODENAME}
Architectures: amd64
Components: main
Signed-By: ${KEYRING}
EOF

sudo apt update
sudo apt install -y qgis

echo "Installation complete"

