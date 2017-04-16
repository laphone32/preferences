#/bin/bash

SETTERM=xtermcontrol

export LAPHONE_DEFAULT_TERM="$SETTERM --fg=white --bg=#555557575353 --title=[LOCAL]"
export LAPHONE_PRODUCTION_TERM="$SETTERM --fg=white --bg=#725817a117a1 --title=PROD"
export LAPHONE_REMOTE_TERM="$SETTERM --fg=white --bg=#34346565a4a4 --title=REMOTE"


