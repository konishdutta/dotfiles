#!/usr/bin/env bash
# Disposable end-to-end test. Uses a private tmux socket and /tmp save directory.
set -euo pipefail
TMUX_BIN="$(command -v tmux)"
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SESSIONIZER_BIN="${SESSIONIZER_BIN:-$HOME/.local/bin/tmux-sessionizer}"
SOCKET="codex-tmux-test-$$"
WORK="$(mktemp -d)"
CONF="$WORK/tmux.conf"
CLIENT_PID=""
cleanup() {
  if [[ -n "$CLIENT_PID" ]]; then kill "$CLIENT_PID" 2>/dev/null || true; wait "$CLIENT_PID" 2>/dev/null || true; fi
  "$TMUX_BIN" -L "$SOCKET" kill-server 2>/dev/null || true
  rm -rf "$WORK"
}
trap cleanup EXIT

mkdir -p "$WORK/one/duplicate/sub" "$WORK/two/duplicate" "$WORK/fakebin"
printf 'fixture A\n' > "$WORK/one/duplicate/a.py"
printf 'fixture B\n' > "$WORK/two/duplicate/b.py"
printf 'echo must-not-run > %s\n' "$WORK/template-ran" > "$WORK/one/duplicate/.tmux-sessionizer"
python3 - "$CONFIG_DIR/tmux.conf" "$CONF" "$WORK/resurrect" <<'PY'
from pathlib import Path
import sys
source = Path(sys.argv[1]).read_text()
source = source.replace("set -g @continuum-save-interval '5'", "set -g @continuum-save-interval '1'")
source = source.replace("set -g @resurrect-capture-pane-contents 'on'", "set -g @resurrect-capture-pane-contents 'on'\nset -g @resurrect-dir '" + sys.argv[3] + "'")
Path(sys.argv[2]).write_text(source)
PY
cat > "$WORK/fakebin/fzf" <<'FZF'
#!/usr/bin/env bash
cat >/dev/null
printf '%s\n' "$SESSIONIZER_PICK"
FZF
chmod +x "$WORK/fakebin/fzf"

# Start a fresh, isolated server using the real config and private save path.
"$TMUX_BIN" -L "$SOCKET" -f "$CONF" new-session -d -s seed -c "$WORK"
# A real client is needed for sessionizer switch-client and status-right autosave.
python3 - "$SOCKET" seed > /dev/null 2>&1 <<'PYCLIENT' &
import os, pty, select, signal, sys
pid, fd = pty.fork()
if pid == 0:
    os.environ["TERM"] = "xterm-256color"
    os.execvp("tmux", ["tmux", "-L", sys.argv[1], "attach-session", "-t", sys.argv[2]])
def stop(*_):
    try: os.kill(pid, signal.SIGTERM)
    except ProcessLookupError: pass
    raise SystemExit(0)
signal.signal(signal.SIGTERM, stop)
while True:
    ready, _, _ = select.select([fd], [], [], 0.5)
    if ready:
        try: os.read(fd, 65536)
        except OSError: break
PYCLIENT
CLIENT_PID=$!
sleep 1
if ! kill -0 "$CLIENT_PID" 2>/dev/null; then echo 'PTY client failed to start'; exit 1; fi
"$TMUX_BIN" -L "$SOCKET" set-environment -g PATH "$WORK/fakebin:$PATH"
"$TMUX_BIN" -L "$SOCKET" set-environment -g SESSIONIZER_PICK "$WORK/one/duplicate"
"$TMUX_BIN" -L "$SOCKET" run-shell "$SESSIONIZER_BIN"
"$TMUX_BIN" -L "$SOCKET" set-environment -g SESSIONIZER_PICK "$WORK/two/duplicate"
"$TMUX_BIN" -L "$SOCKET" run-shell "$SESSIONIZER_BIN"
NAME_A="duplicate_$(printf '%s' "$WORK/one/duplicate" | sha256sum | cut -c1-10)"
NAME_B="duplicate_$(printf '%s' "$WORK/two/duplicate" | sha256sum | cut -c1-10)"
"$TMUX_BIN" -L "$SOCKET" has-session -t "$NAME_A"
"$TMUX_BIN" -L "$SOCKET" has-session -t "$NAME_B"
[[ "$NAME_A" != "$NAME_B" ]]
"$TMUX_BIN" -L "$SOCKET" rename-window -t "$NAME_A:1" editor
[[ ! -e "$WORK/template-ran" ]]

# Arrange arbitrary user-created layouts, then revisit a project without changing it.
"$TMUX_BIN" -L "$SOCKET" split-window -h -t "$NAME_A:1" -c "$WORK/one/duplicate/sub"
"$TMUX_BIN" -L "$SOCKET" new-window -d -t "$NAME_A" -n tests -c "$WORK/one/duplicate"
"$TMUX_BIN" -L "$SOCKET" select-window -t "$NAME_A:1"
"$TMUX_BIN" -L "$SOCKET" select-pane -t "$NAME_A:1.2"
"$TMUX_BIN" -L "$SOCKET" resize-pane -Z -t "$NAME_A:1.2"
"$TMUX_BIN" -L "$SOCKET" set-environment -g SESSIONIZER_PICK "$WORK/one/duplicate"
"$TMUX_BIN" -L "$SOCKET" run-shell "$SESSIONIZER_BIN"
[[ "$("$TMUX_BIN" -L "$SOCKET" display-message -p -t "$NAME_A" '#{session_windows}')" == 2 ]]
"$TMUX_BIN" -L "$SOCKET" switch-client -t "$NAME_A"

# Manual save, then change the layout and verify Continuum saves within its
# isolated one-minute test interval. A PTY client keeps status-right ticking.
"$TMUX_BIN" -L "$SOCKET" run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh"
SAVE="$WORK/resurrect/last"
for _ in $(seq 1 50); do [[ -s "$SAVE" ]] && break; sleep 0.1; done
[[ -s "$SAVE" ]]
rg -F "$NAME_A" "$SAVE" >/dev/null
rg -F "$NAME_B" "$SAVE" >/dev/null
BASELINE="$(stat -c %Y "$SAVE")"
"$TMUX_BIN" -L "$SOCKET" new-window -d -t "$NAME_A" -n autosaved -c "$WORK/one/duplicate"
# The same PTY client remains attached while Continuum evaluates status-right.
sleep 1
if ! kill -0 "$CLIENT_PID" 2>/dev/null; then echo 'PTY client stopped'; exit 1; fi
for _ in $(seq 1 100); do
  if [[ "$(stat -c %Y "$SAVE" 2>/dev/null || echo 0)" -gt "$BASELINE" ]] && rg -F 'autosaved' "$SAVE" >/dev/null 2>&1; then break; fi
  sleep 1
done
rg -F 'autosaved' "$SAVE" >/dev/null || { echo 'Continuum did not save the changed layout within the one-minute test interval'; exit 1; }

# Simulate a server restart. Only this private socket and /tmp save directory
# are touched; Continuum must restore the just-saved work automatically.
kill "$CLIENT_PID" 2>/dev/null || true
wait "$CLIENT_PID" 2>/dev/null || true
CLIENT_PID=""
"$TMUX_BIN" -L "$SOCKET" kill-server
"$TMUX_BIN" -L "$SOCKET" -f "$CONF" new-session -d -s startup_trigger -c "$WORK"
for _ in $(seq 1 30); do
  if "$TMUX_BIN" -L "$SOCKET" has-session -t "$NAME_A" 2>/dev/null && "$TMUX_BIN" -L "$SOCKET" has-session -t "$NAME_B" 2>/dev/null; then break; fi
  sleep 1
done
"$TMUX_BIN" -L "$SOCKET" has-session -t "$NAME_A"
"$TMUX_BIN" -L "$SOCKET" has-session -t "$NAME_B"
[[ "$("$TMUX_BIN" -L "$SOCKET" display-message -p -t "$NAME_A:1" '#{window_name}')" == editor ]]
[[ "$("$TMUX_BIN" -L "$SOCKET" display-message -p -t "$NAME_A:2" '#{window_name}')" == tests ]]
[[ "$("$TMUX_BIN" -L "$SOCKET" display-message -p -t "$NAME_A:3" '#{window_name}')" == autosaved ]]
[[ "$("$TMUX_BIN" -L "$SOCKET" display-message -p -t "$NAME_A:1.2" '#{pane_current_path}')" == "$WORK/one/duplicate/sub" ]]
[[ "$("$TMUX_BIN" -L "$SOCKET" display-message -p -t "$NAME_A" '#{window_index}')" == 1 ]]
[[ "$("$TMUX_BIN" -L "$SOCKET" display-message -p -t "$NAME_A:1.2" '#{pane_active}')" == 1 ]]
[[ "$("$TMUX_BIN" -L "$SOCKET" display-message -p -t "$NAME_A:1" '#{window_zoomed_flag}')" == 1 ]]
WIDTHS="$("$TMUX_BIN" -L "$SOCKET" list-panes -t "$NAME_A:1" -F '#{pane_width}' | sort -n)"
[[ "$(wc -l <<<"$WIDTHS")" == 2 ]]
[[ "$("$TMUX_BIN" -L "$SOCKET" display-message -p -t "$NAME_B:1.1" '#{pane_current_path}')" == "$WORK/two/duplicate" ]]
printf '%s\n' 'ISOLATED_SESSIONIZER_OK' 'CONTINUUM_AUTOSAVE_OK' 'SERVER_RESTART_RESTORE_OK' 'LAYOUT_CWD_ACTIVE_WINDOW_PANE_ZOOM_OK'
