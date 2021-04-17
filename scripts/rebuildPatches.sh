#!/bin/bash

PS1="$"
basedir="$(cd "$1" && pwd -P)"
echo "Rebuilding patch files from current fork state..."
git config core.safecrlf false

function cleanupPatches {
    cd "$1"
    for patch in *.patch; do
        echo "$patch"
        diffs=$(  git diff --staged "$patch" | grep --color=none -E "^(\+|\-)" | grep --color=none -Ev "(\-\-\- a|\+\+\+ b|^.index)")

        if [ "x$diffs" == "x" ] ; then
            git reset HEAD $patch >/dev/null
            git checkout -- $patch >/dev/null
        fi
    done
}

function savePatches {
    what=$1
    target=$2
    echo "Formatting patches for $what..."

    cd "$basedir/$target"
    rm -rf "$basedir/${what}-Patches/"

    git format-patch --zero-commit --full-index --no-signature --no-stat -N -o "$basedir/${what}-Patches/" upstream/upstream >/dev/null

    cd "$basedir"
    git add -A "$basedir/${what}-Patches"
    cleanupPatches "$basedir/${what}-Patches"
    echo "  Patches saved for $what to $what-Patches/"
}

savePatches Spigot-API PaperSpigot-API
savePatches Spigot-Server PaperSpigot-Server
