#!/bin/bash

################################################################################
# FEDORA PIMP MY SYSTEM - ULTIMATE GAMING & STREAMING SETUP
# Ziel: Annähernde Bazzite-Funktionalität auf Workstation-Basis
# Fokus: AMD Ryzen 9700X + Radeon 7800 XT
# For Fedora only
# Only Test for Fedora 43
# Mainener: @Knilix
# V1.02
################################################################################
echo "Starte System-Optimierung..."

# 0. Sudo-Check (Sofort am Start)
echo "Überprüfe Berechtigungen..."
sudo -v
# Hält das Sudo-Passwort aktuell, während das Skript läuft
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# 1. DNF & System Update (Sicheres Hinzufügen)
if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
  echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
fi

sudo dnf update -y
sudo fwupdmgr refresh && sudo fwupdmgr update

# 2. SELinux Helper
sudo dnf install -y setroubleshoot setroubleshoot-server

# 3. RPM Fusion & Multimedia Codecs (Full FFmpeg & VAAPI)
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                   https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf upgrade --refresh -y
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf install -y libva-utils vdpauinfo
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# 4. Gaming Essentials, Steam & Discord (Nativ)
sudo dnf install -y \
    steam \
    steam-devices \
    discord \
    mangohud \
    goverlay \
    gamemode \
    gamescope \
    lutris \
    wine \
    winetricks \
    liberation-fonts \
    cabextract \
    protontricks \
    flatpak

# 5. Vulkan & Mesa (32-bit & 64-bit)
sudo dnf install -y mesa-vulkan-drivers mesa-vulkan-drivers.i686 vulkan-tools vulkan-validation-layers

# 6. OBS Studio (Nativ)
sudo dnf install -y obs-studio obs-studio-plugin-vaapi

# 7. Power Management (PPD)
sudo dnf remove -y tuned tuned-ppd
sudo dnf install -y power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon

# 8. Low Latency PipeWire
mkdir -p ~/.config/pipewire/pipewire.conf.d
cat <<'EOF' > ~/.config/pipewire/pipewire.conf.d/99-lowlatency.conf
context.properties = {
    default.clock.rate = 48000
    default.clock.quantum = 512
    default.clock.min-quantum = 32
}
EOF

# 9. Konfigurationen (GameMode / MangoHud)
mkdir -p ~/.config/MangoHud
cat <<'EOF' > ~/.config/gamemode.ini
[general]
renice=10
[cpu]
governor=performance
[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0
amd_performance_level=high
EOF

cat <<'EOF' > ~/.config/MangoHud/MangoHud.conf
fps
frametime
gpu_stats
cpu_stats
ram
vram
vulkan_driver
wine
position=top-left
toggle_hud=F12
EOF

# 10. System-Tweaks (Sysctl)
sudo tee /etc/sysctl.d/90-boost.conf <<'EOF'
kernel.nmi_watchdog=0
vm.swappiness=10
vm.dirty_background_bytes=134217728
vm.dirty_bytes=268435456
fs.inotify.max_user_watches=524288
EOF
sudo sysctl --system

# 11. Flatpaks (Notepad Next, Termius, Tools)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub \
    net.davidotek.pupgui2 \
    com.heroicgameslauncher.hgl \
    com.usebottles.bottles \
    com.github.dail8859.NotepadNext \
    com.termius.Termius

echo "----------------------------------------------------------------------"
echo "Setup abgeschlossen! Alles glänzt, sogar das Highlighting auf GitHub."
echo "Bitte starte das System neu."
echo "----------------------------------------------------------------------"
