#!/usr/bin/env bash
# This script manages to deploy the infrastructure for the given product
#
# Usage:  ./start-dc-terraform.sh <product> [-skip]
# <product>: - At this the script supports only 'bamboo'. If the arguments are missing 'bamboo' will consider by default
# [-skip]: '-skip' as the second argument will skip re-generating the terraform-backend.tf and tfstate-local.tf files

set -e
PRODUCT=$1
SKIP_GENERATE_VARS=$2
CURRENT_PATH="$(pwd)"
SCRIPT_PATH="$(dirname "$0")"

process_arguments() {
  if [ $# -eq 0 ]
    then
      PRODUCT="bamboo"
  else
    # for now only bamboo is supported
    declare -l PRODUCT
    if [ ${PRODUCT} != "bamboo" ]; then
      echo "'${PRODUCT}' is not supported."
      exit 1
    fi
  fi
}

generate_backend_variables() {
  BACKEND_TF="${SCRIPT_PATH}/../../terraform-backend.tf"
  TFSTATE_LOCALS="${SCRIPT_PATH}/../tfstate/tfstate-locals.tf"
  if [[ $SKIP_GENERATE_VARS == "-skip" ]]; then
    if [[ -f $BACKEND_TF && -f $TFSTATE_LOCALS ]]; then
      echo "Skipped generating tfstate variable files. The existing files will be used."
      exit 0
    fi
      echo "Terraform state backend/variable files are missing."
      exit 1
  fi

  source "${SCRIPT_PATH}/generate-tfstate-backend.sh" ${BACKEND_TF} ${TFSTATE_LOCALS}

  # fetch the locals.tf file from terraform project
  cp -fr "${SCRIPT_PATH}/../../locals.tf" "${SCRIPT_PATH}/../tfstate"
}

create_tfstate_bucket() {
  # Check if the S3 bucket is existed otherwise create the bucket to keep the terraform state
  echo "Checking the terraform state."
  cd "${SCRIPT_PATH}/../tfstate"
  set +e
  aws s3api head-bucket --bucket "$S3_BUCKET"
  S3_BUCKET_EXISTS=$?
  set -e
  if [ $S3_BUCKET_EXISTS -eq 0 ]
  then
    echo "S3 bucket '$S3_BUCKET' is already existed."
    cd "${CURRENT_PATH}"
  else
    # create s3 bucket to be used for keep state of the terraform project
    echo "Creating '$S3_BUCKET' bucket for storing the terraform state..."
    terraform init
    terraform apply -auto-approve
    sleep 5s

    echo "Migrating the terraform state to S3 bucket..."
    cd "${CURRENT_PATH}"
    terraform init -migrate-state
  fi
}

create_infrastructure() {
  Echo "Starting to analyze the infrastructure..."
  terraform init
  terraform apply -auto-approve
}

# Process the arguments - Validate the PRODUCT (first argument) and second argument to see if skip generating backend vars
process_arguments

# Generates ./terraform-backend.tf and ./pkg/tfstate/tfstate-local.tf using the content of local.tf and current aws account
generate_backend_variables

# Create S3 bucket and dynamodb table to keep state and manage lock if they are not created yet
create_tfstate_bucket

# Deploy the infrastructure if is not created yet otherwise apply the changes to existing infrastructure
create_infrastructure



