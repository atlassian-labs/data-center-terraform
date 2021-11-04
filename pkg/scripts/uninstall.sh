#!/usr/bin/env bash
# This script manages to destroy the infrastructure for the given product
#
# Syntax:  uninstall <product> [-s] [-h]
# <product>: - At this the script supports only 'bamboo'. If the arguments are missing 'bamboo' will consider by default

set -e
CURRENT_PATH="$(pwd)"
SCRIPT_PATH="$(dirname "$0")"

show_help(){
  if [ ! -z "${HELP_FLAG}" ]; then
cat << EOF
** WARNING **
This script destroys the infrastructure for Atlassian Data Center products in AWS environment. You may lose all application data.
The infrastructure will be removed by terraform. Also the terraform state will be removed from the S3 bucket which will be provision by this script if is not existed.
EOF

  fi
  echo
  echo "Usage:  ./uninstall.sh -p <product> [-h] [-s]"
  echo "   <product>: name of the product to uninstall. At this point we only support 'bamboo'."
  echo "   -s : Skip cleaning up the terraform state"
  echo "   -h : provides help to how executing this script."
  echo
  exit 2
}

# Extract arguments
  declare -l PRODUCT
  HELP_FLAG=
  SKIP_TFSTATE=
  while getopts sh?p: name ; do
      case $name in
      s)  SKIP_TFSTATE=1;;            # Skip cleaning terraform state
      h)  HELP_FLAG=1; show_help;;    # Help
      p)  PRODUCT="${OPTARG}";;       # Product name for uninstall
      ?)  echo "Invalid arguments."; show_help
      esac
  done

  shift $((${OPTIND} - 1))
  UNKNOWN_ARGS="$*"

 # Validate the arguments. PRODUCT (first argument) and second argument to see if skip generating backend vars
process_arguments() {
  if [ ! -z "${PRODUCT}" ]; then
    if [ ${PRODUCT} == "bamboo" ]; then
      echo "Preparing to uninstall the infrastructure of '${PRODUCT}'."./
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

destroy_infrastructure() {
  cd "${SCRIPT_PATH}/../../"
  set +e
  terraform destroy
  if [ $? -eq 0 ]; then
    set -e
  else
    cd "${CURRENT_PATH}"
    exit 1
  fi
  cd "${CURRENT_PATH}"
  echo ${PRODUCT} infrastructure is removed successfully.
}


destroy_tfstate() {
  echo $SKIP_TFSTATE
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

    cd "${SCRIPT_PATH}/../tfstate"
    set +e
    aws s3api head-bucket --bucket "${S3_BUCKET}"
    S3_BUCKET_EXISTS=$?
    set -e
    if [ ${S3_BUCKET_EXISTS} -eq 0 ]
    then
      set +e
      terraform destroy -target 'module.tfstate-table'
      if [ $? -eq 0 ]; then
        set -e
        aws "s3" "rm" "s3://${S3_BUCKET}/${BUCKET_KEY%%/*}" "--recursive"
      else
        echo "Couldn't destroy dynamodb table. Terraform state '${BUCKET_KEY}' in S3 bucket '${S3_BUCKET}' cannot be removed."
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

# Destroy the infrastructure for the given product
destroy_infrastructure

# Destroy tfstate (S3 bucket key and dynamodb table) of the product
destroy_tfstate


