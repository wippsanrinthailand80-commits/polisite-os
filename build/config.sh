#!/usr/bin/env bash
# ============================================================================
# polisite-os build configuration
# ----------------------------------------------------------------------------
# Polisite OS is a gaming- and AI-first Linux distribution: we compile our
# own Linux kernel from upstream source (like Deposit OS) and assemble a
# minimal userspace. To honour "supports Ubuntu/Arch/Mint/Deposition
# installations" the userspace is glibc + dpkg + apt compatible with the
# Debian/Ubuntu ABI, but it is *assembled* (debootstrap) rather than cloned.
# It also ships its own ALP + MSX installer variants.
#
# Set any of these as environment variables to override at build time.
# ============================================================================

# --- Distro identity -------------------------------------------------------
POLISITE_NAME="polisite"
POLISITE_PRETTY="Polisite OS"
POLISITE_VERSION="0.1.0"
POLISITE_ID="polisite"
POLISITE_ID_LIKE="ubuntu debian"
POLISITE_HOME_URL="https://github.com/wippsanrinthailand80-commits/polisite-os"
POLISITE_BUG_REPORT_URL="https://github.com/wippsanrinthailand80-commits/polisite-os/issues"
POLISITE_PRIVACY_POLICY_URL="https://github.com/wippsanrinthailand80-commits/polisite-os"

# --- Target architecture ---------------------------------------------------
# x86_64 or aarch64. Override with POLISITE_ARCH.
POLISITE_ARCH="${POLISITE_ARCH:-$(uname -m)}"

# --- Kernel (compiled from upstream source, NOT from any distro) ------------
POLISITE_KERNEL_VERSION="${POLISITE_KERNEL_VERSION:-6.6.58}"   # LTS, good on old HW + gaming
POLISITE_KERNEL_URL="${POLISITE_KERNEL_URL:-https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${POLISITE_KERNEL_VERSION}.tar.xz}"
POLISITE_KERNEL_TINY="${POLISITE_KERNEL_TINY:-0}"             # 0 = defconfig (broad), 1 = tinyconfig (CI/fast)
# Build parallelism. Lower = less RAM, slower build. Default: all host cores.
POLISITE_KERNEL_JOBS="${POLISITE_KERNEL_JOBS:-$(nproc)}"

# --- Userspace (Debian/Ubuntu pool, for .deb/apt + Deposition .mlpds compat) ---
POLISITE_SUITE="${POLISITE_SUITE:-noble}"                     # Ubuntu 24.04
POLISITE_MIRROR="${POLISITE_MIRROR:-http://archive.ubuntu.com/ubuntu}"
POLISITE_PORTS_MIRROR="${POLISITE_PORTS_MIRROR:-http://ports.ubuntu.com/ubuntu-ports}"
POLISITE_COMPONENTS="${POLISITE_COMPONENTS:-main,universe}"

POLISITE_EXTRA_BASE="${POLISITE_EXTRA_BASE:-apt-utils ca-certificates gpgv \
  gnupg netplan.io systemd systemd-sysv udev openssh-server vim-tiny curl}"

POLISITE_DESKTOP_PKGS="${POLISITE_DESKTOP_PKGS:-xfce4 xfce4-terminal lightdm xfce4-goodies xorg xserver-xorg-video-all xserver-xorg-input-all}"

POLISITE_THEME_PKGS="${POLISITE_THEME_PKGS:-materia-gtk-theme papirus-icon-theme \
  fonts-noto-color-emoji}"

POLISITE_ENABLE_THAI="${POLISITE_ENABLE_THAI:-1}"
POLISITE_THAI_FONTS="${POLISITE_THAI_FONTS:-fonts-thai-tlwg fonts-noto-color-emoji \
  fonts-noto-extra}"
POLISITE_LOCALES="${POLISITE_LOCALES:-en_US.UTF-8 th_TH.UTF-8}"

# Curated apps (gaming + AI helpers are added on top in a later phase)
POLISITE_APPS="${POLISITE_APPS:-network-manager-gnome pavucontrol pulseaudio \
  udisks2 xfce4-screenshooter xarchiver gnome-font-viewer \
  ibus ibus-libthai im-config \
  bluez bluez-tools \
  plymouth plymouth-themes \
  firefox-esr}"
POLISITE_SERVICES="${POLISITE_SERVICES:-ufw}"

POLISITE_INSTALL_KERNEL_IN_ROOTFS="${POLISITE_INSTALL_KERNEL_IN_ROOTFS:-0}"

# --- Default install settings (used by the ALP/MSX installers) -------------
POLISITE_DEFAULT_HOSTNAME="${POLISITE_DEFAULT_HOSTNAME:-polisite}"
POLISITE_DEFAULT_USER="${POLISITE_DEFAULT_USER:-polisite}"
POLISITE_DEFAULT_USER_PASSWORD="${POLISITE_DEFAULT_USER_PASSWORD:-}"
POLISITE_DEFAULT_LOCALE="${POLISITE_DEFAULT_LOCALE:-en_US.UTF-8}"
POLISITE_DEFAULT_TIMEZONE="${POLISITE_DEFAULT_TIMEZONE:-UTC}"

# --- Build output locations -------------------------------------------------
POLISITE_BUILD_DIR="${POLISITE_BUILD_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output}"
POLISITE_KERNEL_OUT="${POLISITE_KERNEL_OUT:-$POLISITE_BUILD_DIR/kernel}"
POLISITE_ROOTFS_OUT="${POLISITE_ROOTFS_OUT:-$POLISITE_BUILD_DIR/rootfs}"

# Resolve the right debootstrap mirror for the arch.
polisite_mirror_for_arch() {
  case "$POLISITE_ARCH" in
    x86_64|amd64) echo "$POLISITE_MIRROR" ;;
    *)            echo "$POLISITE_PORTS_MIRROR" ;;
  esac
}

# Normalise arch for debootstrap / kernel build.
polisite_debootstrap_arch() {
  case "$POLISITE_ARCH" in
    x86_64) echo amd64 ;;
    aarch64) echo arm64 ;;
    armv7l|armhf) echo armhf ;;
    *) echo "$POLISITE_ARCH" ;;
  esac
}
