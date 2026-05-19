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

BASE_YAYS=(
	tty-clock
	moonlight-qt
	visual-studio-code-bin
	heroic-games-launcher-bin
  protonplus
  localsend-bin
	google-chrome
	sunshine
	fcitx5-bamboo
)

BASE_PKGS=(
	sdl3 sdl3_image sdl3_ttf sdl3_mixer
  dotnet-sdk
  sdl2 openal
  freetype2
	lsd
	curl
  zsh
  unzip
  zip
	cuda
	tmux
  neovim 
	btop
  fastfetch
  clang
  cmake
  ark
  steam
  discord
  mpv
 	lact
  audacity
  tailscale
 	telegram-desktop
 	blender
  obs-studio
  spotify-launcher
	kdenlive
	filelight
	okular
	gwenview
	kclock
	elisa
	korganizer
	nerd-fonts
	qemu-full virt-manager virt-viewer dnsmasq vde2 openbsd-netcat
	fcitx5 fcitx5-qt fcitx5-gtk 
	wine
	fcitx5-configtool
  powerdevil power-profiles-daemon
)


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

# Install base tools
for yay in "${BASE_YAYS[@]}"; do
  if ! command -v "$yay" &>/dev/null; then
    echo "📦 Installing $yay..."
    install_yays "$yay"
    echo "✅ $yay installed"
  else
    echo "✅ $yay already installed"
  fi
done

for pkg in "${BASE_PKGS[@]}"; do
  if ! command -v "$pkg" &>/dev/null; then
    echo "📦 Installing $pkg..."
    install_pkg "$pkg"
    echo "✅ $pkg installed"
  else
    echo "✅ $pkg already installed"
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
sudo systemctl enable --now lactd
sudo systemctl enable --now libvirtd
sudo systemctl start libvirtd
sudo systemctl enable --now power-profiles-daemon
dotnet new install MonoGame.Templates.CSharp

# Flash spotify

echo "🎉 DONE! Logout/login lại để dùng zsh + tmux."

