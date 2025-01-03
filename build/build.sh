#!/bin/bash

if [[ "$BASH_SOURCE" == /* ]]; then
    TOP=$(realpath $(dirname $BASH_SOURCE)/..)
else
    TOP=$(realpath $(pwd)/$(dirname $BASH_SOURCE)/..)
fi
cd $TOP

OUT=target

function buildPackage() {
    local packageId=$1
    local interfaceVersion=$2
    local buildDate=$(date +%Y-%m-%d)
    local tocFile=$packageId.toc

    local dstRoot=out/$packageId
    rm -rf $dstRoot
    mkdir -p $dstRoot

    local dstTocFile=$dstRoot/$packageId.toc
    cp $tocFile $dstTocFile
    sed "s/{Interface}/$interfaceVersion/" -i $dstTocFile
    sed "s/{BuildDate}/$buildDate/" -i $dstTocFile

    while read line; do
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
                    cp --parents -t $dstRoot $line
                fi
            fi
        fi
    done < $dstTocFile

    sed "s/.*\/bindings.xml/bindings.xml/" -i $dstTocFile

    pushd out >/dev/null
    zip -qr $packageId.$interfaceVersion.$buildDate.zip $packageId
    popd >/dev/null
}

function installPackage() {
    local zipFile=$1
    local wowRoot=$2

    if test ! -d "$wowRoot"; then
        echo "E: invalid wow dir [$wowRoot]"
        return
    fi

    local INTERFACE_VERSION_CLASSIC=11300
    if [[ $zipFile == *.$INTERFACE_VERSION_CLASSIC.* ]]; then
        local wowBranch="_classic_"
    else
        local wowBranch="_retail_"
    fi
    unzip -o $zipFile -d "$wowRoot/$wowBranch/Interface/AddOns" >/dev/null
}

########################################

# packages="thplus thpack.scoreboard"

# for packageId in $packages; do
#     echo "building $packageId[11300] ..."
#     buildPackage $packageId 11300
# done

# if [[ "$1" == "install" ]]; then
#     wowRoot="$HOME/app/World of Warcraft"
#     for f in `\ls out/*.zip`; do
#         echo "installing $f ..."
#         installPackage $f "$wowRoot"
#     done
# fi

########################################

function buildClean() {
    local packageName="$1"

    if test -z "$packageName"; then
        echo "E: invalid package name [$packageName]"
        return
    fi
    rm -rf $OUT/$packageName*
}

function buildPackage() {
    local packageName="$1"

    if test ! -d "$packageName"; then
        echo "E: invalid package name [$packageName]"
        return
    fi

    local buildDate=$(date +%Y%m%d)

    local dstPackageRoot=$OUT/$packageName
    local dstTocFile=$dstPackageRoot/$packageName.toc

    rm -rf $dstPackageRoot
    mkdir -p $dstPackageRoot

    cp -Lr $packageName/* -t $dstPackageRoot

    sed "s/{BuildDate}/$buildDate/" -i $dstTocFile

    # while read line; do
    #     if [[ "$line" == \#\#\ Interface:\ * ]]; then
    #         interfaceVersion=${line#"## Interface: "}
    #         break
    #     fi
    # done < $dstTocFile

    pushd $OUT >/dev/null
    zip -qr $packageName.zip $packageName
    popd >/dev/null

    echo Done building $OUT/$packageName.zip
}

function buildInstall() {
    local packageName="$1"
    local addonsDirectory="./addons/"

    if test ! -f "$OUT/$packageName.zip"; then
        echo "E: not found [$OUT/$packageName.zip]"
        return
    fi

    if test ! -d "$addonsDirectory"; then
        echo "E: invalid addons dir [$addonsDirectory]"
        return
    fi

    rm -rf $addonsDirectory/$packageName/*
    unzip $OUT/$packageName.zip -d "$addonsDirectory"
}

case "$1" in
    clean)
        buildClean QuietTweaks
        ;;
    package)
        buildPackage QuietTweaks
        ;;
    install)
        buildInstall QuietTweaks
        ;;
    "")
        buildClean QuietTweaks
        buildPackage QuietTweaks
        buildInstall QuietTweaks
        ;;
esac
