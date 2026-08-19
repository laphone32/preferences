#!/usr/bin/env bash
# File: aws/os/macos.sh

function parse_date_to_epoch {
    local date_str="$1"
    date -j -f "%Y-%m-%dT%H:%M:%SZ" "$date_str" "+%s" 2>/dev/null || \
    date -j -f "%Y-%m-%dT%H:%M:%S%z" "$date_str" "+%s" 2>/dev/null || \
    date -j -f "%Y-%m-%d %H:%M:%S%z" "$date_str" "+%s" 2>/dev/null || \
    date -j "$date_str" "+%s" 2>/dev/null
}
