#!/usr/bin/env bash
# install-font.sh
# Usage: ./install-font.sh [FontName]
# Example: ./install-font.sh FiraCode

# Set font name from argument, default to AdwaitaMono
FONT_NAME="${1:-AdwaitaMono}"

# Destination directory
FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"

# Download the latest release from Nerd Fonts
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.tar.xz"
echo "Downloading $FONT_NAME from $URL..."
curl -LO "$URL"

# Extract to fonts directory
echo "Extracting to $FONTS_DIR..."
tar -xf "${FONT_NAME}.tar.xz" -C "$FONTS_DIR"

# Remove archive
rm "${FONT_NAME}.tar.xz"

# Refresh font cache
fc-cache -fv

echo "$FONT_NAME installed successfully!"

