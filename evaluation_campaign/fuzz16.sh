#!/usr/bin/env bash
#
# start_tmux_fuzz.sh – launch 16 commands in one tmux window (tiled layout)
#                      8 emulators × { run_fuzz.sh   +   filtered logcat }
# --------------------------------------------------------------------------

SESSION="fuzz16"          # tmux session name
WINDOW="all"              # single window that holds all 16 panes

# Abort if the session already exists.
tmux has-session -t "$SESSION" 2>/dev/null && {
    echo "tmux session '$SESSION' already exists – attach with: tmux a -t $SESSION"
    exit 1
}

# ---------------------------------------------------------------------------
# 16 shell commands, exactly as you wrote them.
# ---------------------------------------------------------------------------
cmds=(
"adb -s emulator-5554 shell 'cd /data/local/tmp && sh run_fuzz.sh'"
"adb -s emulator-5554 logcat | grep 'Binder transactions' | tee -a ~/prod/logcat_00.log"

"adb -s emulator-5556 shell 'cd /data/local/tmp && sh run_fuzz.sh'"
"adb -s emulator-5556 logcat | grep 'Binder transactions' | tee -a ~/prod/logcat_01.log"

"adb -s emulator-5558 shell 'cd /data/local/tmp && sh run_fuzz.sh'"
"adb -s emulator-5558 logcat | grep 'Binder transactions' | tee -a ~/prod/logcat_02.log"

"adb -s emulator-5560 shell 'cd /data/local/tmp && sh run_fuzz.sh'"
"adb -s emulator-5560 logcat | grep 'Binder transactions' | tee -a ~/prod/logcat_03.log"

"adb -s emulator-5562 shell 'cd /data/local/tmp && sh run_fuzz.sh'"
"adb -s emulator-5562 logcat | grep 'Binder transactions' | tee -a ~/prod/logcat_04.log"

"adb -s emulator-5564 shell 'cd /data/local/tmp && sh run_fuzz.sh'"
"adb -s emulator-5564 logcat | grep 'Binder transactions' | tee -a ~/prod/logcat_05.log"

"adb -s emulator-5566 shell 'cd /data/local/tmp && sh run_fuzz.sh'"
"adb -s emulator-5566 logcat | grep 'Binder transactions' | tee -a ~/prod/logcat_06.log"

"adb -s emulator-5568 shell 'cd /data/local/tmp && sh run_fuzz.sh'"
"adb -s emulator-5568 logcat | grep 'Binder transactions' | tee -a ~/prod/logcat_07.log"
)

# ---------------------------------------------------------------------------
# Create the tmux session & window, run the commands
# ---------------------------------------------------------------------------
tmux new-session  -d  -s "$SESSION"  -n "$WINDOW"

# First command goes into the initial pane (pane 0 in window 0)
# tmux send-keys   -t "$SESSION":"$WINDOW".0  "${cmds[0]}"  C-m

# Add panes for the remaining commands
for i in $(seq 1 15); do
    # Split the *current* window; tmux chooses split direction, we tile later.
    tmux split-window -t "$SESSION":"$WINDOW" -h
    tmux select-layout -t "$SESSION":"$WINDOW" tiled            # keep grid tidy
    # tmux send-keys     -t "$SESSION":"$WINDOW".${i} "${cmds[$i]}" C-m
done

# Final tidy-up and focus the first pane for good measure
tmux select-layout -t "$SESSION":"$WINDOW" tiled
tmux select-pane   -t "$SESSION":"$WINDOW".0

# Attach so you see everything immediately
tmux attach -t "$SESSION"

