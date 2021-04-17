#!/bin/bash

PS1="$"
basedir="$(cd "$1" && pwd -P)"
echo "Rebuilding Forked projects.... "
gitcmd="git -c commit.gpgsign=false"

# Windows detection to workaround ARG_MAX limitation
windows="$([[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]] && echo "true" || echo "false")"

function applyPatch {
    what=$1
    target=$2
    branch=$3

    cd "$basedir/$what"
    git fetch
    git branch -f upstream "$branch" >/dev/null

    cd "$basedir"
    if [ ! -d  "$basedir/$target" ]; then
        git clone "$what" "$target"
    fi
    cd "$basedir/$target"

    echo "Resetting $target to $what..."
    git remote rm upstream > /dev/null 2>&1
    git remote add upstream "$basedir/$what" >/dev/null 2>&1
    git checkout master 2>/dev/null || git checkout -b master
    git fetch upstream >/dev/null 2>&1
    git reset --hard upstream/upstream

    echo "  Applying patches to $target..."

    rm -f ".git/patch-apply-failed"
    git config commit.gpgsign false
    git am --abort >/dev/null 2>&1

    # Special case Windows handling because of ARG_MAX constraint
    if [[ $windows == "true" ]]; then
        echo "  Using workaround for Windows ARG_MAX constraint"
        find "$basedir/${what_name}-Patches/"*.patch -print0 | xargs -0 git am --3way --ignore-whitespace
    else
        git am --3way --ignore-whitespace "$basedir/${what}-Patches/"*.patch
    fi
    if [ "$?" != "0" ]; then
        echo "  Something did not apply cleanly to $target."
        echo "  Please review above details and finish the apply then"
        echo "  save the changes with rebuildPatches.sh"
        exit 1
    else
        echo "  Patches applied cleanly to $target"
    fi
}

applyPatch Bukkit Spigot-API HEAD && applyPatch CraftBukkit Spigot-Server patched

cd $basedir
echo "Importing MC Dev"
$basedir/scripts/importmcdev.sh $basedir

applyPatch Spigot-API PaperSpigot-API HEAD && applyPatch Spigot-Server PaperSpigot-Server HEAD
