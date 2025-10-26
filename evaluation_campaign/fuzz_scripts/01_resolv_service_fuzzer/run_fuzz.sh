#!/system/bin/sh
# run_fuzzers.sh – sequentially run each fuzzer for 30 minutes

cd "$(dirname "$0")" || exit 1


###############################################################################
# List of fuzzers (run in this order)
###############################################################################
FUZZERS="
resolv_service_fuzzer_autogen
"


###############################################################################
# Shared settings
###############################################################################
FORK=4                # number of workers
TIME=43200            # 12 hours
TIMEOUT=5             # per-unit execution timeout, seconds
SEEDS_BASE="seeds"    # seed corpora
ARTIFACTS_BASE="artifacts"   # crash artifacts


###############################################################################
# Run each fuzzer
###############################################################################
for f in $FUZZERS; do
    echo
    echo "=====================  $f  ====================="
    echo

    # Per-fuzzer seed and artifact directories
    SD="$SEEDS_BASE/$f"
    AD="$ARTIFACTS_BASE/$f"

    rm -rf "$SD" "$AD"
    mkdir -p "$SD" "$AD"

    LOG="$f.log"

    "./$f" \
        -fork="$FORK" \
        -ignore_crashes=1 \
        -max_total_time="$TIME" \
        -timeout="$TIMEOUT" \
        -artifact_prefix="$AD/" \
        "$SD" 2>&1 | while IFS= read -r line; do
            printf '%s %s\n' "$(date '+%m-%d %H:%M:%S.%3N')" "$line"
        done | tee -a "$LOG"
done