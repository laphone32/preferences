
# Function with first argument be the name of color scheme
if ! [ -z $ROXTERM_ID ]; then
    dbus-send --session /net/sf/roxterm/Options net.sf.roxterm.Options.SetColourScheme string:$ROXTERM_ID string:$1
fi

