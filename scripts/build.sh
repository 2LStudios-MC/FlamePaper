#!/usr/bin/env bash

(
set -e
basedir="$(cd "$1" && pwd -P)"
gitcmd="git -c commit.gpgsign=false"

cd "$basedir"

($gitcmd submodule update --init \
  && ./scripts/remap.sh $basedir \
  && ./scripts/decompile.sh $basedir \
  && ./scripts/init.sh $basedir \
  && ./scripts/applyPatches.sh $basedir) || (
    echo "Failed to build Paper"
    exit 1
) || exit 1

case "$2" in
    "-j" | "--jar")
        mvn clean install
    ;;
    "-i" | "--install")
        mvn clean \
          org.apache.maven.plugins:maven-source-plugin:2.1.2:jar-no-fork \
          org.apache.maven.plugins:maven-javadoc-plugin:2.7:jar \
          install \
          -DexcludePackageNames="net.minecraft.*" \
          -Dadditionalparam="-Xdoclint:none"
          # excludePackageNames - Exclude the minecraft package from javadocs to fix some issues
          # additionalparam - Disable doc linting otherwise it wont compile
    ;;
esac
) || exit 1
