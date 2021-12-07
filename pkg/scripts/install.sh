#!/usr/bin/env bash
# This script manages to deploy the infrastructure for the Atlassian Data Center products
#
# Usage:  install.sh [-c <config_file>] [-h]
# -p <config_file>: Terraform configuration file. The default value is 'config.tfvars' if the argument is not provided.
# -h : provides help to how executing this script.
set -e
set -o pipefail
ROOT_PATH="$(pwd)"
SCRIPT_PATH="$(dirname "$0")"
LOG_FILE="${SCRIPT_PATH}/../../terraform-dc-install_$(date '+%Y-%m-%d_%H-%M-%S').log"
LOG_TAGGING="${SCRIPT_PATH}/../../terraform-dc-asg-tagging_$(date '+%Y-%m-%d_%H-%M-%S').log"
ENVIRONMENT_NAME=
OVERRIDE_CONFIG_FILE=

EKS_PREFIX="atlassian-dc-"
EKS_SUFFIX="-cluster"

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
    CONFIG_FILE="config.tfvars"
  else
    if [[ ! -f "${CONFIG_FILE}" ]]; then
      echo "Terraform configuration file '${CONFIG_FILE}' is not found!"
      show_help
    fi
  fi
  OVERRIDE_CONFIG_FILE="-var-file=${CONFIG_FILE}"
  echo "Terraform uses '${CONFIG_FILE}' to install the infrastructure."

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
  INVALID_CONTENT=$(grep -o '^[^#]*' $CONFIG_FILE | grep '<\|>')
  set -e
  ENVIRONMENT_NAME=$(grep 'environment_name' ${CONFIG_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')
  EKS_CLUSTER_NAME=${EKS_PREFIX}${ENVIRONMENT_NAME}${EKS_SUFFIX}

  if [ "${#EKS_CLUSTER_NAME}" -gt 38 ]; then
    echo "The environment name is too long. The final EKS cluster name is ${EKS_CLUSTER_NAME} and it needs to be less than 38 characters."
    exit 1
  fi

  if [ ! -z "${INVALID_CONTENT}" ]; then
    echo "Configuration file '${CONFIG_FILE}' is not valid."
    echo "Terraform uses this file to generate customised infrastructure for '${ENVIRONMENT_NAME}' on your AWS account."
    echo "Please modify '${CONFIG_FILE}' using a text editor and complete the configuration. "
    echo "Then re-run the install.sh to deploy the infrastructure."
    echo
    echo "${INVALID_CONTENT}"
    exit 0
  fi
}


# Cleaning all the generated terraform state variable and backend file
cleanup_terraform_backend_variables() {
    echo "Cleaning all the generated terraform state variable and backend file."
    sh "${SCRIPT_PATH}/cleanup.sh" -s
}

# Generates ./terraform-backend.tf and ./pkg/tfstate/tfstate-local.tf using the content of local.tf and current aws account
generate_terraform_backend_variables() {
  echo "${ENVIRONMENT_NAME}' infrastructure deployment is started using ${CONFIG_FILE}."

  echo "Terraform state backend/variable files are missing."
  source "${SCRIPT_PATH}/generate-variables.sh" ${CONFIG_FILE} ${ROOT_FOLDER}
}

# Create S3 bucket, bucket key, and dynamodb table to keep state and manage lock if they are not created yet
create_tfstate_resources() {
  # Check if the S3 bucket is existed otherwise create the bucket to keep the terraform state
  echo "Checking the terraform state."
  cd "${SCRIPT_PATH}/../tfstate"
  set +e
  aws s3api head-bucket --bucket "${S3_BUCKET}" 2>/dev/null
  S3_BUCKET_EXISTS=$?
  set -e
  if [ ${S3_BUCKET_EXISTS} -eq 0 ]
  then
    echo "S3 bucket '${S3_BUCKET}' already exists."
    cd "${ROOT_PATH}"
  else
    # create s3 bucket to be used for keep state of the terraform project
    echo "Creating '${S3_BUCKET}' bucket for storing the terraform state..."
    terraform init
    terraform apply -auto-approve "${OVERRIDE_CONFIG_FILE}"
    sleep 5s

    echo "Migrating the terraform state to S3 bucket..."
    cd "${ROOT_PATH}"
    terraform init -migrate-state
  fi
}

# Deploy the infrastructure if is not created yet otherwise apply the changes to existing infrastructure
create_update_infrastructure() {
  Echo "Starting to analyze the infrastructure..."
  terraform init | tee "${LOG_FILE}"
  terraform apply -auto-approve "${OVERRIDE_CONFIG_FILE}" | tee -a "${LOG_FILE}"
}

# Apply the tags into ASG and EC2 instances created by ASG
add_tags_to_asg_resources() {
  echo "Tagging Auto Scaling Group and EC2 instances."
  TAG_MODULE_PATH="${SCRIPT_PATH}/../modules/AWS/asg_ec2_tagging"

  terraform -chdir="${TAG_MODULE_PATH}" init > "${LOG_TAGGING}"
  terraform -chdir="${TAG_MODULE_PATH}" apply -auto-approve "-var-file=${CONFIG_FILE}" >> "${LOG_TAGGING}"
  echo "Resource tags are applied to ASG and all EC2 instances."
}

set_current_context_k8s() {
  EKS_CLUSTER="${EKS_PREFIX}${ENVIRONMENT_NAME}${EKS_SUFFIX}"
  CONTEXT_FILE="kubeconfig_${EKS_CLUSTER}"

  echo
  if [[ -f  "${CONTEXT_FILE}" ]]; then
    echo "EKS Cluster ${EKS_CLUSTER} in region ${REGION} is ready to use."
    echo
    echo "Kubernetes config file could be found at ${CONTEXT_FILE}"
    aws --region "${REGION}" eks update-kubeconfig --name "${EKS_CLUSTER}"
  else
    echo "${CONTEXT_FILE} could not be found."
  fi
  echo

}


# Process the arguments
process_arguments

# Verify the configuration file
verify_configuration_file

# cleanup all the files generated by install.sh previously
cleanup_terraform_backend_variables

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
