#/bin/bash

function setFont {
    local name size

    case $1 in
        "vim" )
            font="DejaVu Sans Mono Book"
            size="20"
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
        "docker" )
            font="Ubuntu Mono normal"
            size="20"
            ;;
        *)
            font="Ubuntu Mono normal"
            size="20"
            ;;
    esac

    local profile=$(gsettings get org.gnome.Terminal.ProfilesList default | sed -e s/\'//g)

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/ font "$font $size"
}

