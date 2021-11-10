#!/usr/bin/env bash
# This script manages to deploy the infrastructure for the Atlassian Data Center products
#
# Usage:  install.sh [-c <config_file>] [-h]
# -p <config_file>: Terraform configuration file. The default value is 'config.auto.tfvars' if the argument is not provided.
# -h : provides help to how executing this script.

set -e
CURRENT_PATH="$(pwd)"
SCRIPT_PATH="$(dirname "$0")"
ENVIRONMENT_NAME=

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
  echo "   -c <config_file>: Terraform configuration file. The default value is 'config.auto.tfvars' if the argument is not provided."
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
      c)    CONFIG_FILE="${OPTARG}";; # Config file name to install - this overrides the default, 'config.auto.tfvars'
      ?)    echo "Invalid arguments."; show_help
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
  fi

  if [ ! -z "${UNKNOWN_ARGS}" ]; then
    echo "Unknown arguments:  ${UNKNOWN_ARGS}"
    show_help
  fi
}

#Cleaning all the generated terraform state variable and backend file
cleanup_backen_variables() {
    echo "Cleaning all the generated terraform state variable and backend file."
    source "${SCRIPT_PATH}/cleanup.sh"
}

# Make sure the infrastructure config file is existed and contains the valid data
verify_configuration_file() {
  echo "Verifying the config file."

  # Make sure the config values are defined
  set +e
  INVALID_CONTENT=$(grep '<' $CONFIG_FILE & grep '>' $CONFIG_FILE)
  set -e
  ENVIRONMENT_NAME=$(grep 'environment_name' ${CONFIG_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')

  if [ ! -z "${INVALID_CONTENT}" ]; then
    echo "Configuration file '${CONFIG_FILE}' is not valid."
    echo "Terraform uses this file to generate customised infrastructure for '${ENVIRONMENT_NAME}' on your AWS account."
    echo "Please modify '${CONFIG_FILE}' using a text editor and complete the configuration. "
    echo "Then re-run the install.sh to deploy the infrastructure."
    echo
    exit 0
  fi
}

# Generates ./terraform-backend.tf and ./pkg/tfstate/tfstate-local.tf using the content of local.tf and current aws account
generate_backend_variables() {
  BACKEND_TF="${SCRIPT_PATH}/../../terraform-backend.tf"
  TFSTATE_LOCALS="${SCRIPT_PATH}/../tfstate/tfstate-locals.tf"

  echo "${ENVIRONMENT_NAME}' infrastructure deployment is started using ${CONFIG_FILE}."

  if [[ -f ${BACKEND_TF} && -f ${TFSTATE_LOCALS} ]]; then
    echo "Terraform state backend/variable files are already existed. "
  else
    echo "Terraform state backend/variable files are missing."
    source "${SCRIPT_PATH}/generate-tfstate-backend.sh" ${CONFIG_FILE} ${BACKEND_TF} ${TFSTATE_LOCALS}
  fi

  # fetch the config files from root
  cp -fr "${SCRIPT_PATH}/../../variables.tf" "${SCRIPT_PATH}/../tfstate"
  cp -fr "${SCRIPT_PATH}/../../config.auto.tfvars" "${SCRIPT_PATH}/../tfstate"
}

# Create S3 bucket, bucket key, and dynamodb table to keep state and manage lock if they are not created yet
create_tfstate_resources() {
  # Check if the S3 bucket is existed otherwise create the bucket to keep the terraform state
  echo "Checking the terraform state."
  cd "${SCRIPT_PATH}/../tfstate"
  set +e
  aws s3api head-bucket --bucket "${S3_BUCKET}"
  S3_BUCKET_EXISTS=$?
  set -e
  if [ ${S3_BUCKET_EXISTS} -eq 0 ]
  then
    echo "S3 bucket '${S3_BUCKET}' is already existed."
    cd "${CURRENT_PATH}"
  else
    # create s3 bucket to be used for keep state of the terraform project
    echo "Creating '${S3_BUCKET}' bucket for storing the terraform state..."
    terraform init
    terraform apply -auto-approve
    sleep 5s

    echo "Migrating the terraform state to S3 bucket..."
    cd "${CURRENT_PATH}"
    terraform init -migrate-state
  fi
}

# Deploy the infrastructure if is not created yet otherwise apply the changes to existing infrastructure
create_update_infrastructure() {
  Echo "Starting to analyze the infrastructure..."
  terraform init
  terraform apply -auto-approve
}

set_current_context_k8s() {
  EKS_CLUSTER="atlassian-dc-${ENVIRONMENT_NAME}-cluster"
  CONTEXT_FILE="${CURRENT_PATH}/kubeconfig_${EKS_CLUSTER}"

  echo
  if [[ -f  "${CONTEXT_FILE}" ]]; then
    echo "EKS Cluster ${EKS_CLUSTER} in region ${REGION} is ready to use."
    echo
    echo "If you like to use kubectl to access to the cluster directly you can run either of the following commands:"
    echo
    echo "   export KUBECONFIG=${KUBECONFIG}:${CONTEXT_FILE}"
    echo "   aws --region ${REGION} eks update-kubeconfig --name ${EKS_CLUSTER}"
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
cleanup_backen_variables

# Generates ./terraform-backend.tf and ./pkg/tfstate/tfstate-local.tf
generate_backend_variables

# Create S3 bucket and dynamodb table to keep state
create_tfstate_resources

# Deploy the infrastructure
create_update_infrastructure

# Print information about manually adding the new k8s context
set_current_context_k8s
