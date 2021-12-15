#!/usr/bin/env bash
# This script manages to destroy the infrastructure of the Atlassian Data Center products
#
# Usage:  uninstall [-c <config_file>] [-s] [-h]
# -c <config_file>: Terraform configuration file. The default value is 'config.tfvars' if the argument is not provided.
# -s : Skip cleaning up the terraform state
# -h : provides help to how executing this script.
set -e
set -o pipefail
SCRIPT_PATH="$(dirname "$0")"
ROOT_PATH="${SCRIPT_PATH}/../.."
LOG_FILE="${ROOT_PATH}/logs/terraform-dc-uninstall_$(date '+%Y-%m-%d_%H-%M-%S').log"
ENVIRONMENT_NAME=
OVERRIDE_CONFIG_FILE=

show_help(){
  if [ ! -z "${HELP_FLAG}" ]; then
cat << EOF
** WARNING **
This script destroys the infrastructure for Atlassian Data Center products in AWS environment. You may lose all application data.
The infrastructure will be removed by terraform. Also the terraform state could be removed if you use switch `-t` in uninstall command.
EOF

  fi
  echo
  echo "Usage:  ./uninstall.sh [-c <config_file>] [-h] [-s]"
  echo "   -c <config_file>: Terraform configuration file. The default value is 'config.tfvars' if the argument is not provided."
  echo "   -t : Cleaning up the terraform state as well."
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
      ?)  echo "Invalid arguments."; show_help
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
      echo "Terraform configuration file '${CONFIG_FILE}' is not found!"
      show_help
    fi
  fi
  CONFIG_ABS_PATH="$(cd "$(dirname "${CONFIG_FILE}")"; pwd)/$(basename "${CONFIG_FILE}")"
  OVERRIDE_CONFIG_FILE="-var-file=${CONFIG_ABS_PATH}"

  echo "Terraform uses '${CONFIG_ABS_PATH}' to uninstall the infrastructure."

  if [ ! -z "${UNKNOWN_ARGS}" ]; then
    echo "Unknown arguments:  ${UNKNOWN_ARGS}"
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
      Yes ) echo "Thank you. We have your confirmation now. Environment '${ENVIRONMENT_NAME}' will be deleted soon.";;
      No ) exit;;
      * ) echo "Please answer 'Yes' to confirm deleting the infrastructure (case sensitive)."; exit;;
  esac
  echo
}

# Cleaning all the generated terraform state variable and backend file and local terraform files
regenerate_environment_variables() {
  echo "${ENVIRONMENT_NAME}' infrastructure uninstall is started using ${CONFIG_ABS_PATH}."

  echo "Terraform state backend/variable files are set."
  source "${SCRIPT_PATH}/generate-variables.sh" ${CONFIG_ABS_PATH} ${ROOT_PATH}
}


destroy_infrastructure() {
  if ! test -d "${ROOT_PATH}/logs" ; then
    mkdir "${ROOT_PATH}/logs"
  fi
  touch "${LOG_FILE}"
  # Start destroying the infrastructure
  if ! test -d ".terraform" ; then
    terraform -chdir="${ROOT_PATH}" init | tee -a "${LOG_FILE}"
  fi
  set +e
  terraform -chdir="${ROOT_PATH}" destroy -auto-approve "${OVERRIDE_CONFIG_FILE}" | tee -a "${LOG_FILE}"
  if [ $? -eq 0 ]; then
    set -e
  else
    echo "'${ENVIRONMENT_NAME}' infrastructure could not be removed successfully."
    exit 1
  fi
  echo "'${ENVIRONMENT_NAME}' infrastructure is removed successfully."
}


destroy_tfstate() {
  # Check if the user passed '-s' parameter to skip removing tfstate
  if [ -z "${CLEAN_TFSTATE}" ]; then
    echo "Skipped terraform state cleanup."
    return
  fi
  TF_STATE_FILE="${SCRIPT_PATH}/../tfstate/tfstate-locals.tf"
  if [ -f "${TF_STATE_FILE}" ]; then
    # extract S3 bucket and bucket key from tfstate-locals.tf
    S3_BUCKET=$(grep "bucket_name" "${TF_STATE_FILE}" | sed -nE 's/^.*"(.*)".*$/\1/p')
    BUCKET_KEY=$(grep "bucket_key" "${TF_STATE_FILE}" | sed -nE 's/^.*"(.*)".*$/\1/p')
    DYNAMODB_TABLE=$(grep 'dynamodb_name' ${TF_STATE_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')

    local TFSTATE_FOLDER="${SCRIPT_PATH}/../tfstate"
    set +e
    aws s3api head-bucket --bucket "${S3_BUCKET}" 2>/dev/null
    S3_BUCKET_EXISTS=$?
    set -e
    if [ ${S3_BUCKET_EXISTS} -eq 0 ]
    then
      set +e
      if ! test -d ".terraform" ; then
        terraform -chdir="${TFSTATE_FOLDER}" init | tee -a "${LOG_FILE}"
      fi
      terraform -chdir="${TFSTATE_FOLDER}" destroy -auto-approve "${OVERRIDE_CONFIG_FILE}" | tee -a "${LOG_FILE}"
      if [ $? -eq 0 ]; then
        set -e
        echo "Cleaning all the terraform generated files."
        sh "${SCRIPT_PATH}/cleanup.sh" -t
        echo Terraform state is removed successfully.
      else
        echo "Couldn't destroy dynamodb table '${DYNAMODB_TABLE}'. Terraform state '${BUCKET_KEY}' in S3 bucket '${S3_BUCKET}' cannot be removed."
        exit 1
      fi
    else
      # Provided s3 bucket to be used for keep state of the terraform project does not exist
      echo "S3 bucket '${S3_BUCKET}' is not existed. There is no 'tfstate' resource to destroy"
      exit 1
    fi
  else
      echo "Cannot cleanup the Terraform state because ${TF_STATE_FILE} does not exist."
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

# Delete tfstate and tfvars in asg_ec2_tagging module
cleanup_asg_ec2_tagging_module