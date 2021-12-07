#!/usr/bin/env bash
# This script cleanup the generated files and makes the environment ready for a clean install
#
# Usage: cleanup.sh [-s] [-t] [-h]
# no switch: Cleanup only the variable files generated by install.sh. The files generated by terraform will remain.
# -t: Cleanup all the files generated by either terraform or install.sh
# -h: help
set -e
set -x

SCRIPT_PATH="$(dirname "$0")"
REPO_PATH="${SCRIPT_PATH}/../.."
TAG_MODULE_PATH="${REPO_PATH}/pkg/modules/AWS/asg_ec2_tagging"
TFSTATE_PATH="${REPO_PATH}/pkg/tfstate"

show_help(){
  if [ ! -z "${HELP_FLAG}" ]; then
cat << EOF
First time running the install.sh results in generating two sets of files, variable/config definition, and terraform files.
This script can cleanup the both type of generated file sets.

Usually you don't need to cleanup unless you face some problem in terraform locking process caused by an interruption during the install or uninstall.
EOF

  fi
  echo
  echo "Usage:  ./cleanup.sh [-s] [-t] [-h]"
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
  while getopts hst?: name ; do
      case $name in
      h)    HELP_FLAG=1; show_help;;  # Help
      s)    CLEAN_SETUP_FILES=1;;     # cleanup variable files generated by installer
      t)    CLEAN_TERRAFORM=1;;       # cleanup terraform files generated by terraform
      ?|*)    echo "Invalid arguments."; show_help
      esac
  done
  shift $((${OPTIND} - 1))
  UNKNOWN_ARGS="$*"
  if [ ! -z "${UNKNOWN_ARGS}" ]; then
    echo "Unknown arguments:  ${UNKNOWN_ARGS}"
    show_help
  fi

  if [ -z "${CLEAN_SETUP_FILES}${CLEAN_TERRAFORM}" ]; then
    show_help
  fi

delete_terraform_files() {
    rm -rf "${CLEANING_PATH}/.terraform"
    rm -rf "${CLEANING_PATH}/.terraform.lock.hcl"
    rm -rf "${CLEANING_PATH}/terraform.tfstate"
    rm -rf "${CLEANING_PATH}/terraform.tfstate.backkup"
}

cleanup_terraform() {
  # remove the files generated by terraform
  if [ ! -z "${CLEAN_TERRAFORM}" ]; then
    echo "Cleaning up terraform generated files."

    local CURRENT_PATH="$(pwd)"
    cd "${REPO_PATH}"

    # List of all folders to cleanup
    local folder_lists=(
      "."
      "./pkg/modules/AWS/eks"
      "./pkg/modules/AWS/s3"
      "./pkg/modules/AWS/efs"
      "/pkg/modules/AWS/dynamodb"
      "./pkg/modules/AWS/ingress"
      "./pkg/modules/AWS/rds"
      "./pkg/modules/AWS/vpc"
      "./pkg/products/bamboo"
      "./pkg/products/common"
      "./pkg/modules/AWS/asg_ec2_tagging"
    )

    for TARGET_FOLDER in "${folder_lists[@]}"; do
      echo "${TARGET_FOLDER}"
      CLEANING_PATH="${TARGET_FOLDER}"
      delete_terraform_files
    done

    cd "${CURRENT_PATH}"
  fi
}

cleanup_setup_files() {
  # clean up the files generated by install.sh for terraform state and tagging module
  if [ ! -z "${CLEAN_SETUP_FILES}" ]; then
    echo "Cleaning generated variable files."

    # root
    rm -rf "${REPO_PATH}/terraform-backend.tf"

    # Terraform state
    rm -rf "${TFSTATE_PATH}/*.tfvars"
    rm -rf "${TFSTATE_PATH}/variables.tf"
    rm -rf "${TFSTATE_PATH}/tfstate-locals.tf"

    # Tagging module
    rm -rf "${TAG_MODULE_PATH}/*.tfvars"
    rm -rf "${TAG_MODULE_PATH}/variables.tf"
    rm -rf "${TAG_MODULE_PATH}/tfstate-locals.tf"
  fi
}

cleanup_terraform

cleanup_setup_files
