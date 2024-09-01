#!/bin/sh

set -oeux pipefail

dnf install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

dnf update -y \
  --uninstall rpmfusion-free-release \
  --uninstall rpmfusion-nonfree-release \
  --install rpmfusion-free-release \
  --install rpmfusion-nonfree-release

