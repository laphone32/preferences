#!/usr/bin/env bash
# File: aws/os/linux.sh

function parse_date_to_epoch {
    local date_str="$1"
    date -d "$date_str" "+%s" 2>/dev/null
}
