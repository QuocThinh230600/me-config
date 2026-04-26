set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
echo "⣶⡯⢳⣆⠄⠄⠄⠄⣍⡛⠿⢿⡿⢋⠄⠄⠄⢜⣿⡿⡟⢿"
echo "⣿⠿⣸⠟⠄⠄⠠⡄⠢⣉⣁⢀⣼⣿⡿⢅⣾⣎⠈⠃⠋⢸⣿⣄"
echo "⡟⣾⣿⡲⣷⡀⠄⢟⣂⡀⢙⣰⣭⣾⣿⣿⣿⣿⣆⠄⠄⠠⣬⠛⢿⣄"
echo "⣿⣿⣿⣿⠈⣧⠠⢈⣿⣿⣿⡿⢿⣿⢰⢟⣯⣷⣿⣿⣿⣿⣷⣶⣤⡉⠻⣄"
echo "⣾⣿⣿⠟⠄⣿⣇⠄⠄⢻⣿⣷⣦⣬⡘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠘⣿⡄"
echo "⠉⠄⠄⠄⢰⣿⣿⡆⠄⠄⠙⢿⣿⣿⣿⣿⣎⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠸⣷"
echo "⠄⠄⠄⠄⣿⣿⣿⡇⠄⠄⠄⠄⠙⢿⣿⣿⣿⣧⢹⣿⣿⣿⣿⣿⣿⡿⠃⠄⢀⠟"
echo "⢀⠄⠄⠄⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄⠙⢿⣿⣿⠄⣿⣿⣿⡿⠟⠋⠄⠄⢀"
echo "⣰⠄⠄⠄⢿⣿⣿⣇⠄⠄⠄⠄⠄⠄⠄⠄⠉⠛⠐⠛⠝⠃⠄⠄⠄⣀"
echo "⢻⠄⠄⠄⠈⢿⣿⣿⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣠"
echo "⣿⣄⠁⠄⠄⠄⠉⠛⠓⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣠⣾"
echo " "
echo "======AUTO INSTALL APP======"
echo "📂 Script dir: $SCRIPT_DIR"
echo "🏠 Home dir  : $HOME_DIR"
echo "============================"
echo " "

BASE_PKGS=(curl zsh unzip zip tmux neovim btop fastfetch clang cmake ark steam discord mpv lact audacity tailscale telegram-desktop blender obs-studio spotify-launcher docker lazydocker)
BASE_YAYS=(tty-clock sunshine moonlight-qt visual-studio-code-bin heroic-games-launcher-bin protonplus localsend-bin)

# Detect package manager
install_pkg() {
  if command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm "$@"
  else
    echo "❌ Unsupported package manager"
    exit 1
  fi
}

install_yays() {
  if command -v yay &>/dev/null; then
    yay -S --noconfirm "$@"
  else
    echo "❌ Unsupported package manager"
    exit 1
  fi
}

# Auto Update
echo "============================"
echo "🎮 Enabling multilib for Steam..."
sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
sudo pacman -Syu --noconfirm
echo "============================"
# Install Yay
if ! command -v yay &>/dev/null; then
  echo "📦 Installing yay..."
  install_pkg git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay || exit
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
  echo "✅ Git Base-Devel Yay installed"
else
  echo "✅ Git Base-Devel Yay already installed"
fi

# Install base tools
for pkg in "${BASE_PKGS[@]}"; do
  if ! command -v "$pkg" &>/dev/null; then
    echo "📦 Installing $pkg..."
    install_pkg "$pkg"
    echo "✅ $pkg installed"
  else
    echo "✅ $pkg already installed"
  fi
done

for yay in "${BASE_YAYS[@]}"; do
  if ! command -v "$yay" &>/dev/null; then
    echo "📦 Installing $yay..."
    install_yays "$yay"
    echo "✅ $yay installed"
  else
    echo "✅ $yay already installed"
  fi
done

# Install Oh My Zsh
if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
  echo "✨ Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed"
fi

# Copy .zshrc
if [ -f "$SCRIPT_DIR/zsh/.zshrc" ]; then
  echo "📄 Copying .zshrc..."
  cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME_DIR/.zshrc"
else
  echo "⚠️ zsh/.zshrc not found"
fi

# tmux config
if [ -f "$SCRIPT_DIR/tmux/.tmux.conf" ]; then
  cp "$SCRIPT_DIR/tmux/.tmux.conf" "$HOME_DIR/.tmux.conf"
  echo "✅ .tmux.conf copied"
else
  echo "⚠️ tmux/.tmux.conf not found"
fi

# Change default shell
if [ "$SHELL" != "$(command -v zsh)" ]; then
  echo "🔁 Changing default shell to zsh..."
  chsh -s "$(command -v zsh)"
fi

echo "⚙️ Enabling services..."
systemctl --user enable --now sunshine
sudo systemctl enable --now tailscaled
sudo systemctl enable --now docker
sudo systemctl enable --now lactd

# Flash spotify
bash <(curl -sSL https://spotx-official.github.io/run.sh)

echo "🎉 DONE! Logout/login lại để dùng zsh + tmux."

