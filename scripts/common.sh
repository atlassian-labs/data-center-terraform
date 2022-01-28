#!/usr/bin/env bash
# Prints message to stdout
# params: $1 - message, $2 - log level
log(){
  if [ "$#" -eq 0 ]; then
    echo "Usage: log <message>"
    return 1
  elif [ "$#" -eq 2 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") [$2] $1"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
  fi
}

# Fetch the value of the requested variable defined in Terraform config file
# params: $1 - variable name, $2 - config file full path
get_variable(){
  if [ "$#" -eq 2 ]; then
    if [ ! -f "${2}" ]; then
      echo "File ${2} is not existed."
      return 1
    fi
    local VALUE=$(grep -o '^[^#]*' "${2}" | grep "${1}" | sed 's/ //g' | grep "${1}=" | sed -nE 's/^.*"(.*)".*$/\1/p')
    if [ ! $(echo "${VALUE}" | wc -l) -eq 1 ];then
      log "ERROR - '${1}' is re-defined in '${2}'" "ERROR";
      echo "${VALUE}"
      return 1;
    fi
    echo "${VALUE}"
    return 0
  fi
  echo "Usage: fetch <config file> <variable name>"
  return 1
}