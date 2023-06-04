#!/bin/bash

PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -x

#bash
$PREFERENCES_DIR/bash/install.sh

# vim
$PREFERENCES_DIR/vim/install.sh

# git
$PREFERENCES_DIR/git/install.sh

# systemd
$PREFERENCES_DIR/systemd/install.sh

