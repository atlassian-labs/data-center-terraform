#!/bin/bash
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