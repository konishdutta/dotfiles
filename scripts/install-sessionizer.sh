#!/usr/bin/env bash
set -euo pipefail

# Install ThePrimeagen's upstream script at a pinned revision, then make only
# the local policy changes used by this setup. Upstream source is fetched from
# its original repository rather than redistributed here (the upstream repo
# currently has no license file).
readonly revision=7edf8211e36368c29ffc0d2c6d5d2d350b4d729b
readonly expected_sha=9242b732dd46faddeaf41ebed5e27058e9d140761908ab16b61cd6ff3b9b6b1e
bin_dir="${SESSIONIZER_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$bin_dir"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl --fail --location --silent --show-error \
  "https://raw.githubusercontent.com/ThePrimeagen/tmux-sessionizer/${revision}/tmux-sessionizer" \
  --output "$tmp"
printf '%s  %s\n' "$expected_sha" "$tmp" | sha256sum --check --status || {
  echo 'Pinned tmux-sessionizer checksum mismatch; refusing installation.' >&2
  exit 1
}
python3 - "$tmp" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
script = path.read_text()
script, count = re.subn(r"\nhydrate\(\) \{.*?\n\}\n(?=\nis_tmux_running\(\))", "\n", script, count=1, flags=re.S)
if count != 1:
    raise SystemExit("Could not find the expected upstream hydrate() function")
script = re.sub(r'^\s*hydrate "\$target" "\$selected"\n', "", script, flags=re.M)
script = re.sub(r'^\s*hydrate "\$selected_name" "\$selected"\n', "", script, flags=re.M)
old = '''if [[ "$selected" =~ ^\\[TMUX\\]\\ (.+)$ ]]; then
    selected="${BASH_REMATCH[1]}"
fi

selected_name=$(basename "$selected" | tr . _)
'''
new = '''selected_dir="$HOME"
if [[ "$selected" =~ ^\\[TMUX\\]\\ (.+)$ ]]; then
    # An existing session was selected from the picker; preserve its exact name.
    selected_name="${BASH_REMATCH[1]}"
else
    selected_dir="$(realpath -m -- "$selected")"
    base_name="$(basename "$selected_dir" | sed -E 's/[^[:alnum:]_-]+/_/g; s/^_+|_+$//g')"
    [[ -n "$base_name" ]] || base_name="project"
    path_hash="$(printf '%s' "$selected_dir" | sha256sum | cut -c1-10)"
    selected_name="${base_name:0:40}_${path_hash}"
fi
'''
if old not in script:
    raise SystemExit("Could not find the expected upstream project naming block")
script = script.replace(old, new, 1)
script = script.replace('tmux new-session -ds "$selected_name" -c "$selected"', 'tmux new-session -ds "$selected_name" -c "$selected_dir"')
path.write_text(script)
PY
install -m 755 "$tmp" "$bin_dir/tmux-sessionizer"
echo "Installed customized tmux-sessionizer to $bin_dir/tmux-sessionizer"
