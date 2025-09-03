#!/usr/bin/env bash
set -euo pipefail

echo "[*] Starting GNOME settings installation script..."
echo "[*] This script assumes you already have a functioning install of GNOME (barebones)."
echo "[*] If you don't have GNOME installed, please install it first and then run this script."

if command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
elif command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
else
    echo "[x] No supported package manager found (pacman, dnf, apt). Exiting."
    exit 1
fi
echo "[*] Detected package manager: $PKG_MANAGER"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
    read -rp "[?] Install GNOME settings? (y/n) " yn
    case $yn in
        [Yy]* ) break ;;
        [Nn]* ) echo "[x] Script aborted. :("; exit 0 ;;
        * ) echo "[!] Please answer y or n." ;;
    esac
done
echo "[*] Continuing - Installing GNOME settings..."

while true; do
    read -rp "[?] Install distro-specific software (git, dev tools, GNOME Tweaks)? (y/n) " yn
    case $yn in
        [Yy]* )
            case $PKG_MANAGER in
                pacman)
                    echo "[*] Installing git, base-devel, and GNOME Tweaks on Arch..."
                    sudo pacman -S --needed git base-devel gnome-tweaks --noconfirm

                    git clone https://aur.archlinux.org/yay.git
                    cd yay || exit
                    makepkg -si --noconfirm
                    cd .. || exit
                    rm -rf yay
                    ;;
                dnf)
                    echo "[*] Installing git, development tools, and GNOME Tweaks on Fedora..."
                    sudo dnf install -y git @development-tools gnome-tweaks
                    ;;
                apt)
                    echo "[*] Installing git, build-essential, and GNOME Tweaks on Debian/Ubuntu..."
                    sudo apt update
                    sudo apt install -y git build-essential gnome-tweaks
                    ;;
            esac
            break
            ;;
        [Nn]* )
            echo "[*] Skipping distro-specific software install."
            break
            ;;
        * ) echo "[!] Please answer y or n." ;;
    esac
done

while true; do
    read -rp "[?] Install additional desktop software (VSCode, Vicinae, Vesktop)? (y/n) " yn
    case $yn in
        [Yy]* )
            if [ "$PKG_MANAGER" = "pacman" ]; then
                echo "[*] Installing VSCode via AUR..."
                git clone https://aur.archlinux.org/visual-studio-code-bin.git
                cd visual-studio-code-bin || exit
                makepkg -si --noconfirm
                cd .. || exit
                rm -rf visual-studio-code-bin
            else
                echo "[*] Skipping VSCode (not implemented for non-Arch distros)."
            fi

            echo "[*] Installing Vicinae..."
            if [ "$PKG_MANAGER" = "pacman" ]; then
                git clone https://aur.archlinux.org/vicinae-bin.git
                cd vicinae-bin || exit
                makepkg -si --noconfirm
                cd .. || exit
                rm -rf vicinae-bin
            else
                git clone https://github.com/vicinaehq/vicinae.git
                cd vicinae || exit
                make release
                sudo make install
                cd .. || exit
                rm -rf vicinae
            fi

            echo "[*] Enabling and starting vicinae.service for the current user..."
            systemctl --user enable --now vicinae.service
            echo "[✔] Vicinae installed and service started!"

            # Vesktop (still Arch-only)
            if [ "$PKG_MANAGER" = "pacman" ]; then
                echo "[*] Installing Vesktop via AUR..."
                git clone https://aur.archlinux.org/vesktop.git
                cd vesktop || exit
                makepkg -si --noconfirm
                cd .. || exit
                rm -rf vesktop
                echo "[✔] Vesktop installed!"
            else
                echo "[*] Skipping Vesktop (Arch-only)."
            fi

            break
            ;;
        [Nn]* )
            echo "[*] Skipping additional desktop software installation."
            break
            ;;
        * ) echo "[!] Please answer y or n." ;;
    esac
done

while true; do
    read -rp "[?] Install blur-my-shell? (y/n) " yn
    case $yn in
        [Yy]* )
            echo "[*] Installing blur-my-shell..."
            git clone https://github.com/aunetx/blur-my-shell
            cd blur-my-shell || exit
            make install
            cd .. || exit
            rm -rf blur-my-shell
            echo "[✔] blur-my-shell installed!"
            break
            ;;
        [Nn]* )
            echo "[*] Skipping blur-my-shell installation."
            break
            ;;
        * ) echo "[!] Please answer y or n." ;;
    esac
done

while true; do
    read -rp "[?] Copy all folders from dotfiles config/ to ~/.config? (y/n) " yn
    case $yn in
        [Yy]* )
            if [ -d "$SCRIPT_DIR/config" ]; then
                echo "[*] Copying config files..."
                mkdir -p "$HOME/.config"
                cp -r "$SCRIPT_DIR/config/"* "$HOME/.config/"
                echo "[✔] Config files copied!"
            else
                echo "[!] Config folder not found in script directory, skipping copy."
            fi
            break
            ;;
        [Nn]* )
            echo "[*] Skipping config copy."
            break
            ;;
        * ) echo "[!] Please answer y or n." ;;
    esac
done

while true; do
    read -rp "[?] Configure GNOME: enable blur-my-shell extension, set green accent color, and add Super+Space keybind for Vicinae? (y/n) " yn
    case $yn in
        [Yy]* )
            echo "[*] To complete the GNOME configuration, please do the following in the GNOME GUI:"
            echo "  1. Open 'Extensions' or 'GNOME Extensions' app."
            echo "  2. Enable the 'blur-my-shell' extension."
            echo "  3. Open 'Settings' → 'Appearance' and set the accent color to green."
            echo "  4. Open 'Settings' → 'Keyboard Shortcuts', create a custom shortcut:"
            echo "       Name: Vicinae"
            echo "       Command: vicinae"
            echo "       Shortcut: Super+Space"
            echo "[✔] GNOME configuration instructions displayed. Please complete manually in the GUI."
            break
            ;;
        [Nn]* )
            echo "[*] Skipping GNOME extensions, theme, and keybind setup."
            break
            ;;
        * ) echo "[!] Please answer y or n." ;;
    esac
done

echo "[✔] GNOME settings installation script completed!"
echo "[*] You may need to restart GNOME (logout/login) for some changes to take effect."
