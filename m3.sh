#!/usr/bin/env bash

declare -A hashModules
declare -A fileModules

declare -a changes

searchDir=${1:-.}
shift

if [ -f .m3cache ]; then
    while read f; do
        IFS=":" read dir ck <<< "${f}"
        fileModules["${dir}"]="${ck}"
    done <.m3cache
fi

for D in ${searchDir}/*/; do
    ck=$(find ${D} -type f -print0 | sort -z | xargs -0 cksum | awk '{print $1;}' | cksum | awk '{print $1;}')
    hashModules["${D}"]="${ck}"
    if [ "${ck}" != "${fileModules[${D}]}" ]; then
        changes+=("${D}")
    fi
done

: > .m3cache
for key in ${!hashModules[@]}; do
    echo ${key}:${hashModules[${key}]} >> .m3cache
done

plArg=""
for key in ${!changes[@]}; do
    plArg+=",${changes[$key]}"
done

argString=""
for a in $*; do
	argString+=" $a"
done

mvn -pl ${plArg:1} -amd ${argString:1}