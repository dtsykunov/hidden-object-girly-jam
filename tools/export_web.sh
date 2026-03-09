#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-"$ROOT_DIR/dist"}"
CI_DIR="${CI_DIR:-"$ROOT_DIR/.godot-ci"}"
DOWNLOAD_DIR="$CI_DIR/downloads"
BIN_DIR="$CI_DIR/bin"
TMP_DIR="$CI_DIR/tmp"

GODOT_VERSION="${GODOT_VERSION:-4.6-stable}"
GODOT_TEMPLATE_VERSION="${GODOT_TEMPLATE_VERSION:-${GODOT_VERSION//-/.}}"
GODOT_RELEASE_BASE="${GODOT_RELEASE_BASE:-https://github.com/godotengine/godot/releases/download/$GODOT_VERSION}"
GODOT_ZIP="Godot_v${GODOT_VERSION}_linux.x86_64.zip"
GODOT_TEMPLATES_TPZ="Godot_v${GODOT_VERSION}_export_templates.tpz"

mkdir -p "$BUILD_DIR" "$DOWNLOAD_DIR" "$BIN_DIR" "$TMP_DIR"

export HOME="${GODOT_HOME:-$CI_DIR/home}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$CI_DIR/xdg/data}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$CI_DIR/xdg/config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$CI_DIR/xdg/cache}"
mkdir -p "$HOME" "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"

GODOT_BIN="${GODOT_BIN:-$BIN_DIR/godot}"
TEMPLATES_DIR="$XDG_DATA_HOME/godot/export_templates/$GODOT_TEMPLATE_VERSION"

download_if_missing() {
  local url="$1"
  local output="$2"

  if [[ -f "$output" ]]; then
    return
  fi

  local tmp_output="$output.tmp"
  rm -f "$tmp_output"
  curl --fail --location --silent --show-error "$url" --output "$tmp_output"
  mv "$tmp_output" "$output"
}

install_godot() {
  if [[ -x "$GODOT_BIN" ]]; then
    return
  fi

  local zip_path="$DOWNLOAD_DIR/$GODOT_ZIP"
  download_if_missing "$GODOT_RELEASE_BASE/$GODOT_ZIP" "$zip_path"

  rm -rf "$TMP_DIR/godot-bin"
  mkdir -p "$TMP_DIR/godot-bin"
  unzip -q "$zip_path" -d "$TMP_DIR/godot-bin"

  local extracted_bin
  extracted_bin="$(find "$TMP_DIR/godot-bin" -type f -name 'Godot_v*_linux.x86_64' | head -n 1)"
  if [[ -z "$extracted_bin" ]]; then
    echo "Unable to locate extracted Godot binary." >&2
    exit 1
  fi

  install -m 0755 "$extracted_bin" "$GODOT_BIN"
}

install_templates() {
  if [[ -f "$TEMPLATES_DIR/web_nothreads_debug.zip" && -f "$TEMPLATES_DIR/web_nothreads_release.zip" ]]; then
    return
  fi

  local tpz_path="$DOWNLOAD_DIR/$GODOT_TEMPLATES_TPZ"
  download_if_missing "$GODOT_RELEASE_BASE/$GODOT_TEMPLATES_TPZ" "$tpz_path"

  rm -rf "$TMP_DIR/export-templates" "$TEMPLATES_DIR"
  mkdir -p "$TMP_DIR/export-templates" "$TEMPLATES_DIR"
  unzip -q "$tpz_path" -d "$TMP_DIR/export-templates"

  if [[ -d "$TMP_DIR/export-templates/templates" ]]; then
    cp -R "$TMP_DIR/export-templates/templates/." "$TEMPLATES_DIR/"
  else
    cp -R "$TMP_DIR/export-templates/." "$TEMPLATES_DIR/"
  fi
}

build() {
  rm -rf "$BUILD_DIR"
  mkdir -p "$BUILD_DIR"
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --editor --quit
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --export-release Web "$BUILD_DIR/index.html"
  touch "$BUILD_DIR/.nojekyll"
}

install_godot
install_templates
build
