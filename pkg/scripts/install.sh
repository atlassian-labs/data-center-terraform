#!/usr/bin/env bash
# This script manages to deploy the infrastructure for the given product
#
# Syntax:  install.sh [-p <product>] [-h]
# -p <product>: name of the product to install. The default value is 'bamboo' if the argument is not provided.
# -h : provides help to how executing this script.

set -e
CURRENT_PATH="$(pwd)"
SCRIPT_PATH="$(dirname "$0")"

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
  echo "Usage:  ./install.sh [-p <product>] [-h]"
  echo "   -p <product>: name of the product to install. The default value is 'bamboo' if the argument is not provided."
  echo "   -h : provides help to how executing this script."
  echo
  exit 2
}

# Extract arguments
  declare -l PRODUCT
  PRODUCT="bamboo"
  HELP_FLAG=
  while getopts h?p: name ; do
      case $name in
      h)    HELP_FLAG=1; show_help;;  # Help
      p)    PRODUCT="${OPTARG}";;     # Product name to install
      ?)    echo "Invalid arguments."; show_help
      esac
  done

  shift $((${OPTIND} - 1))
  UNKNOWN_ARGS="$*"

# Validate the arguments. PRODUCT (first argument) and second argument to see if skip generating backend vars
process_arguments() {
  if [ ! -z "${PRODUCT}" ]; then
    if [ ${PRODUCT} == "bamboo" ]; then
      echo "Preparing the infrastructure to install '${PRODUCT}'."
    else
      echo "The product '${PRODUCT}' is not supported. At this point only we support the following products:"
      echo "     1. bamboo"
      echo
      exit 1
    fi
  else
    echo "Invalid arguments."
    show_help
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
  CONFIG_FILE="${SCRIPT_PATH}/../../config.auto.tfvars"
  CONFIG_TEMP="${SCRIPT_PATH}/../../config.auto.tfvars.example"

  # clone config.auto.tfvars.backup from config.auto.tfvars.backup.example if is not existed
  if [[ ! -f  "./config.auto.tfvars" ]]; then
    cp "${CONFIG_TEMP}" "${CONFIG_FILE}"
  fi

  # Make sure the config values are defined
  set +e
  INVALID_CONTENT=$(grep '<' $CONFIG_FILE & grep '>' $CONFIG_FILE)
  set -e

  if [ ! -z "${INVALID_CONTENT}" ]; then
    echo "Configuration file 'config.auto.tfvars' is not defined yet."
    echo "Terraform uses this file to generate customised infrastructure for '${PRODUCT}' on your account."
    echo "Please modify 'config.auto.tfvars' using a text editor and add proper values in config variables. "
    echo "Then re-run the script to deploy the infrastructure."
    echo
    exit 0
  fi
}

# Generates ./terraform-backend.tf and ./pkg/tfstate/tfstate-local.tf using the content of local.tf and current aws account
generate_backend_variables() {
  BACKEND_TF="${SCRIPT_PATH}/../../terraform-backend.tf"
  TFSTATE_LOCALS="${SCRIPT_PATH}/../tfstate/tfstate-locals.tf"

  if [[ -f ${BACKEND_TF} && -f ${TFSTATE_LOCALS} ]]; then
    echo "Terraform state backend/variable files are already existed. "
  else
    echo "Terraform state backend/variable files are missing."
    source "${SCRIPT_PATH}/generate-tfstate-backend.sh" ${BACKEND_TF} ${TFSTATE_LOCALS}
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
