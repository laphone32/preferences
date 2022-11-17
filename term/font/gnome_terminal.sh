#/bin/bash

function setTermFont {
    local name size

    case $1 in
        "vim" )
            font="Ubuntu Mono normal"
            size="23"
            ;;
        "prod" )
            font="Ubuntu Mono normal"
            size="20"
            ;;
        "uat" )
            font="Ubuntu Mono normal"
            size="20"
            ;;
        "remote" )
            font="Ubuntu Mono normal"
            size="20"
            ;;
        "container" )
            font="Ubuntu Mono normal"
            size="20"
            ;;
        *)
            font="DejaVu Sans Mono Book"
            size="20"
            ;;
    esac

    local profile=$(gsettings get org.gnome.Terminal.ProfilesList default | sed -e s/\'//g)

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/ font "$font $size"
}

