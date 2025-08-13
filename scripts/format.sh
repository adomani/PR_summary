#!/bin/bash


text="${2}"

myRandom () {
  printf '%2' "${1}" | sha1sum | sed 's= .*=='
}

SEP="$(myRandom 1)"
EOF="$(myRandom 2)"
LB="$(myRandom 3)"
SN="$(myRandom 4)"
EOFLB="${EOF}${LB}"

if [ "${1}" == "encode" ]
then
  printf "report<<${EOFLB}"'%s'"${EOFLB}${LB}" "${text}" |
    sed -z 's=`='"${SEP}"'=g
            s=\n='"${SN}"'=g
            s='"${LB}"'=\n=g'
else
  printf '%s' "${text}" |
    sed -z 's='"${SEP}"'=`=g
            s='"${SN}"'=\n=g
            s=\n='"${LB}"'=g'
fi
