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


#declare -a dcomponents=("algorithms" "aviator" "blocker" "Bug" "tools%2Fcms" "critical" "documents" "dWb+" "tools%2Fffmpeggui" "util%2Fgeo" "model" "project%20management" "scratch" "sQLshell" "ui" "util" "util%2Fgenerator" "website")
#declare -a ddcomponents=("algorithms" "aviator" "blocker" "Bug" "tools/cms" "critical" "documents" "dWb+" "tools/ffmpeggui" "util/geo" "model" "project management" "scratch" "sQLshell" "ui" "util" "util/generator2" "website")
components=$(curl -i --header 'Private-Token: <privateToken>' "http://gitlab.fritz.box/api/v4/projects/" 2>/dev/null|grep name|jq .[].id |cut -d '"' -f 2)
while read -r component; do
encoded=$( rawurlencode "$component" )
#echo $encoded
projectname=$(curl -i --header 'Private-Token: <privateToken>' "http://gitlab.fritz.box/api/v4/projects/$encoded" 2>/dev/null|grep name|jq .name |cut -d '"' -f 2)
count=$(curl -i --header 'Private-Token: <privateToken>' "http://gitlab.fritz.box/api/v4/projects/$encoded/issues?state=opened&scope=all&per_page=1" 2>/dev/null|grep "X-Total:"|cut -d ' ' -f 2)
encoded=$( lineformatencode "$component" )
echo "openIssues,projectId=$encoded,projectName=$projectname count=$count"
done <<< "$components"

#for component in "${components[@]}"
#do
#encoded=$( rawurlencode "$component" )
##echo $encoded
#count=`curl -i --header 'Private-Token: <privateToken>' "http://gitlab.fritz.box/api/v4/projects/1/issues?state=opened&scope=all&per_page=1&labels=$encoded" 2>/dev/null|grep "X-Total:"|cut -d ' ' -f 2`
#encoded=$( lineformatencode "$component" )
#echo openIssues,component=$encoded count=$count
#done
