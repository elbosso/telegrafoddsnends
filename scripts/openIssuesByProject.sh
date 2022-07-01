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

components=$(curl -k -i --header 'Private-Token: xxxx-xxxx-xxxxxxxxxx' "https://gitlab.fritz.box/api/v4/projects/" 2>/dev/null|grep name|jq .[].id |cut -d '"' -f 2)
while read -r component; do
encoded=$( rawurlencode "$component" )
projectname=$(curl -k -i --header 'Private-Token: xxxx-xxxx-xxxxxxxxxx' "https://gitlab.fritz.box/api/v4/projects/$encoded" 2>/dev/null|grep name|jq .name |cut -d '"' -f 2)
count=$(curl -k -i -s --header 'Private-Token: xxxx-xxxx-xxxxxxxxxx' "https://gitlab.fritz.box/api/v4/projects/$encoded/issues?state=opened&scope=all&per_page=1" 2>/dev/null|grep "x-total:"|cut -d ' ' -f 2| sed -e 's/\s$//g')
encoded=$( lineformatencode "$component" )
echo "openIssues,projectId=$encoded,projectName=$projectname count=$count"
curl -k -i --header 'Private-Token: xxxx-xxxx-xxxxxxxxxx' -XPOST http://192.168.10.2:8086/write?db=monitoring --data-binary "openIssues,projectId=$encoded,projectName=$projectname count=$count"

done <<< "$components"

