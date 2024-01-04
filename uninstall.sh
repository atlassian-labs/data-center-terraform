#!/usr/bin/env bash
# This script manages to destroy the infrastructure of the Atlassian Data Center products
#
# Usage:  uninstall [-c <config_file>] [-t] [-f] [-h]
# -c <config_file>: Terraform configuration file. The default value is 'config.tfvars' if the argument is not provided.
# -t : clean up the terraform state
# -f : Auto-approve
# -h : provides help to how executing this script.
set -e
set -o pipefail
ROOT_PATH=$(cd $(dirname "${0}"); pwd)
SCRIPT_PATH="${ROOT_PATH}/scripts"
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
  echo "   -t : Cleaning up the terraform state S3 bucket permanently."
  echo "        Use this option only when there is no other environment installed in the region."
  echo "   -h : provides help to how executing this script."
  echo
  exit 2
}

# Extract arguments
  CONFIG_FILE=
  HELP_FLAG=
  CLEAN_TFSTATE=
  FORCE_FLAG=
  SKIP_REFRESH=
  while getopts thfs?c: name ; do
      case $name in
      t)  CLEAN_TFSTATE=1;;            # Cleaning terraform state
      h)  HELP_FLAG=1; show_help;;    # Help
      c)  CONFIG_FILE="${OPTARG}";;       # Config file name to install - this overrides the default, 'config.tfvars'
      f)  FORCE_FLAG="-f";;         # Force uninstall - Auto-approve
      s)  SKIP_REFRESH="-s";;
      ?)  log "Invalid arguments." "ERROR"; show_help
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
      log "Terraform configuration file '${CONFIG_FILE}' was not found!" "ERROR"
      show_help
    fi
  fi
  CONFIG_ABS_PATH="$(cd "$(dirname "${CONFIG_FILE}")"; pwd)/$(basename "${CONFIG_FILE}")"
  OVERRIDE_CONFIG_FILE="-var-file=${CONFIG_ABS_PATH}"

  log "Terraform uses '${CONFIG_ABS_PATH}' to uninstall the infrastructure."

  if [ ! -z "${UNKNOWN_ARGS}" ]; then
    log "Unknown arguments:  ${UNKNOWN_ARGS}" "ERROR"
    show_help
  fi

  ENVIRONMENT_NAME=$(get_variable 'environment_name' ${CONFIG_ABS_PATH})
  REGION=$(get_variable 'region' ${CONFIG_ABS_PATH})

  if [ "${SKIP_REFRESH}" ]; then
    SKIP_REFRESH="-refresh=false"
  fi
}

# Ask user confirmation for destroying the environment
confirm_action() {
  echo
  log "You are about to destroy the '${ENVIRONMENT_NAME}' environment. "
  echo
  log "All data resources provisioned in this environment including database will be deleted permanently."
  log "Please make sure you have made a backup of your valuable data before proceeding."
  echo

  if [ -z "${FORCE_FLAG}" ]; then
    read -p "Are you sure that you want to **DELETE** the environment '${ENVIRONMENT_NAME}' (yes/no)? " yn
    case $yn in
        Yes|yes ) log "Deletion confirmed. Environment '${ENVIRONMENT_NAME}' will be deleted soon.";;
        No|no|n|N ) log "Uninstall is cancelled by the user." "ERROR";  exit 1;;
        * ) log "Please answer 'Yes' to confirm deleting the infrastructure." "ERROR"; exit 1;;
    esac
    echo
  else
    log "Because -f option was provided, the environment will be destroyed without manual confirmation"
  fi
}

# Cleaning all the generated terraform state variable and backend file and local terraform files
regenerate_environment_variables() {
  log "${ENVIRONMENT_NAME}' infrastructure uninstall is started using '${CONFIG_ABS_PATH##*/}'."
  bash "${SCRIPT_PATH}/generate-variables.sh" -c "${CONFIG_ABS_PATH}" "${FORCE_FLAG}"
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
  terraform -chdir="${ROOT_PATH}" destroy -auto-approve ${SKIP_REFRESH} -no-color "${OVERRIDE_CONFIG_FILE}" | tee -a "${LOG_FILE}"
  if [ $? -eq 0 ]; then
    log "'${ENVIRONMENT_NAME}' infrastructure was removed successfully."
  else
    set -e
    log "Failed to remove '${ENVIRONMENT_NAME}' infrastructure." "ERROR"
    log "Attempting to force terminate environment" "ERROR"
    python3 <(curl -s https://raw.githubusercontent.com/atlassian/dc-app-performance-toolkit/retry-in-cleanup-script/app/util/k8s/terminate_cluster.py) \
            --cluster_name atlas-${ENVIRONMENT_NAME}-cluster \
            --aws_region ${REGION}
  fi
}

destroy_tfstate() {
  # Check if the user passed '-s' parameter to skip removing tfstate
  if [ -z "${CLEAN_TFSTATE}" ]; then
    return
  fi
  echo
  log "Attempting to remove terraform backend."
  echo
  TF_STATE_FILE="${ROOT_PATH}/modules/tfstate/tfstate-locals.tf"
  if [ -f "${TF_STATE_FILE}" ]; then
    # extract S3 bucket name, bucket key and dynamodb table name from tfstate-locals.tf
    S3_BUCKET=$(get_variable "bucket_name" "${TF_STATE_FILE}")
    BUCKET_KEY=$(get_variable "bucket_key" "${TF_STATE_FILE}")
    DYNAMODB_TABLE=$(get_variable 'dynamodb_name' ${TF_STATE_FILE})
    AWS_REGION=$(get_variable 'region' "${CONFIG_ABS_PATH}")
    local TFSTATE_FOLDER="${ROOT_PATH}/modules/tfstate"
    set +e
    aws s3api head-bucket --bucket "${S3_BUCKET}" 2>/dev/null
    S3_BUCKET_EXISTS=$?
    set -e
    if [ ${S3_BUCKET_EXISTS} -eq 0 ]; then
      set +e
      # Get the bucket key list of all installed environments in this region
      ALL_BUCKET_KEYS=$(cut -d 'E' -f2 <<< $(aws s3api list-objects --bucket "${S3_BUCKET}" --output text --query "Contents[].{Key: Key}"))
      if [ "${ALL_BUCKET_KEYS}" != "${BUCKET_KEY}" ]; then
        log "Terraform is going to delete the S3 bucket contains the state for all environments provisioned in the region."
        log "Here is the list of environments provisioned using this instance:"
        log "${ALL_BUCKET_KEYS}"
        echo
        log "Without valid states, terraform cannot manage the environments anymore."
        log "Make sure you have already uninstalled all the environments before proceeding."
        echo
        read -p "Are you sure that you want to delete terraform states for the environments (yes/no)? " yn
        case $yn in
            Yes|yes ) log "Thank you. We have your confirmation to proceed.";;
            No|no|n|N ) \
              log "Thank you. The environment ${ENVIRONMENT_NAME} is uninstalled successfully.";\
              log "As your request, the terraform state is not removed."; exit 1;;
            * ) log "Please answer 'Yes' to confirm deleting the terraform state." "ERROR"; exit 1;;
        esac
      fi

      ERROR="false"
      log "Deleting object versions in ${S3_BUCKET} S3 bucket..."
      OBJECT_VERSIONS=$(aws s3api list-object-versions --bucket "${S3_BUCKET}")
      if [ -z "${OBJECT_VERSIONS}" ]; then
        log "No object versions found"
      else
        aws s3api delete-objects \
          --bucket ${S3_BUCKET} \
          --delete "$(aws s3api list-object-versions --bucket "${S3_BUCKET}" --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')" >/dev/null
        if [ $? -ne 0 ]; then
          ERROR="true"
        fi
      fi

      log "Deleting S3 bucket ${S3_BUCKET}..."
      aws s3api delete-bucket --bucket "${S3_BUCKET}" >/dev/null
      if [ $? -ne 0 ]; then
        ERROR="true"
      fi

      log "Deleting DynamoDB table ${DYNAMODB_TABLE}..."
      aws dynamodb delete-table --table-name "${DYNAMODB_TABLE}" --region "${AWS_REGION}" >/dev/null
      if [ $? -ne 0 ]; then
        ERROR="true"
      fi

      if [ ${ERROR} == "false" ]; then
        set -e
        log "Cleaning all the terraform generated files."
        bash "${SCRIPT_PATH}/cleanup.sh" -t -s -x -r ${ROOT_PATH}
        log "Terraform state is removed successfully."
      else
        log "Couldn't destroy S3 bucket '${S3_BUCKET}' and/or dynamodb table '${DYNAMODB_TABLE}'. Terraform state '${BUCKET_KEY}' in S3 bucket '${S3_BUCKET}' cannot be removed." "ERROR"
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
