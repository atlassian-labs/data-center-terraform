#!/usr/bin/env bash
# This script manages to destroy the infrastructure of the Atlassian Data Center products
#
# Usage:  uninstall [-c <config_file>] [-s] [-h]
# -c <config_file>: Terraform configuration file. The default value is 'config.tfvars' if the argument is not provided.
# -s : Skip cleaning up the terraform state
# -h : provides help to how executing this script.
set -e
set -o pipefail
ROOT_PATH=$(cd $(dirname "${0}"); pwd)
SCRIPT_PATH="${ROOT_PATH}/pkg/scripts"
LOG_FILE="${ROOT_PATH}/logs/terraform-dc-uninstall_$(date '+%Y-%m-%d_%H-%M-%S').log"
ENVIRONMENT_NAME=
OVERRIDE_CONFIG_FILE=
DIFFERENT_ENVIRONMENT=1

source "${SCRIPT_PATH}/common.sh"

show_help(){
  if [ ! -z "${HELP_FLAG}" ]; then
cat << EOF
** WARNING **
This script destroys the infrastructure for Atlassian Data Center products in AWS environment. You may lose all application data.
The infrastructure will be removed by terraform. Also the terraform state could be removed if you use switch `-t` in uninstall command.
EOF

  fi
  echo
  echo "Usage:  ./uninstall.sh [-c <config_file>] [-h] [-t]"
  echo "   -c <config_file>: Terraform configuration file. The default value is 'config.tfvars' if the argument is not provided."
  echo "   -t : Cleaning up the terraform state S3 bucket."
  echo "   -h : provides help to how executing this script."
  echo
  exit 2
}

# Extract arguments
  CONFIG_FILE=
  HELP_FLAG=
  CLEAN_TFSTATE=
  while getopts th?c: name ; do
      case $name in
      t)  CLEAN_TFSTATE=1;;            # Cleaning terraform state
      h)  HELP_FLAG=1; show_help;;    # Help
      c)  CONFIG_FILE="${OPTARG}";;       # Config file name to install - this overrides the default, 'config.tfvars'
      ?)  log "Invalid arguments."; show_help
      esac
  done

  shift $((${OPTIND} - 1))
  UNKNOWN_ARGS="$*"

 # Validate the arguments.
process_arguments() {
  # set the default value for config file if is not provided
  if [ -z "${CONFIG_FILE}" ]; then
    CONFIG_FILE="${ROOT_PATH}/config.tfvars"
  else
    if [[ ! -f "${CONFIG_FILE}" ]]; then
      log "Terraform configuration file '${CONFIG_FILE}' is not found!"
      show_help
    fi
  fi
  CONFIG_ABS_PATH="$(cd "$(dirname "${CONFIG_FILE}")"; pwd)/$(basename "${CONFIG_FILE}")"
  OVERRIDE_CONFIG_FILE="-var-file=${CONFIG_ABS_PATH}"

  log "Terraform uses '${CONFIG_ABS_PATH}' to uninstall the infrastructure."

  if [ ! -z "${UNKNOWN_ARGS}" ]; then
    log "Unknown arguments:  ${UNKNOWN_ARGS}"
    show_help
  fi

  ENVIRONMENT_NAME=$(grep 'environment_name' ${CONFIG_ABS_PATH} | sed -nE 's/^.*"(.*)".*$/\1/p')
}

# Ask user confirmation for destroying the environment
confirm_action() {
  echo
  echo "You are about to destroy the '${ENVIRONMENT_NAME}' environment. "
  echo
  echo "All data resources provisioned in this environment including database will be deleted permanently."
  echo "Please make sure you have made a backup of your valuable data before proceeding."
  echo

  read -p "Are you sure that you want to **DELETE** the environment '${ENVIRONMENT_NAME}' (Yes/No)? " yn
  case $yn in
      Yes|yes ) echo "Deletion confirmed. Environment '${ENVIRONMENT_NAME}' will be deleted soon.";;
      No|no|n|N ) exit;;
      * ) echo "Please answer 'Yes' to confirm deleting the infrastructure."; exit;;
  esac
  echo
}

# Cleaning all the generated terraform state variable and backend file and local terraform files
regenerate_environment_variables() {
  log "${ENVIRONMENT_NAME}' infrastructure uninstall is started using '${CONFIG_ABS_PATH##*/}'."
  source "${SCRIPT_PATH}/generate-variables.sh" ${CONFIG_ABS_PATH}
}


destroy_infrastructure() {
  if [ ! -d "${ROOT_PATH}/logs" ]; then
    mkdir "${ROOT_PATH}/logs"
  fi
  touch "${LOG_FILE}"
  # Start destroying the infrastructure
  if [ -n "${DIFFERENT_ENVIRONMENT}" ] ; then
    terraform -chdir="${ROOT_PATH}" init -no-color -migrate-state | tee -a "${LOG_FILE}"
    terraform -chdir="${ROOT_PATH}" init -no-color | tee -a "${LOG_FILE}"
  fi
  set +e
  terraform -chdir="${ROOT_PATH}" destroy -auto-approve -no-color "${OVERRIDE_CONFIG_FILE}" | tee -a "${LOG_FILE}"
  if [ $? -eq 0 ]; then
    set -e
  else
    log "'${ENVIRONMENT_NAME}' infrastructure could not be removed successfully." "ERROR"
    exit 1
  fi
  log "'${ENVIRONMENT_NAME}' infrastructure is removed successfully."
}


destroy_tfstate() {
  # Check if the user passed '-s' parameter to skip removing tfstate
  if [ -z "${CLEAN_TFSTATE}" ]; then
    return
  fi
  echo
  echo "Attempting to remove terraform backend."
  echo
  TF_STATE_FILE="${ROOT_PATH}/pkg/tfstate/tfstate-locals.tf"
  if [ -f "${TF_STATE_FILE}" ]; then
    # extract S3 bucket and bucket key from tfstate-locals.tf
    S3_BUCKET=$(grep "bucket_name" "${TF_STATE_FILE}" | sed -nE 's/^.*"(.*)".*$/\1/p')
    BUCKET_KEY=$(grep "bucket_key" "${TF_STATE_FILE}" | sed -nE 's/^.*"(.*)".*$/\1/p')
    DYNAMODB_TABLE=$(grep 'dynamodb_name' ${TF_STATE_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')

    local TFSTATE_FOLDER="${ROOT_PATH}/pkg/tfstate"
    set +e
    aws s3api head-bucket --bucket "${S3_BUCKET}" 2>/dev/null
    S3_BUCKET_EXISTS=$?
    set -e
    if [ ${S3_BUCKET_EXISTS} -eq 0 ]; then
      set +e
      # Get the bucket key list of all installed environments in this region
      ALL_BUCKET_KEYS=$(cut -d 'E' -f2 <<< $(aws s3api list-objects --bucket "${S3_BUCKET}" --prefix "n" --output text --query "Contents[].{Key: Key}"))
      if [ "${ALL_BUCKET_KEYS}" != "${BUCKET_KEY}" ]; then
        echo "Terraform is going to delete the S3 bucket contains the state for all environments provisioned in the region."
        echo "Here is the list of environments provisioned using this instance:"
        echo "${ALL_BUCKET_KEYS}"
        echo
        echo "Without valid states, terraform cannot manage the environments anymore."
        echo "Make sure you have already uninstalled all the environments before proceeding."
        echo
        read -p "Are you sure that you want to delete terraform states for the environments (Yes/No)? " yn
        case $yn in
            Yes|yes ) echo "Thank you. We have your confirmation to proceed.";;
            No|no|n|N ) \
              echo "Thank you. The environment ${ENVIRONMENT_NAME} is uninstalled successfully.";\
              echo "As your request, the terraform state is not removed."; exit;;
            * ) echo "Please answer 'Yes' to confirm deleting the terraform state."; exit;;
        esac
      fi
      if ! test -d ".terraform" ; then
        terraform -chdir="${TFSTATE_FOLDER}" init -no-color | tee -a "${LOG_FILE}"
      fi
      terraform -chdir="${TFSTATE_FOLDER}" destroy -auto-approve -no-color "${OVERRIDE_CONFIG_FILE}" | tee -a "${LOG_FILE}"
      if [ $? -eq 0 ]; then
        set -e
        log "Cleaning all the terraform generated files."
        sh "${SCRIPT_PATH}/cleanup.sh" -t -s -x -r ${ROOT_PATH}
        log Terraform state is removed successfully.
      else
        log "Couldn't destroy dynamodb table '${DYNAMODB_TABLE}'. Terraform state '${BUCKET_KEY}' in S3 bucket '${S3_BUCKET}' cannot be removed." "ERROR"
        exit 1
      fi
    else
      # Provided s3 bucket to be used for keep state of the terraform project does not exist
      log "S3 bucket '${S3_BUCKET}' doesn't exist. There is no 'tfstate' resource to destroy" "ERROR"
      exit 1
    fi
  else
      log "Cannot cleanup the Terraform state because ${TF_STATE_FILE} does not exist." "ERROR"
      exit 1
  fi
}

# Process the arguments
process_arguments

# Ask user confirmation for destroy the environment
confirm_action

# cleanup environment variable and regenerate them
regenerate_environment_variables

# Destroy the infrastructure for the given product
destroy_infrastructure

# Destroy tfstate (S3 bucket key and dynamodb table) of the product
destroy_tfstate

