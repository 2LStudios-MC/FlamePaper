#!/usr/bin/env bash

(
set -e
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/work"
mcver=$(cat "$basedir/BuildData/info.json" | grep minecraftVersion | cut -d '"' -f 4)
paperjar="$basedir/PaperSpigot-Server/target/paperspigot-$mcver-R0.1-SNAPSHOT.jar"
vanillajar="$workdir/$mcver/$mcver.jar"

(
    cd "$basedir/Paperclip"
    mvn clean package "-Dmcver=$mcver" "-Dpaperjar=$paperjar" "-Dvanillajar=$vanillajar"
)
cp "$basedir/Paperclip/assembly/target/paperclip-${mcver}.jar" "$basedir/Paperclip-$mcver.jar"

echo ""
echo ""
echo ""
echo "Build success!"
echo "Copied final jar to $(cd "$basedir" && pwd -P)/Paperclip-$mcver.jar"
) || exit 1
