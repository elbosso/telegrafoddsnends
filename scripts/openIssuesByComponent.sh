#!/bin/bash
#https://stackoverflow.com/questions/296536/how-to-urlencode-data-for-curl-command
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER)
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

lineformatencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [+\Q/\E-_.~a-zA-Z0-9] ) o="$c" ;;
        * )               o="\\$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER)
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

components=$(curl -k -s -i --header 'Private-Token: xxxx-xxxx-xxxxxxxxxx' "https://gitlab.fritz.box/api/v4/projects/1/labels" |grep name|     sed -e 's/[{}]/''/g' |      awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}'|grep name|cut -d ':' -f 2|cut -d '"' -f 2)
while read -r component; do
  encoded=$( rawurlencode "$component" )
#  echo $encoded
  count=$(curl -k -i --header 'Private-Token: xxxx-xxxx-xxxxxxxxxx' "https://gitlab.fritz.box/api/v4/projects/1/issues?state=opened&scope=all&per_page=1&labels=$encoded" 2>/dev/null|grep "x-total:"|cut -d ' ' -f 2| sed -e 's/\s$//g'
)
  encoded=$( lineformatencode "$component" )
  echo "openIssues,component=$encoded count=$count"
  curl -k -i --header 'Private-Token: xxxx-xxxx-xxxxxxxxxx' -XPOST http://192.168.10.2:8086/write?db=monitoring --data-binary "openIssues,component=$encoded count=$count"
done <<< "$components"
