#!/usr/bin/env bash
# build-thor.sh - build TheAirBlow's Thor (Odin protocol, Linux) from source
# for this machine, so the reset works WITHOUT downloading SamFW or any
# prebuilt blob. Output: $DEST/TheAirBlow.Thor.Shell (framework-dependent).
set -euo pipefail
DEST="${1:-$HOME/.local/share/scr01/thor}"
SRC="$(mktemp -d)"
command -v git >/dev/null || { echo "missing: git"; exit 1; }
if ! command -v dotnet >/dev/null; then
  echo "Installing .NET SDK 8 (sudo apt)..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y dotnet-sdk-8.0
fi
RID="linux-$(uname -m | sed 's/aarch64/arm64/;s/x86_64/x64/')"
echo "Cloning Thor and building for $RID ..."
git clone -q --depth 1 https://github.com/Samsung-Loki/Thor "$SRC/Thor"
cd "$SRC/Thor"
# Project targets net9.0; retarget to the apt-provided net8.0 runtime.
sed -i 's|<TargetFramework>net9.0</TargetFramework>|<TargetFramework>net8.0</TargetFramework>|' \
  TheAirBlow.Thor.Library/*.csproj TheAirBlow.Thor.Shell/*.csproj
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
mkdir -p "$DEST"
dotnet publish TheAirBlow.Thor.Shell/TheAirBlow.Thor.Shell.csproj \
  -c Release -r "$RID" --self-contained false -o "$DEST"
rm -rf "$SRC"
echo "Thor built at: $DEST/TheAirBlow.Thor.Shell"
