#!/usr/bin/env bash
# This script manages to destroy the infrastructure of the Atlassian Data Center products
#
# Usage:  uninstall [-c <config_file>] [-s] [-h]
# -c <config_file>: Terraform configuration file. The default value is 'config.auto.tfvars' if the argument is not provided.
# -s : Skip cleaning up the terraform state
# -h : provides help to how executing this script.

set -e
CURRENT_PATH="$(pwd)"
SCRIPT_PATH="$(dirname "$0")"
ENVIRONMENT_NAME=
OVERRIDE_CONFIG_FILE=

show_help(){
  if [ ! -z "${HELP_FLAG}" ]; then
cat << EOF
** WARNING **
This script destroys the infrastructure for Atlassian Data Center products in AWS environment. You may lose all application data.
The infrastructure will be removed by terraform. Also the terraform state will be removed from the S3 bucket which will be provision by this script if is not existed.
EOF

  fi
  echo
  echo "Usage:  ./uninstall.sh [-c <config_file>] [-h] [-s]"
  echo "   -c <config_file>: Terraform configuration file. The default value is 'config.auto.tfvars' if the argument is not provided."
  echo "   -s : Skip cleaning up the terraform state."
  echo "   -h : provides help to how executing this script."
  echo
  exit 2
}

# Extract arguments
  CONFIG_FILE=
  HELP_FLAG=
  SKIP_TFSTATE=
  while getopts sh?c: name ; do
      case $name in
      s)  SKIP_TFSTATE=1;;            # Skip cleaning terraform state
      h)  HELP_FLAG=1; show_help;;    # Help
      c)  CONFIG_FILE="${OPTARG}";;       # Config file name to install - this overrides the default, 'config.auto.tfvars'
      ?)  echo "Invalid arguments."; show_help
      esac
  done

  shift $((${OPTIND} - 1))
  UNKNOWN_ARGS="$*"

 # Validate the arguments.
process_arguments() {
  # set the default value for config file if is not provided
  if [ -z "${CONFIG_FILE}" ]; then
    CONFIG_FILE="${SCRIPT_PATH}/../../config.auto.tfvars"
  else
    if [[ ! -f "${CONFIG_FILE}" ]]; then
      echo "Terraform configuration file '${CONFIG_FILE}' is not found!"
      show_help
    fi
    OVERRIDE_CONFIG_FILE="-var-file=${CONFIG_FILE}"
    echo "Terraform uses '${CONFIG_FILE}' to uninstall the infrastructure."
  fi

  if [ ! -z "${UNKNOWN_ARGS}" ]; then
    echo "Unknown arguments:  ${UNKNOWN_ARGS}"
    show_help
  fi

  ENVIRONMENT_NAME=$(grep 'environment_name' ${CONFIG_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')
}

# Cleaning all the generated terraform state variable and backend file and local terraform files
regenerate_environment_variables() {
    echo "Cleaning all the generated terraform state variable and backend file."
    source "${SCRIPT_PATH}/cleanup.sh"

  ROOT_PATH="${SCRIPT_PATH}/../.."

  echo "${ENVIRONMENT_NAME}' infrastructure uninstall is started using ${CONFIG_FILE}."

  echo "Terraform state backend/variable files are set."
  source "${SCRIPT_PATH}/generate-variables.sh" ${CONFIG_FILE} ${ROOT_PATH}
}



destroy_infrastructure() {
  cd "${SCRIPT_PATH}/../../"
  set +e
  terraform destroy "${OVERRIDE_CONFIG_FILE}"
  if [ $? -eq 0 ]; then
    set -e
  else
    cd "${CURRENT_PATH}"
    echo "'${ENVIRONMENT_NAME}' infrastructure could not be removed successfully."
    exit 1
  fi
  cd "${CURRENT_PATH}"
  echo "'${ENVIRONMENT_NAME}' infrastructure is removed successfully."
}


destroy_tfstate() {
  # Check if the user passed '-s' parameter to skip removing tfstate
  if [ ! -z "${SKIP_TFSTATE}" ]; then
    echo "Skipped terraform state cleanup."
    return
  fi
  TF_STATE_FILE="${SCRIPT_PATH}/../tfstate/tfstate-locals.tf"
  if [ -f "${TF_STATE_FILE}" ]; then
    # extract S3 bucket and bucket key from tfstate-locals.tf
    S3_BUCKET=$(grep "bucket_name" "${TF_STATE_FILE}" | sed -nE 's/^.*"(.*)".*$/\1/p')
    BUCKET_KEY=$(grep "bucket_key" "${TF_STATE_FILE}" | sed -nE 's/^.*"(.*)".*$/\1/p')
    DYNAMODB_TABLE=$(grep 'dynamodb_name' ${TF_STATE_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')

    cd "${SCRIPT_PATH}/../tfstate"
    set +e
    aws s3api head-bucket --bucket "${S3_BUCKET}"
    S3_BUCKET_EXISTS=$?
    set -e
    if [ ${S3_BUCKET_EXISTS} -eq 0 ]
    then
      set +e
      terraform destroy -auto-approve "${OVERRIDE_CONFIG_FILE}"
      if [ $? -eq 0 ]; then
        set -e
      else
        echo "Couldn't destroy dynamodb table '${DYNAMODB_TABLE}'. Terraform state '${BUCKET_KEY}' in S3 bucket '${S3_BUCKET}' cannot be removed."
        cd "${CURRENT_PATH}"
        exit 1
      fi
    else
      # Provided s3 bucket to be used for keep state of the terraform project does not exist
      echo "S3 bucket '${S3_BUCKET}' is not existed. There is no 'tfstate' resource to destroy"
      cd "${CURRENT_PATH}"
      exit 1
    fi
    cd "${CURRENT_PATH}"
    echo Terraform state is removed successfully.
  else
      echo "Cannot cleanup the Terraform state because ${TF_STATE_FILE} does not exist."
      exit 1
  fi
}

# Process the arguments
process_arguments

# cleanup environment variable and regenerate them
regenerate_environment_variables

# Destroy the infrastructure for the given product
destroy_infrastructure

# Destroy tfstate (S3 bucket key and dynamodb table) of the product
destroy_tfstate

# Delete tfstate and tfvars in asg_ec2_tagging module
cleanup_asg_ec2_tagging_module
