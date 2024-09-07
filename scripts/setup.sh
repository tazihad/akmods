#!/usr/bin/env bash

# TODO:
# - add support for switching out the kernel versions

set -oeux pipefail

### PREPARE REPOS
ARCH="$(rpm -E '%_arch')"
RELEASE="$(rpm -E '%fedora')"

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/fedora-updates-archive.repo

# enable RPMs with alternatives to create them in this image build
mkdir -p /var/lib/alternatives

# If KERNEL_VERSION is not empty, install that kernel
if [[ "${KERNEL_VERSION}" != "" ]]; then
  KERNEL_VERSION="${KERNEL_VERSION}"
  KERNEL_MAJOR_MINOR_PATCH=$(echo "${KERNEL_VERSION}" | cut -d '-' -f 1)
  KERNEL_RELEASE=$(echo "${KERNEL_VERSION}" | cut -d '-' -f 2)
  rpm-ostree override replace --experimental \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm" \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-core-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm" \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-modules-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm" \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-modules-core-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm" \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-modules-extra-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm"
fi

curl -LsSf -o /etc/yum.repos.d/fedora-coreos-pool.repo \
    https://raw.githubusercontent.com/coreos/fedora-coreos-config/stable/fedora-coreos-pool.repo

rpm-ostree install \
  kernel-devel \
  kernel-devel-matched

rpm-ostree install \
  akmods \
  mock

if [[ ! -s "/tmp/certs/private_key.priv" ]]; then
    echo "WARNING: Using test signing key. Run './generate-akmods-key' for production builds."
    cp /tmp/certs/private_key.priv{.local,}
    cp /tmp/certs/public_key.der{.local,}
fi

install -Dm644 /tmp/certs/public_key.der   /etc/pki/akmods/certs/public_key.der
install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv

# protect against incorrect permissions in tmp dirs which can break akmods builds
chmod 1777 /tmp /var/tmp

# create directories for later copying resulting artifacts
mkdir -p /var/cache/rpms/{kmods,eternal}