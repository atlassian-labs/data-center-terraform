#!/usr/bin/env bash
# This script cleanup the generated files and makes the environment ready for a clean install
#
# Usage: cleanup.sh [-s] [-t] [-h] [-r <root_repo>]
# no switch: Cleanup only the variable files generated by install.sh. The files generated by terraform will remain.
# -s : cleanup the variable setup files generated by installer.
# -t : cleanup the terraform generated files during the last install.
# -r <path_root_repo>: define path to root folder of repo. If is not provided it calculated it based on script path
# -h: help
set -e

if [ "${0##*/}" == "cleanup.sh" ]; then
  # the script ran directly from terminal
  ROOT_PATH=$(cd $(dirname "${0}")/../..; pwd)
else
  # the script called by install.sh or uninstall.sh
  ROOT_PATH=$(cd $(dirname "${0}"); pwd)
fi
SCRIPT_PATH="${ROOT_PATH}/pkg/scripts"

source "${SCRIPT_PATH}/common.sh"

show_help(){
  if [ -n "${HELP_FLAG}" ]; then
cat << EOF
First time running the install.sh results in generating two sets of files, variable/config definition,
and terraform files.
This script can cleanup the both type of generated file sets.

Usually you don't need to cleanup manually unless you face some problem in terraform locking process
caused by any kind of interruption during the install or uninstall.
EOF

  fi
  echo
  echo "Usage:  ./cleanup.sh [-s] [-t] [-h] [-r <root_repo>]"
  echo "   removes all files generated by install.sh and/or terraform based on the switches you use:"
  echo "   -s : cleanup the variable setup files generated by installer."
  echo "   -t : cleanup the terraform generated files during the last install."
  echo "   -h : provides help to how executing this script."
  echo
  exit 2
}

# Extract and process the arguments
  HELP_FLAG=
  CLEAN_TERRAFORM=
  CLEAN_SETUP_FILES=
  ROOT_PATH=
  while getopts hst?r: name ; do
      case $name in
      h)    HELP_FLAG=1; show_help;;  # Help
      s)    CLEAN_SETUP_FILES=1;;     # cleanup variable files generated by installer
      t)    CLEAN_TERRAFORM=1;;       # cleanup terraform files generated by terraform
      r)    ROOT_PATH="${OPTARG}";;   # path to root of repo
      ?|*)  log "Invalid arguments."; show_help
      esac
  done
  shift $((${OPTIND} - 1))
  UNKNOWN_ARGS="$*"
  if [ -n "${UNKNOWN_ARGS}" ]; then
    log "Unknown arguments:  ${UNKNOWN_ARGS}"
    show_help
  fi

  if [ -z "${CLEAN_SETUP_FILES}${CLEAN_TERRAFORM}" ]; then
    show_help
  fi

  TAG_MODULE_PATH="${ROOT_PATH}/pkg/modules/AWS/asg_ec2_tagging"
  TFSTATE_PATH="${ROOT_PATH}/pkg/tfstate"

delete_terraform_files() {
    rm -rf "${CLEANING_PATH}/.terraform"
    rm -rf "${CLEANING_PATH}/.terraform.lock.hcl"
    rm -rf "${CLEANING_PATH}/terraform.tfstate"
}

cleanup_terraform() {
  # remove the files generated by terraform
  if [ -n "${CLEAN_TERRAFORM}" ]; then
    log "Cleaning up terraform generated files."

    # List of all folders to cleanup
    local folder_lists=(
      "${ROOT_PATH}"
      "${ROOT_PATH}/pkg/modules/AWS/eks"
      "${ROOT_PATH}/pkg/modules/AWS/s3"
      "${ROOT_PATH}/pkg/modules/AWS/efs"
      "${ROOT_PATH}/pkg/modules/AWS/dynamodb"
      "${ROOT_PATH}/pkg/modules/AWS/ingress"
      "${ROOT_PATH}/pkg/modules/AWS/rds"
      "${ROOT_PATH}/pkg/modules/AWS/vpc"
      "${ROOT_PATH}/pkg/products/bamboo"
      "${ROOT_PATH}/pkg/products/common"
      "${ROOT_PATH}/pkg/modules/AWS/asg_ec2_tagging"
      "${ROOT_PATH}/pkg/tfstate"
    )

    for TARGET_FOLDER in "${folder_lists[@]}"; do
      CLEANING_PATH="${TARGET_FOLDER}"
      delete_terraform_files
    done
  fi
}

cleanup_setup_files() {
  # clean up the files generated by install.sh for terraform state and tagging module
  if [ -n "${CLEAN_SETUP_FILES}" ]; then
    log "Cleaning generated variable files."
    # from root
    rm -rf "${ROOT_PATH}/terraform-backend.tf"

    # Terraform state
    rm -rf "${TFSTATE_PATH}"/*.tfvars
    rm -rf "${TFSTATE_PATH}/variables.tf"
    rm -rf "${TFSTATE_PATH}/tfstate-locals.tf"

    # Tagging module
    rm -rf "${TAG_MODULE_PATH}"/*.tfvars
    rm -rf "${TAG_MODULE_PATH}/variables.tf"
    rm -rf "${TAG_MODULE_PATH}/tfstate-locals.tf"
  fi
}

cleanup_terraform
cleanup_setup_files
