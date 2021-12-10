# This script will generate/override the `./pkg/tfstate/tfstate-locals.tf` and `./terraform-backend.tf`

show_help() {
    echo "The terraform config filename for infrastructure is missing."
    echo
    echo "Usage: generate-variables.sh <config_file>"
    exit 1
}

if [ $# -lt 1 ]; then
  show_help
fi
CONFIG_FILE="${1}"
if [ ! -f "${CONFIG_FILE}" ]; then
  echo "Could not find config file ${CONFIG_FILE}."
  show_help
fi

# this script is located in {repo_root_path}/pkg/scripts
SCRIPT_PATH="$(dirname "$0")"
ROOT_PATH="${SCRIPT_PATH}/../.."

set_variables() {
  echo ${CONFIG_FILE}
  # extract S3 bucket, dynamodb, tags, and region from locals.tf
  ENVIRONMENT_NAME=$(grep 'environment_name' ${CONFIG_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')
  REGION=$(grep 'region' ${CONFIG_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')

  # Get the AWS account ID
  AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

  # Generates the unique s3 bucket and key names for the deployment for keeping the terraform state
  S3_BUCKET="atlas-${ENVIRONMENT_NAME}-${REGION}-${AWS_ACCOUNT_ID}-tfst"
  BUCKET_KEY="${ENVIRONMENT_NAME}-${AWS_ACCOUNT_ID}"

  # length of the bucket name should be less than 64 characters
  S3_BUCKET="${S3_BUCKET:0:63}"

  # Generates the unique dynamodb table names for the deployment lock ( convert all '-' to '_' )
  DYNAMODB_TABLE="tf_lock_${ENVIRONMENT_NAME//-/_}_${AWS_ACCOUNT_ID}"

  BACKEND_TF="${ROOT_PATH}/terraform-backend.tf"
  TFSTATE_LOCALS="${ROOT_PATH}/pkg/tfstate/tfstate-locals.tf"
  ASG_EC2_TAG_PATH="${ROOT_PATH}/pkg/modules/AWS/asg_ec2_tagging"
}

# Cleaning all the generated terraform state variable and backend file
cleanup_existing_files() {
  if [ -f ${BACKEND_TF} ]; then
    # remove terraform generated files if the environment name or AWS Account ID or Region has changed
    set +e
    if ! grep -q \""${S3_BUCKET}"\" "${BACKEND_TF}"  ; then
      echo "We found you have used this instance to create a different environment previously."
      echo "Installing or uninstalling a different environment will override the terraform state files."
      echo "As the result, you will not able to manage the previous environment by terraform anymore."
      echo
      echo "We strongly suggest you to use a different instance to provision each new infrastructure or make a backup of"
      echo "the './pkg/tfstate' folder (including hidden files) before proceeding."
      echo
      echo "We are about to override terraform state files and replace it by new state for environment '${ENVIRONMENT_NAME}'"
      read -p "Are you sure(Yes/No)? " yn
      case $yn in
          Yes|yes ) echo "Thank you. We have your confirmation to proceed.";;
          No|no|n|N ) exit;;
          * ) echo "Please answer 'Yes' to confirm deleting the infrastructure."; exit;;
      esac
      CLEANUP_TERRAFORM_FILES='-t'
    fi
    set -e
  fi
  echo "Cleaning all the generated variable files."
  sh "${SCRIPT_PATH}/cleanup.sh" -s "${CLEANUP_TERRAFORM_FILES}"
}




inject_variables_to_templates() {
  # Generate the terraform backend, where terraform store the state of the infrastructure
  echo "Generating the terraform backend definition file 'terraform.backend.tf'."
  sed 's/<REGION>/'${REGION}'/g'  "${ROOT_PATH}/pkg/templates/terraform-backend.tf.tmpl" | \
  sed 's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
  sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
  sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
    > ${BACKEND_TF}

  # Generate the locals for terraform state
  echo "Generating the terraform state local file 'pkg/tfstate/tfstate-locals.tf'."
  sed 's/<REGION>/'${REGION}'/g'  "${ROOT_PATH}/pkg/templates/tfstate-locals.tf.tmpl" | \
  sed 's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
  sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
  sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
    > ${TFSTATE_LOCALS}
}


copy_injected_files() {
  # fetch the config files from root
  cp -fr "${ROOT_PATH}/variables.tf" "${ROOT_PATH}/pkg/tfstate"
  cp -fr "${CONFIG_FILE}" "${ROOT_PATH}/pkg/tfstate"

  # copy variable files for tagging module
  cp "${CONFIG_FILE}" "${ASG_EC2_TAG_PATH}"
  cp "${ROOT_PATH}/variables.tf" "${ASG_EC2_TAG_PATH}"
  cp "${TFSTATE_LOCALS}" "${ASG_EC2_TAG_PATH}"
}


set_variables
cleanup_existing_files
inject_variables_to_templates
copy_injected_files
