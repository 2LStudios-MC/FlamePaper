#!/usr/bin/env bash

nms="net/minecraft/server"
export MODLOG=""
PS1="$"
basedir="$(cd "$1" && pwd -P)"

workdir=$basedir/work
minecraftversion=$(cat $basedir/BuildData/info.json | grep minecraftVersion | cut -d '"' -f 4)
decompiledir=$workdir/$minecraftversion

export importedmcdev=""
function import() {
  export importedmcdev="$importedmcdev $1"
  file="${1}.java"
  target="$basedir/Spigot-Server/src/main/java/$nms/$file"
  base="$decompiledir/$nms/$file"

  if [[ ! -f "$target" ]]; then
    export MODLOG="$MODLOG  Imported $file from mc-dev\n"
    echo "Copying $base to $target"
    cp "$base" "$target"
  fi
}

(
  cd $basedir/Spigot-Server/
  lastlog=$(git log -1 --oneline)
  if [[ "$lastlog" == *"mc-dev Imports"* ]]; then
    git reset --hard HEAD^
  fi
)

files=$(cat "$basedir/Spigot-Server-Patches/"* | grep "+++ b/src/main/java/net/minecraft/server/" | sort | uniq | sed 's/\+\+\+ b\/src\/main\/java\/net\/minecraft\/server\///g' | sed 's/.java//g')

nonnms=$(grep -R "new file mode" -B 1 "$basedir/Spigot-Server-Patches/" | grep -v "new file mode" | grep -oE "net\/minecraft\/server\/.*.java" | grep -oE "[A-Za-z]+?.java$" --color=none | sed 's/.java//g')
function containsElement() {
  local e
  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && return 0
  done
  return 1
}
set +e
for f in $files; do
  containsElement "$f" ${nonnms[@]}
  if [ "$?" == "1" ]; then
    if [ ! -f "$basedir/Spigot-Server/src/main/java/net/minecraft/server/$f.java" ]; then
      if [ ! -f "$decompiledir/$nms/$f.java" ]; then
        echo "ERROR!!! Missing NMS $f"
      else
        import $f
      fi
    fi
  fi
done

#import PacketPlayOutMap
#import PacketPlayOutSpawnEntity
#import AxisAlignedBB

(
  cd $basedir/Spigot-Server/
  git add src -A
  echo -e "mc-dev Imports\n\n$MODLOG" | git commit src -F -
)
