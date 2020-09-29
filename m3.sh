#!/usr/bin/env bash

declare -A hashModules
declare -A fileModules

declare -a changes

searchDir=${1:-.}

while read f; do
    IFS=":" read dir ck <<< "${f}"
    fileModules["${dir}"]="${ck}"
done <.m3cache

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

for key in ${!changes[@]}; do
    echo ${changes[$key]}
done