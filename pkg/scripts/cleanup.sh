#!/usr/bin/env bash
# This script cleanup the generated files and makes the environment ready for a clean install
#
# Syntax: cleanup.sh [-t] [-h]
# no switch: Cleanup all the files generated by install.sh
# -t: Cleanup all the files generated by terraform and install.sh
# -h: help
set -e

SCRIPT_PATH="$(dirname "$0")"
REPO_PATH="${SCRIPT_PATH}/../.."

show_help(){
  if [ ! -z "${HELP_FLAG}" ]; then
cat << EOF
First time running the install.sh results generating two set of files, variable definition and config files, and terraform files.
This script can cleanup the both type of generated files.

Usually you don't need to cleanup unless you face some problem in terraform locking process caused by interrupting during the install or uninstall.
EOF

  fi
  echo
  echo "Usage:  ./cleanup.sh [-t] [-h]"
  echo "   removes all files generated by install.sh if no switch is used."
  echo "   -t : cleanup the files generated by both terraform and install.sh."
  echo "   -h : provides help to how executing this script."
  echo
  exit 2
}

# Extract and process the arguments
  HELP_FLAG=
  CLEAN_TERRAFORM=
  CLEAN_SETUP_FILES=1                 # cleanup files generated by install.sh
  while getopts ht?: name ; do
      case $name in
      h)    HELP_FLAG=1; show_help;;  # Help
      t)    CLEAN_TERRAFORM=1;;       # cleanup files generated by terraform
      ?|*)    echo "Invalid arguments."; show_help
      esac
  done
  shift $((${OPTIND} - 1))
  UNKNOWN_ARGS="$*"
  if [ ! -z "${UNKNOWN_ARGS}" ]; then
    echo "Unknown arguments:  ${UNKNOWN_ARGS}"
    show_help
  fi

cleanup_terraform() {
  # remove the files generated by terraform
  if [ ! -z "${CLEAN_TERRAFORM}" ]; then
    # NOTE:
    rm -rf "${REPO_PATH}/.terraform"
    rm -rf "${REPO_PATH}/pkg/tfstate/.terraform"
    rm -rf "${REPO_PATH}/pkg/tfstate/.terraform.lock.hcl"
    rm -rf "${REPO_PATH}/.terraform.lock.hcl"
  fi
}

cleanup_setup_files() {
  # clean up the files generated by install.sh
  if [ ! -z "${CLEAN_SETUP_FILES}" ]; then
    rm -rf "${REPO_PATH}/terraform-backend.tf"
    rm -rf "${REPO_PATH}/pkg/tfstate/tfstate-locals.tf"
    rm -rf "${REPO_PATH}/pkg/tfstate/variables.tf"
    rm -rf "${REPO_PATH}/pkg/tfstate/config.auto.tfvars"
  fi
}


cleanup_terraform

cleanup_setup_files