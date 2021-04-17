#!/bin/bash

PS1="$"
basedir="$(cd "$1" && pwd -P)"

function update {
    cd "$basedir/$1"
    git fetch && git reset --hard origin/master
    cd ../
    git add $1
}

update Bukkit
update CraftBukkit
