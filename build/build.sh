#!/bin/bash

if [[ "$BASH_SOURCE" == /* ]]; then
    TOP=$(realpath $(dirname $BASH_SOURCE)/..)
else
    TOP=$(realpath $(pwd)/$(dirname $BASH_SOURCE)/..)
fi
cd $TOP

OUT=target
WOW_DIRECTORY=wow

function packageAddon() {
    local addon=$1

    if test ! -f "$addon.toc"; then
        echo "E: invalid addon name [$addon]"
        return
    fi

    local buildDate=$(date +%Y-%m-%d)
    local dstRoot=$OUT/$addon
    local dstTocFile=$dstRoot/$addon.toc

    rm -rf $dstRoot
    mkdir -p $dstRoot

    cp "$addon.toc" $dstTocFile
    sed "s/{BuildDate}/$buildDate/" -i $dstTocFile

    # while read line; do
    #     if [[ "$line" == \#\#\ Interface:\ * ]]; then
    #         interfaceVersion=${line#"## Interface: "}
    #         break
    #     fi
    # done < $dstTocFile

    while read -r line; do
        if [[ "$line" =~ ^[A-Za-z0-9#][^#] ]]; then
            if [[ "$line" == \#* ]]; then
                if [[ "$line" == \#res/* ]]; then
                    line=${line#"#"}
                    cp --parents -t $dstRoot $line
                fi
            else
                if test `basename $line` == "bindings.xml"; then
                    cp -t $dstRoot $line
                else
                    local s="${line//\\//}"
                    cp -r --parents -t $dstRoot $s
                fi
            fi
        fi
    done < $dstTocFile

    sed "s/.*\/bindings.xml/bindings.xml/" -i $dstTocFile

    pushd $OUT >/dev/null
    zip -qr $addon.zip $addon
    popd >/dev/null
}

function installAddon() {
    local addon=$1
    local wowD=$2

    if test ! -f "$OUT/$addon.zip"; then
        echo "E: not found [$OUT/$addon.zip]"
        return
    fi

    if test ! -d "$wowD/Interface/AddOns"; then
        echo "E: invalid WoW directory [$wowD]"
        return
    fi

    rm -rf "$wowD/Interface/AddOns"/$addon/*
    unzip $OUT/$addon.zip -d "$wowD/Interface/AddOns"
}

case "$1" in
    package)
        packageAddon r2d2
        ;;
    install)
        installAddon r2d2 $WOW_DIRECTORY
        ;;
    "")
        packageAddon r2d2
        installAddon r2d2 $WOW_DIRECTORY
        ;;
esac
