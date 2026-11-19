#!/bin/zsh
# 検索結果用の動画（3:2・文字なし・10秒ループ）を書き出す。  ./render.sh [--stills]
set -e
cd "$(dirname "$0")"
HUMAN=../../Kodo/Assets.xcassets/human_1.imageset/human_1.png
BIN=$(mktemp -d)/kodo_video
swiftc -O kodo_video.swift -o "$BIN"
if [[ "$1" == "--stills" ]]; then "$BIN" "$HUMAN" x 1920 1280 --stills output/stills; exit; fi
"$BIN" "$HUMAN" output/search_3840x2560.mp4 3840 2560   # HEVC
"$BIN" "$HUMAN" output/search_1920x1280.mp4 1920 1280   # H.264
