#!/bin/bash
# wolfy - bootleg wolfram|alpha cli frontend written in bash
# requirements: curl, jq

# w|a usually needs just an appid to function, but we're going to be using the
# appid found in mathematica, which requires a signature. luckily a pastebin
# from 2012 contained both the appid AND how the # signature is generated, so
# we don't have to do any manual labour! the signature is generated like so:
#
# <key>appid<appid><query parameters sorted alphabetically with ?,&,= removed>
#
# you then get the md5 checksum of that string.
# as you can see, it's ugly.
# onto the script!

## api server
server="api.wolframalpha.com"

## key and appid from mathematica
key="gC6sz9fxmosyGvwS"
appid="U2YPK6-9K5JY5YK6Y"

## options
# full - full results (json)
# short - short answers (text)
# simple - image output (gif)

if [[ "$1" == "full" ]]; then
  base="v2/query"
fi

if [[ "${1}" == "short" ]]; then
  base="v1/spoken"
fi

if [[ "${1}" == "simple" ]]; then
  if [ -t 1 ]; then
    echo simple output specified without pipe, exiting
    exit 1
  fi
  base="v1/simple"
fi

if [[ -z "${base}" ]]; then
  echo option not specified, specfiy one of the following:
  echo 'full - full results (json)'
  echo 'short - short answers (text)'
  echo 'simple - image output (gif)'
  exit 1
fi

## get rid of the first argument so we can just type our question after
## clarifying which output we want
shift 1

## Parse input and make it URL safe
input=$(echo "${*}" | jq -sRr @uri)

## response output (json,xml)
output="json"

## signature for query
message="${key}appid${appid}input${input}output${output}"
digest=$(echo -n "${message}" | md5sum | cut -f1 -d' ')

curl -s "https://${server}/${base}?appid=${appid}&input=${input}&output=${output}&sig=${digest}"

if [[ "${base}" == "v1/spoken" ]]; then
  printf '\n'
fi
