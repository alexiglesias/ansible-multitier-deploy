#!/usr/bin/env bash
# Tear down all VMs and remove generated files for ansible-multitier-deploy.

set -euo pipefail

echo "==> Destroying Vagrant VMs..."
vagrant destroy -f

echo "==> Removing .vagrant directory..."
rm -rf .vagrant

echo "==> Removing editor swap files and OS noise..."
rm -f .README.md.swp .DS_Store

echo "==> Done. Run 'vagrant up' to start fresh."
