#!/usr/bin/env bash
# This script manages to deploy the infrastructure for the Atlassian Data Center products
#
# Usage:  install.sh [-c <config_file>] [-h]
# -p <config_file>: Terraform configuration file. The default value is 'config.tfvars' if the argument is not provided.
# -h : provides help to how executing this script.
set -e
set -o pipefail
ROOT_PATH="$(dirname "$0")"
SCRIPT_PATH="${ROOT_PATH}/pkg/scripts"
LOG_FILE="${ROOT_PATH}/logs/terraform-dc-install_$(date '+%Y-%m-%d_%H-%M-%S').log"
LOG_TAGGING="${ROOT_PATH}/logs/terraform-dc-asg-tagging_$(date '+%Y-%m-%d_%H-%M-%S').log"

ENVIRONMENT_NAME=
OVERRIDE_CONFIG_FILE=


show_help(){
  if [ ! -z "${HELP_FLAG}" ]; then
cat << EOF
This script provisions the infrastructure for Atlassian Data Center products in AWS environment.
The infrastructure will be generated by terraform and state of the resources will be kept in a S3 bucket which will be provision by this script if is not existed.

Before installing the infrastructure make sure you have completed the configuration process and did all perquisites.
For more information visit https://github.com/atlassian-labs/data-center-terraform.
EOF

  fi
  echo
  echo "Usage:  ./install.sh [-c <config_file>] [-h]"
  echo "   -c <config_file>: Terraform configuration file. The default value is 'config.tfvars' if the argument is not provided."
  echo "   -h : provides help to how executing this script."
  echo
  exit 2
}

# Extract arguments
  CONFIG_FILE=
  HELP_FLAG=
  while getopts h?c: name ; do
      case $name in
      h)    HELP_FLAG=1; show_help;;  # Help
      c)    CONFIG_FILE="${OPTARG}";; # Config file name to install - this overrides the default, 'config.tfvars'
      ?)    echo "Invalid arguments."; show_help
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
  
  echo "Terraform uses '${CONFIG_ABS_PATH}' to install the infrastructure."

  if [ ! -z "${UNKNOWN_ARGS}" ]; then
    echo "Unknown arguments:  ${UNKNOWN_ARGS}"
    show_help
  fi
}


# Make sure the infrastructure config file is existed and contains the valid data
verify_configuration_file() {
  echo "Verifying the config file."

  # Make sure the config values are defined
  set +e
  INVALID_CONTENT=$(grep -o '^[^#]*' ${CONFIG_ABS_PATH} | grep '<\|>')
  set -e
  ENVIRONMENT_NAME=$(grep 'environment_name' ${CONFIG_ABS_PATH} | sed -nE 's/^.*"(.*)".*$/\1/p')

  if [ "${#ENVIRONMENT_NAME}" -gt 25 ]; then
    echo "The environment name '${ENVIRONMENT_NAME}' is too long(${#ENVIRONMENT_NAME} characters)."
    echo "Please make sure your environment name is less than 25 characters"
    exit 1
  fi

  if [ ! -z "${INVALID_CONTENT}" ]; then
    echo "Configuration file '${CONFIG_ABS_PATH}' is not valid."
    echo "Terraform uses this file to generate customised infrastructure for '${ENVIRONMENT_NAME}' on your AWS account."
    echo "Please modify '${CONFIG_ABS_PATH}' using a text editor and complete the configuration. "
    echo "Then re-run the install.sh to deploy the infrastructure."
    echo
    echo "${INVALID_CONTENT}"
    exit 0
  fi
}

# Generates ./terraform-backend.tf and ./pkg/tfstate/tfstate-local.tf using the content of local.tf and current aws account
generate_terraform_backend_variables() {
  echo "${ENVIRONMENT_NAME}' infrastructure deployment is started using ${CONFIG_ABS_PATH}."

  echo "Terraform state backend/variable files are not created yet."
  source "${SCRIPT_PATH}/generate-variables.sh" ${CONFIG_ABS_PATH} ${ROOT_PATH}
}

# Create S3 bucket, bucket key, and dynamodb table to keep state and manage lock if they are not created yet
create_tfstate_resources() {
  # Check if the S3 bucket is existed otherwise create the bucket to keep the terraform state
  echo "Checking the terraform state."
  if ! test -d "${ROOT_PATH}/logs" ; then
    mkdir "${ROOT_PATH}/logs"
  fi
  touch "${LOG_FILE}"
  local STATE_FOLDER="${SCRIPT_PATH}/../tfstate"
  set +e
  aws s3api head-bucket --bucket "${S3_BUCKET}" 2>/dev/null
  S3_BUCKET_EXISTS=$?
  set -e
  if [ ${S3_BUCKET_EXISTS} -eq 0 ]
  then
    echo "S3 bucket '${S3_BUCKET}' already exists."
  else
    # create s3 bucket to be used for keep state of the terraform project
    echo "Creating '${S3_BUCKET}' bucket for storing the terraform state..."
    if ! test -d "${STATE_FOLDER}/.terraform" ; then
      terraform -chdir="${STATE_FOLDER}" init -no-color | tee -a "${LOG_FILE}"
    fi
    terraform -chdir="${STATE_FOLDER}" apply -auto-approve -no-color "${OVERRIDE_CONFIG_FILE}" | tee -a "${LOG_FILE}"
    sleep 5s
  fi
}

# Deploy the infrastructure if is not created yet otherwise apply the changes to existing infrastructure
create_update_infrastructure() {
  Echo "Starting to analyze the infrastructure..."
  if ! test -d "${ROOT_PATH}/.terraform" ; then
    echo "Migrating the terraform state to S3 bucket..."
    terraform -chdir="${ROOT_PATH}" init -no-color -migrate-state | tee -a "${LOG_FILE}"
    terraform -chdir="${ROOT_PATH}" init -no-color | tee -a "${LOG_FILE}"
  fi
  terraform -chdir="${ROOT_PATH}" apply -auto-approve -no-color "${OVERRIDE_CONFIG_FILE}" | tee -a "${LOG_FILE}"
}

# Apply the tags into ASG and EC2 instances created by ASG
add_tags_to_asg_resources() {
  echo "Tagging Auto Scaling Group and EC2 instances. It may take a few minutes. Please wait..."
  TAG_MODULE_PATH="${SCRIPT_PATH}/../modules/AWS/asg_ec2_tagging"

  terraform -chdir="${TAG_MODULE_PATH}" init -no-color > "${LOG_TAGGING}"
  terraform -chdir="${TAG_MODULE_PATH}" apply -auto-approve -no-color "${OVERRIDE_CONFIG_FILE}" >> "${LOG_TAGGING}"
  echo "Resource tags are applied to ASG and all EC2 instances."
}

set_current_context_k8s() {
  local EKS_PREFIX="atlas-"
  local EKS_SUFFIX="-cluster"
  local EKS_CLUSTER_NAME=${EKS_PREFIX}${ENVIRONMENT_NAME}${EKS_SUFFIX}
  local EKS_CLUSTER="${EKS_CLUSTER_NAME:0:38}"
  CONTEXT_FILE="${ROOT_PATH}/kubeconfig_${EKS_CLUSTER}"

  echo
  if [[ -f  "${CONTEXT_FILE}" ]]; then
    echo "EKS Cluster ${EKS_CLUSTER} in region ${REGION} is ready to use."
    echo
    echo "Kubernetes config file could be found at '${CONTEXT_FILE}'"
    aws --region "${REGION}" eks update-kubeconfig --name "${EKS_CLUSTER}"
  else
    echo "Kubernetes context file '${CONTEXT_FILE}' could not be found."
  fi
  echo

}


# Process the arguments
process_arguments

# Verify the configuration file
verify_configuration_file

# Generates ./terraform-backend.tf and ./pkg/tfstate/tfstate-local.tf
generate_terraform_backend_variables

# Create S3 bucket and dynamodb table to keep state
create_tfstate_resources

# Deploy the infrastructure
create_update_infrastructure

# Manually add resource tags into ASG and EC2 
add_tags_to_asg_resources

# Print information about manually adding the new k8s context
set_current_context_k8s
